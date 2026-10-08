#!/usr/bin/env sh
set -eu
repo="${1:-.}"; recent="${2:-8}"
cd "$repo"
echo "ROOT=$(git rev-parse --show-toplevel)"
echo "HEAD=$(git rev-parse HEAD)"
git status --short --branch
echo "-- RECENT --"; git log --oneline --decorate -n "$recent"
echo "-- WORKTREES --"; git worktree list
