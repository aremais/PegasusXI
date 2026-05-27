# Stops LandSandBoat processes, runs DB recovery, optionally starts servers.
# Usage (from repo root):
#   .\tools\recover_server.ps1
#   .\tools\recover_server.ps1 -StartServers
#   .\tools\recover_server.ps1 -KeepAh
#   .\tools\recover_server.ps1 -WithIndexes

param(
    [string]$ServerPath = "D:\server",
    [switch]$StartServers,
    [switch]$KeepAh,
    [switch]$WithIndexes,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Set-Location $ServerPath

$exes = @("xi_map", "xi_connect", "xi_world", "xi_search")
Write-Host "Stopping server processes (if any) ..."
foreach ($name in $exes) {
    Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2

$pyArgs = @("tools\recover_server_db.py")
if ($KeepAh) { $pyArgs += "--keep-ah" }
if ($WithIndexes) { $pyArgs += "--with-indexes" }
if ($StartServers) { $pyArgs += "--start-servers" }
if ($Force) { $pyArgs += "--force" }

Write-Host "Running: python $($pyArgs -join ' ')"
python @pyArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Done. If you did not use -StartServers, start xi_connect, xi_world, xi_search, then xi_map (or use your watchdog)."
