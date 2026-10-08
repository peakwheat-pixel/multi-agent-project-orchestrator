param([string]$Repository=".",[int]$Recent=8,[switch]$Full)
$ErrorActionPreference="Stop"
Push-Location $Repository
try {
  "ROOT=" + (git rev-parse --show-toplevel)
  "HEAD=" + (git rev-parse HEAD)
  git status --short --branch
  "-- RECENT --"; git log --oneline --decorate -n $Recent
  "-- WORKTREES --"; git worktree list
  if ($Full) { "-- BRANCHES --"; git branch -vv --all }
} finally { Pop-Location }
