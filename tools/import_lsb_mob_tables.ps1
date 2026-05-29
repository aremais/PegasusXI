<#
.SYNOPSIS
    Imports LandSandBoat mob SQL dumps into xidb (or your configured SQL_DATABASE).

.DESCRIPTION
    Replaces mob-related tables with upstream LandSandBoat/server base branch dumps.
    Does not touch player/character tables. Stop xi_map and other xi_* processes first.

    Import order matches table dependencies (species -> pools -> spawns -> drops).

.PARAMETER LsbSqlPath
    Directory containing mob_*.sql and fishing_mob.sql (e.g. clone of LandSandBoat/server/sql).

.PARAMETER CloneFromGit
    Shallow-clone LandSandBoat/server base branch into -CloneDir when SQL files are missing.

.PARAMETER CloneDir
    Target directory for -CloneFromGit (default: sibling folder LandSandBoat-server-base).

.PARAMETER CopyToRepo
    Copy imported SQL files into this repo's sql/ folder before importing.

.PARAMETER Force
    Skip confirmation prompt.

.PARAMETER WhatIf
    List files that would be imported without connecting to MySQL.

.EXAMPLE
    .\tools\import_lsb_mob_tables.ps1 -CloneFromGit -Force

.EXAMPLE
    .\tools\import_lsb_mob_tables.ps1 -LsbSqlPath C:\src\LandSandBoat\server\sql
#>
[CmdletBinding()]
param(
    [string] $LsbSqlPath = '',
    [string] $CloneDir = '',
    [switch] $CloneFromGit,
    [switch] $CopyToRepo,
    [switch] $Force,
    [switch] $WhatIf,
    [string] $MysqlExe = '',
    [string] $SqlHost = '',
    [int]    $SqlPort = 0,
    [string] $SqlUser = '',
    [string] $SqlPassword = '',
    [string] $SqlDatabase = ''
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoSql  = Join-Path $repoRoot 'sql'

$LsbRepoUrl   = 'https://github.com/LandSandBoat/server.git'
$LsbBranch    = 'base'

# Dependency order for LandSandBoat base branch mob tables.
$MobSqlFiles = @(
    'mob_species_system.sql',
    'mob_pools.sql',
    'mob_pool_mods.sql',
    'mob_resistances.sql',
    'mob_skills.sql',
    'mob_skill_lists.sql',
    'mob_spell_lists.sql',
    'mob_groups.sql',
    'mob_spawn_slots.sql',
    'mob_spawn_points.sql',
    'mob_droplist.sql',
    'fishing_mob.sql',
    'mob_species_mods.sql'
)

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

function Resolve-MysqlExe {
    param([string] $Explicit)
    if ($Explicit -and (Test-Path -LiteralPath $Explicit)) { return $Explicit }
    $candidates = @(
        'C:\Program Files\MariaDB 11.4\bin\mysql.exe',
        'C:\Program Files\MariaDB 11.3\bin\mysql.exe',
        'C:\Program Files\MariaDB 10.11\bin\mysql.exe',
        'C:\Program Files\MariaDB 10.6\bin\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    $cmd = Get-Command mysql.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    throw 'mysql.exe not found. Pass -MysqlExe or install MariaDB/MySQL client.'
}

function Ensure-LsbSqlPath {
    param(
        [string] $SqlPath,
        [string] $CloneTarget,
        [switch] $DoClone
    )
    if (-not $SqlPath) {
        if ($CloneTarget) {
            $SqlPath = Join-Path $CloneTarget 'sql'
        } else {
            $SqlPath = Join-Path (Split-Path -Parent $repoRoot) 'LandSandBoat-server-base\sql'
        }
    }
    $SqlPath = [System.IO.Path]::GetFullPath($SqlPath)

    $missing = @()
    foreach ($name in $MobSqlFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $SqlPath $name))) {
            $missing += $name
        }
    }

    if ($missing.Count -eq 0) {
        return $SqlPath
    }

    if (-not $DoClone) {
        throw @(
            "Missing $($missing.Count) file(s) under: $SqlPath"
            ($missing -join ', ')
            'Use -CloneFromGit or -LsbSqlPath pointing at LandSandBoat/server/sql.'
        ) -join "`n"
    }

    if (-not $CloneTarget) {
        $CloneTarget = Join-Path (Split-Path -Parent $repoRoot) 'LandSandBoat-server-base'
    }
    $CloneTarget = [System.IO.Path]::GetFullPath($CloneTarget)

    function Invoke-Git {
        param([string[]] $Args)
        $prev = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            & git @Args 2>&1 | ForEach-Object { Write-Host $_ }
            if ($LASTEXITCODE -ne 0) { throw "git $($Args -join ' ') failed (exit $LASTEXITCODE)" }
        }
        finally {
            $ErrorActionPreference = $prev
        }
    }

    if (Test-Path -LiteralPath (Join-Path $CloneTarget '.git')) {
        Write-Host "Updating existing clone at $CloneTarget ..."
        Invoke-Git -Args @('-C', $CloneTarget, 'fetch', '--depth', '1', 'origin', $LsbBranch)
        Invoke-Git -Args @('-C', $CloneTarget, 'checkout', $LsbBranch)
        Invoke-Git -Args @('-C', $CloneTarget, 'reset', '--hard', "origin/$LsbBranch")
    } else {
        Write-Host "Cloning $LsbRepoUrl (branch $LsbBranch) to $CloneTarget ..."
        $parent = Split-Path -Parent $CloneTarget
        if ($parent -and -not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
        Invoke-Git -Args @('clone', '--depth', '1', '--branch', $LsbBranch, $LsbRepoUrl, $CloneTarget)
    }

    $SqlPath = Join-Path $CloneTarget 'sql'
    $stillMissing = @()
    foreach ($name in $MobSqlFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $SqlPath $name))) {
            $stillMissing += $name
        }
    }
    if ($stillMissing.Count -gt 0) {
        throw "Clone completed but still missing: $($stillMissing -join ', ')"
    }
    return $SqlPath
}

