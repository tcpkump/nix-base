#!/usr/bin/env bash

# tmux project switcher script
# Lists project directories and opens the selected one in a new tmux window

set -euo pipefail

# Configuration
PROJECTS_ROOT="$HOME/repos"
EXCLUDE_PATTERNS=(".git" "node_modules" "__pycache__" ".venv" "venv" "build" "dist" ".next")

# Function to find project directories
find_projects() {
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
    done | sort
}

# Main function
main() {
    # Check if we're in a tmux session
    if [[ -z "${TMUX:-}" ]]; then
        echo "Error: This script must be run from within a tmux session"
        exit 1
    fi

    # Find projects and let user select
    selected_project=$(find_projects | fzf --prompt="Select project: " --height=40% --reverse --border)
    
    if [[ -z "$selected_project" ]]; then
        echo "No project selected"
        exit 0
    fi
    
    full_path="$PROJECTS_ROOT/$selected_project"
    
    # Check if directory exists
    if [[ ! -d "$full_path" ]]; then
        echo "Error: Directory $full_path does not exist"
        exit 1
    fi
    
    # Get the project name for the window title (just the directory name)
    project_name=$(basename "$selected_project")
    
    # Create a new tmux window with the project directory as working directory
    tmux new-window -c "$full_path" -n "$project_name"
    
    # Open neovim in the new window
    tmux send-keys 'nvim' 'Enter'
    
    echo "Opened project '$selected_project' in new window: $project_name"
}

# Check if fzf is available
if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is required but not installed"
    exit 1
fi

main "$@"
