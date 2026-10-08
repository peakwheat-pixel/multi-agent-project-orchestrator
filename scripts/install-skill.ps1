param([string]$Destination=(Join-Path $HOME ".codex\skills\multi-agent-project-orchestrator"),[switch]$NoBackup)
$ErrorActionPreference="Stop"
$Source=Split-Path -Parent $PSScriptRoot
if (Test-Path $Destination) {
  if (-not $NoBackup) {
    $backup="$Destination.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Copy-Item $Destination $backup -Recurse
    Write-Host "Backup: $backup"
  }
  Remove-Item $Destination -Recurse -Force
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
Copy-Item $Source $Destination -Recurse
Write-Host "Installed: $Destination"
