#Requires -Version 5.1
<#
.SYNOPSIS
  Applies (optional) and verifies Amchuchu trust weapon-skill rows from sql/local/.

.NOTES
  Non-interactive mode requires -Password (piping SQL on stdin conflicts with mysql password prompt).

.EXAMPLE
  .\Invoke-AmchuchuTrustDbCheck.ps1 -User root -Password 'yourpass' -Database xidb -ApplyPatch

.NOTES
  Default -Database is xidb (matches xi.settings.network.SQL_DATABASE in this repo). Use -ListDatabases if unsure.
#>
param(
    [string] $MySql = 'mysql',
    [Parameter(Mandatory = $true)]
    [string] $User,
    [string] $Password,
    [string] $Database = 'xidb',
    [string] $HostName = '127.0.0.1',
    [int] $Port = 3306,
    [switch] $ApplyPatch,
    [switch] $ListDatabases
)

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$sqlLocal = Join-Path $repoRoot 'sql\local'
$patch = Join-Path $sqlLocal 'patch_amchuchu_trust_weapon_skills.sql'
$verify = Join-Path $sqlLocal 'verify_amchuchu_trust_weapon_skills.sql'

if (-not (Test-Path $patch) -or -not (Test-Path $verify)) {
    throw "Missing sql/local files under: $sqlLocal"
}

if (-not $Password) {
    Write-Host @"
No -Password given (avoiding stdin conflict with mysql -p prompt).

Run manually (use your real schema name, e.g. xidb — see settings/network.lua SQL_DATABASE):
  mysql -h $HostName -P $Port -u $User -p $Database --default-character-set=utf8mb4 < `"$patch`"
  mysql -h $HostName -P $Port -u $User -p $Database --default-character-set=utf8mb4 < `"$verify`"

Or re-run with -Password '...' for automated apply/verify.
"@
    exit 0
}

function Get-MysqlBaseArgs {
    return @(
        '-h', $HostName,
        '-P', "$Port",
        '-u', $User,
        "-p$Password",
        '--default-character-set=utf8mb4'
    )
}

if ($ListDatabases) {
    Write-Host "SHOW DATABASES (pick the one that matches your map SQL_DATABASE):"
    & $MySql @(Get-MysqlBaseArgs) '-e', 'SHOW DATABASES;'
    if ($LASTEXITCODE -ne 0) { throw "mysql SHOW DATABASES failed (exit $LASTEXITCODE)" }
    exit 0
}

function Invoke-MysqlSqlFile {
    param([string] $SqlPath)
    $args = @(Get-MysqlBaseArgs) + @($Database)
    Get-Content -LiteralPath $SqlPath -Raw -Encoding UTF8 | & $MySql @args
    if ($LASTEXITCODE -ne 0) {
        throw "mysql failed (exit $LASTEXITCODE) for: $SqlPath. Wrong schema (e.g. ERROR 1049)? Use -ListDatabases or -Database matching settings/network.lua SQL_DATABASE."
    }
}

if ($ApplyPatch) {
    Write-Host "Applying: $patch"
    Invoke-MysqlSqlFile -SqlPath $patch
}

Write-Host "Verifying: $verify"
Invoke-MysqlSqlFile -SqlPath $verify
Write-Host "Expect: skill_list_id 1084 on pool 5969; mob_skill 49,54,61; weapon_skills 49,54,61."
