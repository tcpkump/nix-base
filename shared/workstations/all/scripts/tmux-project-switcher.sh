#!/usr/bin/env bash

# tmux project switcher script
# Lists project directories and opens the selected one in a new tmux window
# Supports git worktrees: create new worktrees (+ new worktree) and
# delete linked worktrees (ctrl-x) with uncommitted/unpushed change warnings.

set -euo pipefail

# Configuration
PROJECTS_ROOT="$HOME/repos"
EXCLUDE_PATTERNS=(".git" "node_modules" "__pycache__" ".venv" "venv" "build" "dist" ".next")

# Sentinel entry shown at the top of the fzf list to trigger worktree creation
NEW_WORKTREE_SENTINEL="+ new worktree"

# Function to find project directories
find_projects() {
    # Main clones: find .git directories and return their parent (the working tree root)
    find "$PROJECTS_ROOT" -maxdepth 3 -type d -name ".git" | while read -r git_dir; do
        project_dir=$(dirname "$git_dir")
        # Skip if matches any exclude pattern
        skip=false
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "$project_dir" == *"$pattern"* ]]; then
                skip=true
                break
            fi
        done

        if [[ "$skip" == false ]]; then
            # Remove the projects root path to show relative paths
            echo "${project_dir#"$PROJECTS_ROOT"/}"
        fi
    done

    # Linked worktrees: find .git files (gitdir pointers) rather than directories.
    # Worktrees use a .git file instead of a .git directory, so they're invisible
    # to the main clone search above. maxdepth 4 reaches sibling dirs one level
    # deeper than the repos root (e.g. ~/repos/personal/nixCats-config-feat-x/).
    find "$PROJECTS_ROOT" -maxdepth 4 -name ".git" ! -type d | while read -r git_file; do
        project_dir=$(dirname "$git_file")
        skip=false
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "$project_dir" == *"$pattern"* ]]; then
                skip=true
                break
            fi
        done

        if [[ "$skip" == false ]]; then
            echo "${project_dir#"$PROJECTS_ROOT"/}"
        fi
    done
}

# List only main clones (those with a .git directory) for the worktree creation
# repo-selection step. Bare clones and linked worktrees are excluded here.
find_main_clones() {
    find "$PROJECTS_ROOT" -maxdepth 3 -type d -name ".git" | while read -r git_dir; do
        dirname "$git_dir"
    done | sort
}

# Prompt the user to pick a repo and branch name, create the worktree as a
# sibling directory of the main clone, then open it in a new tmux window.
create_worktree() {
    local repo_path
    repo_path=$(find_main_clones | sed "s|$PROJECTS_ROOT/||" | \
        fzf --prompt="Select repo: " --height=40% --reverse --border) || return

    [[ -z "$repo_path" ]] && return

    local full_repo_path="$PROJECTS_ROOT/$repo_path"

    printf "Branch name: "
    read -r branch_name
    [[ -z "$branch_name" ]] && return

    # Place the worktree next to the main clone, named <repo>-<branch>
    local repo_basename
    repo_basename=$(basename "$full_repo_path")
    local worktree_path
    worktree_path="$(dirname "$full_repo_path")/${repo_basename}-${branch_name}"

    git -C "$full_repo_path" worktree add "$worktree_path" -b "$branch_name"

    # Open the new worktree immediately
    local project_name
    project_name=$(basename "$worktree_path")
    tmux new-window -c "$worktree_path" -n "$project_name"
    tmux send-keys 'nvim' 'Enter'
}

# Remove a linked worktree after checking for work that would be lost.
# Warns about uncommitted changes and unpushed commits before prompting.
delete_worktree() {
    local full_path="$1"
    local project_name
    project_name=$(basename "$full_path")

    local uncommitted
    uncommitted=$(git -C "$full_path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

    # Unpushed commits: compare HEAD to the upstream tracking branch.
    # Suppress errors for branches with no upstream configured.
    local unpushed="0"
    unpushed=$(git -C "$full_path" log --oneline "@{u}..HEAD" 2>/dev/null | wc -l | tr -d ' ') || true

    printf "\nDelete worktree: %s\nPath: %s\n" "$project_name" "$full_path"

    if [[ "$uncommitted" -gt 0 || "$unpushed" -gt 0 ]]; then
        printf "\nWARNING - you will lose:\n"
        [[ "$uncommitted" -gt 0 ]] && printf "  %s uncommitted change(s)\n" "$uncommitted"
        [[ "$unpushed" -gt 0 ]] && printf "  %s unpushed commit(s)\n" "$unpushed"
    fi

    printf "\nConfirm delete? [y/N] "
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Use the common git dir to run worktree remove from outside the worktree
        # being deleted, avoiding git's "cannot remove current worktree" check.
        local git_common_dir
        git_common_dir=$(git -C "$full_path" rev-parse --git-common-dir)
        git --git-dir="$git_common_dir" worktree remove --force "$full_path"
        printf "Removed.\n"
        sleep 1
    else
        printf "Cancelled.\n"
        sleep 1
    fi
}

# Main function
main() {
    # Check if we're in a tmux session
    if [[ -z "${TMUX:-}" ]]; then
        echo "Error: This script must be run from within a tmux session"
        exit 1
    fi

    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required but not installed"
        exit 1
    fi

    local projects
    projects=$(find_projects | sort)

    # Prepend the creation sentinel so it always appears at the top.
    # --expect=ctrl-x captures that key as an alternate action (delete);
    # fzf then outputs the key on line 1 and the selection on line 2.
    local result
    result=$(printf "%s\n%s" "$NEW_WORKTREE_SENTINEL" "$projects" | fzf \
        --prompt="Select project: " \
        --height=40% \
        --reverse \
        --border \
        --header="enter: open  ctrl-x: delete worktree" \
        --expect=ctrl-x) || exit 0

    local key selected
    key=$(printf "%s" "$result" | head -1)
    selected=$(printf "%s" "$result" | tail -1)

    if [[ -z "$selected" ]]; then
        echo "No project selected"
        exit 0
    fi

    if [[ "$selected" == "$NEW_WORKTREE_SENTINEL" ]]; then
        create_worktree
        exit 0
    fi

    local full_path="$PROJECTS_ROOT/$selected"

    # Check if directory exists
    if [[ ! -d "$full_path" ]]; then
        echo "Error: Directory $full_path does not exist"
        exit 1
    fi

    if [[ "$key" == "ctrl-x" ]]; then
        # Only linked worktrees (those with a .git file) can be removed this way.
        # Refuse to delete a main clone — that would need a manual git clone removal.
        if [[ ! -f "$full_path/.git" ]]; then
            printf "Cannot delete '%s': not a linked worktree.\n" "$selected"
            sleep 2
            exit 1
        fi
        delete_worktree "$full_path"
        exit 0
    fi

    # Get the project name for the window title (just the directory name)
    local project_name
    project_name=$(basename "$selected")

    # Create a new tmux window with the project directory as working directory
    tmux new-window -c "$full_path" -n "$project_name"

    # Open neovim in the new window
    tmux send-keys 'nvim' 'Enter'

    echo "Opened project '$selected' in new window: $project_name"
}

# Check if fzf is available
if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is required but not installed"
    exit 1
fi

main "$@"
