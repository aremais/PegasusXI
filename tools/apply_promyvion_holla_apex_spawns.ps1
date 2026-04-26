<#
.SYNOPSIS
    Applies tools/sql/promyvion_holla_floor1_apex_reposition.sql to MariaDB using the same defaults as settings/default/network.lua (overridable).

.EXAMPLE
    .\tools\apply_promyvion_holla_apex_spawns.ps1 -SqlPassword 'your_real_password'

.EXAMPLE
    .\tools\apply_promyvion_holla_apex_spawns.ps1 -SqlHost 127.0.0.1 -SqlUser root -SqlPassword '...' -SqlDatabase xidb
#>
[CmdletBinding()]
param(
    [string] $MysqlExe = '',
    [string] $SqlHost = '',
    [int]    $SqlPort = 0,
    [string] $SqlUser = '',
    [string] $SqlPassword = '',
    [string] $SqlDatabase = ''
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$sqlFile  = Join-Path $PSScriptRoot 'sql\promyvion_holla_floor1_apex_reposition.sql'

function Read-LuaNetworkString {
    param([string] $Path, [string] $Key)
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $m = [regex]::Match($raw, "$Key\s*=\s*'([^']*)'", [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if (-not $m.Success) { throw "Could not parse $Key from $Path" }
    return $m.Groups[1].Value
}

function Read-LuaNetworkInt {
    param([string] $Path, [string] $Key)
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $m = [regex]::Match($raw, "$Key\s*=\s*(\d+)", [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if (-not $m.Success) { throw "Could not parse $Key from $Path" }
    return [int]$m.Groups[1].Value
}

$networkLua = Join-Path $repoRoot 'settings\default\network.lua'
if (-not (Test-Path -LiteralPath $networkLua)) {
    throw "Missing $networkLua"
}
if (-not (Test-Path -LiteralPath $sqlFile)) {
    throw "Missing $sqlFile"
}

if (-not $SqlHost)     { $SqlHost     = Read-LuaNetworkString $networkLua 'SQL_HOST' }
if ($SqlPort -le 0)   { $SqlPort     = Read-LuaNetworkInt    $networkLua 'SQL_PORT' }
if (-not $SqlUser)    { $SqlUser    = Read-LuaNetworkString $networkLua 'SQL_LOGIN' }
if (-not $SqlPassword){ $SqlPassword = Read-LuaNetworkString $networkLua 'SQL_PASSWORD' }
if (-not $SqlDatabase){ $SqlDatabase = Read-LuaNetworkString $networkLua 'SQL_DATABASE' }

if (-not $MysqlExe) {
    $candidates = @(
        'C:\Program Files\MariaDB 11.4\bin\mysql.exe',
        'C:\Program Files\MariaDB 11.3\bin\mysql.exe',
        'C:\Program Files\MariaDB 10.11\bin\mysql.exe',
        'C:\Program Files\MariaDB 10.6\bin\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { $MysqlExe = $c; break }
    }
}
if (-not $MysqlExe) {
    $cmd = Get-Command mysql.exe -ErrorAction SilentlyContinue
    if ($cmd) { $MysqlExe = $cmd.Source }
}
if (-not $MysqlExe -or -not (Test-Path -LiteralPath $MysqlExe)) {
    throw 'mysql.exe not found. Install MariaDB client or pass -MysqlExe "C:\Path\to\mysql.exe"'
}

Write-Host "Using mysql: $MysqlExe"
Write-Host "Connecting: ${SqlUser}@${SqlHost}:${SqlPort} / database=$SqlDatabase"

# Avoid exposing password in process list where possible: pipe SQL via stdin; use MYSQL_PWD for this session only.
$env:MYSQL_PWD = $SqlPassword
try {
    $sqlText = Get-Content -LiteralPath $sqlFile -Raw -Encoding UTF8
    $sqlText | & $MysqlExe --protocol=TCP -h $SqlHost -P $SqlPort -u $SqlUser $SqlDatabase
    if ($LASTEXITCODE -ne 0) {
        throw "mysql exited with code $LASTEXITCODE"
    }
}
finally {
    Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
}

Write-Host 'Done. Restart xi_map so Promyvion-Holla reloads mob positions from the DB.'