# --- resolve SQL source ---
if (-not $CloneDir) {
    $CloneDir = Join-Path (Split-Path -Parent $repoRoot) 'LandSandBoat-server-base'
}
$LsbSqlPath = Ensure-LsbSqlPath -SqlPath $LsbSqlPath -CloneTarget $CloneDir -DoClone:$CloneFromGit

Write-Host "LandSandBoat mob SQL source: $LsbSqlPath"

if ($CopyToRepo) {
    foreach ($name in $MobSqlFiles) {
        $src = Join-Path $LsbSqlPath $name
        $dst = Join-Path $repoSql $name
        Copy-Item -LiteralPath $src -Destination $dst -Force
        Write-Host "Copied $name -> sql/"
    }
}

$pathsToImport = foreach ($name in $MobSqlFiles) {
    if ($CopyToRepo) { Join-Path $repoSql $name } else { Join-Path $LsbSqlPath $name }
}

if ($WhatIf) {
    Write-Host 'WhatIf: would import these files (in order):'
    $i = 1
    foreach ($p in $pathsToImport) { Write-Host ("  {0,2}. {1}" -f $i++, $p) }
    return
}

if (-not $Force) {
    Write-Host ''
    Write-Host 'This will DROP and recreate mob tables in your database:'
    Write-Host "  Database: (from settings) -> see confirmation below"
    Write-Host "  Files:    $($MobSqlFiles.Count) SQL dumps from LandSandBoat base"
    Write-Host ''
    Write-Host 'Stop xi_map / xi_world / xi_connect before continuing.'
    $answer = Read-Host 'Proceed? [y/N]'
    if ($answer -notmatch '^[yY]') {
        Write-Host 'Cancelled.'
        return
    }
}

$networkLua = Join-Path $repoRoot 'settings\network.lua'
if (-not (Test-Path -LiteralPath $networkLua)) {
    $networkLua = Join-Path $repoRoot 'settings\default\network.lua'
}
if (-not (Test-Path -LiteralPath $networkLua)) {
    throw "Missing network.lua under settings/"
}

if (-not $SqlHost)      { $SqlHost      = Read-LuaNetworkString $networkLua 'SQL_HOST' }
if ($SqlPort -le 0)     { $SqlPort      = Read-LuaNetworkInt    $networkLua 'SQL_PORT' }
if (-not $SqlUser)      { $SqlUser      = Read-LuaNetworkString $networkLua 'SQL_LOGIN' }
if (-not $SqlPassword)  { $SqlPassword  = Read-LuaNetworkString $networkLua 'SQL_PASSWORD' }
if (-not $SqlDatabase)  { $SqlDatabase  = Read-LuaNetworkString $networkLua 'SQL_DATABASE' }

$MysqlExe = Resolve-MysqlExe -Explicit $MysqlExe

Write-Host "Importing into $SqlDatabase on ${SqlHost}:${SqlPort} ..."

$env:MYSQL_PWD = $SqlPassword
try {
    $n = 0
    foreach ($sqlFile in $pathsToImport) {
        $n++
        $base = Split-Path -Leaf $sqlFile
        Write-Host ("[{0}/{1}] {2} ..." -f $n, $pathsToImport.Count, $base) -NoNewline
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        Get-Content -LiteralPath $sqlFile -Raw -Encoding UTF8 |
            & $MysqlExe --protocol=TCP -h $SqlHost -P $SqlPort -u $SqlUser $SqlDatabase 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "mysql exited with code $LASTEXITCODE while importing $base"
        }
        $sw.Stop()
        Write-Host (" done ({0:N1}s)" -f $sw.Elapsed.TotalSeconds)
    }
}
finally {
    Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host 'Mob tables imported from LandSandBoat base.'
Write-Host 'Restart xi_map (and other zone processes) to load the new data.'
if (-not $CopyToRepo) {
    Write-Host 'Tip: re-run with -CopyToRepo to sync sql/ in this repo with the same dumps.'
}
