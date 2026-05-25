<#
.SYNOPSIS
    Re-imports sql/mob_pools.sql after speciesid fix (see tools/audit/fix_mob_pools_speciesid.py).
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
$sqlFile  = Join-Path $repoRoot 'sql\mob_pools.sql'

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

$networkLua = Join-Path $repoRoot 'settings\network.lua'
if (-not (Test-Path -LiteralPath $networkLua)) {
    $networkLua = Join-Path $repoRoot 'settings\default\network.lua'
}
if (-not (Test-Path -LiteralPath $sqlFile)) { throw "Missing $sqlFile" }

if (-not $SqlHost)      { $SqlHost      = Read-LuaNetworkString $networkLua 'SQL_HOST' }
if ($SqlPort -le 0)    { $SqlPort      = Read-LuaNetworkInt    $networkLua 'SQL_PORT' }
if (-not $SqlUser)     { $SqlUser     = Read-LuaNetworkString $networkLua 'SQL_LOGIN' }
if (-not $SqlPassword) { $SqlPassword = Read-LuaNetworkString $networkLua 'SQL_PASSWORD' }
if (-not $SqlDatabase) { $SqlDatabase = Read-LuaNetworkString $networkLua 'SQL_DATABASE' }

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
    throw 'mysql.exe not found.'
}

Write-Host "Importing mob_pools.sql into $SqlDatabase on ${SqlHost}:${SqlPort} ..."
$env:MYSQL_PWD = $SqlPassword
try {
    Get-Content -LiteralPath $sqlFile -Raw -Encoding UTF8 |
        & $MysqlExe --protocol=TCP -h $SqlHost -P $SqlPort -u $SqlUser $SqlDatabase
    if ($LASTEXITCODE -ne 0) { throw "mysql exited with code $LASTEXITCODE" }
}
finally {
    Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
}

Write-Host 'Done. Restart xi_map (and any zone processes) to load corrected mob species data.'
