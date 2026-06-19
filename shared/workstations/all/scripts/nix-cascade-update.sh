#!/usr/bin/env bash
# Propagate upstream flake changes through nixcats-config → nix-base → nix-work and rebuild.
# Usage: nix-cascade-update [--skip-nixcats] [--no-rebuild]
# Env: NIX_REPOS_DIR (default: ~/repos/personal), NIX_CONFIG_NAME (default: hostname)
set -euo pipefail

REPOS_DIR="${NIX_REPOS_DIR:-$HOME/repos/personal}"
NIX_BASE_DIR="$REPOS_DIR/nix-base"
NIX_WORK_DIR="$REPOS_DIR/nix-work"
CONFIG="${NIX_CONFIG_NAME:-$(hostname -s)}"

SKIP_NIXCATS=false
NO_REBUILD=false
for arg in "$@"; do
  case "$arg" in
    --skip-nixcats) SKIP_NIXCATS=true ;;
    --no-rebuild)   NO_REBUILD=true ;;
  esac
done

if [[ "$SKIP_NIXCATS" == "false" ]]; then
  echo "==> Updating nixcats-config pin in nix-base..."
  pushd "$NIX_BASE_DIR" > /dev/null
  nix flake update nixcats-config
  if ! git diff --quiet flake.lock; then
    git add flake.lock && git commit -m "chore: nix flake update" && git push
  else
    echo "  no changes"
  fi
  popd > /dev/null
fi

echo "==> Updating nix-base pin in nix-work..."
pushd "$NIX_WORK_DIR" > /dev/null
nix flake update nix-base
if ! git diff --quiet flake.lock; then
  git add flake.lock && git commit -m "chore: nix flake update" && git push
else
  echo "  no changes"
fi
popd > /dev/null

if [[ "$NO_REBUILD" == "false" ]]; then
  echo "==> Rebuilding $CONFIG..."
  if [[ "$(uname)" == "Darwin" ]]; then
    darwin-rebuild switch --flake "$NIX_WORK_DIR#$CONFIG"
  else
    sudo nixos-rebuild switch --flake "$NIX_WORK_DIR#$CONFIG"
  fi
fi
