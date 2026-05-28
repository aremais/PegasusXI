# Audits all scripts/zones/*/IDs.lua obtain-message text IDs.
# Run: powershell -File tools/audit_zone_text_ids.ps1
# Safe fixes: powershell -File tools/fix_broken_obtain_chains.ps1

param(
    [string]$ReportPath = ""
)

$zonesRoot = Join-Path $PSScriptRoot "..\scripts\zones"
if (-not $ReportPath) { $ReportPath = Join-Path $PSScriptRoot "zone_text_id_audit_report.txt" }
$skipZones = @("Residential_Area")

function Parse-TextIds($content) {
    $text = @{}
    [regex]::Matches($content, '(\w+)\s*=\s*(\d+)\s*,\s*--') | ForEach-Object {
        $text[$_.Groups[1].Value] = [int]$_.Groups[2].Value
    }
    return $text
}

function Get-ChainIssues($text) {
    $issues = @()
    if (-not $text.ContainsKey("ITEM_OBTAINED") -or $text["ITEM_OBTAINED"] -eq 0) { return $issues }

    $item = $text["ITEM_OBTAINED"]
    if ($text.ContainsKey("GIL_OBTAINED") -and $text["GIL_OBTAINED"] -ne ($item + 1)) {
        $issues += "GIL_OBTAINED=$($text['GIL_OBTAINED']) expected $($item+1)"
    }
    if ($text.ContainsKey("GIL_OBTAINED") -and $text.ContainsKey("KEYITEM_OBTAINED") -and $text["KEYITEM_OBTAINED"] -ne ($text["GIL_OBTAINED"] + 2)) {
        $issues += "KEYITEM_OBTAINED=$($text['KEYITEM_OBTAINED']) expected $($text['GIL_OBTAINED']+2)"
    }
    if ($text.ContainsKey("KEYITEM_OBTAINED") -and $text.ContainsKey("KEYITEM_LOST") -and $text["KEYITEM_LOST"] -ne ($text["KEYITEM_OBTAINED"] + 1)) {
        $issues += "KEYITEM_LOST=$($text['KEYITEM_LOST']) expected $($text['KEYITEM_OBTAINED']+1)"
    }
    if ($text.ContainsKey("KEYITEM_OBTAINED") -and $text.ContainsKey("NOT_HAVE_ENOUGH_GIL") -and $text["NOT_HAVE_ENOUGH_GIL"] -ne ($text["KEYITEM_OBTAINED"] + 2)) {
        $issues += "NOT_HAVE_ENOUGH_GIL=$($text['NOT_HAVE_ENOUGH_GIL']) expected $($text['KEYITEM_OBTAINED']+2)"
    }
    if ($text.ContainsKey("ITEMS_OBTAINED") -and $text["ITEMS_OBTAINED"] -ne ($item + 9)) {
        $issues += "ITEMS_OBTAINED=$($text['ITEMS_OBTAINED']) expected $($item+9)"
    }
    if ($text.ContainsKey("GIL_OBTAINED") -and $item -eq $text["GIL_OBTAINED"]) {
        $issues += "CRITICAL: ITEM_OBTAINED equals GIL_OBTAINED"
    }
    if ($text.ContainsKey("ITEM_CANNOT_BE_OBTAINED") -and $text["ITEM_CANNOT_BE_OBTAINED"] -eq 6385 -and -not $text.ContainsKey("FULL_INVENTORY_AFTER_TRADE")) {
        if ($item -lt 6393) {
            $issues += "CRITICAL: compact zone (6385) ITEM_OBTAINED=$item (expect 6393 = CANNOT+8)"
        }
    }
    return $issues
}

function Get-OffsetWarnings($text) {
    $warn = @()
    if (-not $text.ContainsKey("ITEM_CANNOT_BE_OBTAINED") -or -not $text.ContainsKey("ITEM_OBTAINED")) { return $warn }

    $cannot = $text["ITEM_CANNOT_BE_OBTAINED"]
    $hasFull = $text.ContainsKey("FULL_INVENTORY_AFTER_TRADE")
    $item = $text["ITEM_OBTAINED"]

    if ($hasFull -and $text["FULL_INVENTORY_AFTER_TRADE"] -ne ($cannot + 4)) {
        $warn += "FULL_INVENTORY=$($text['FULL_INVENTORY_AFTER_TRADE']) expected $($cannot+4)"
    }

    $expectedItem = $cannot + 8
    if ($item -ne $expectedItem) {
        $layout = if ($hasFull) { "A" } else { "B" }
        $warn += "ITEM_OBTAINED=$item expected $expectedItem (CANNOT+8, layout $layout)"
    }
    return $warn
}

$errors = @()
$warnings = @()
$scanned = 0

Get-ChildItem $zonesRoot -Recurse -Filter "IDs.lua" | ForEach-Object {
    $scanned++
    $zone = $_.Directory.Name
    if ($skipZones -contains $zone) { return }

    $text = Parse-TextIds ([IO.File]::ReadAllText($_.FullName))
    $chain = Get-ChainIssues $text
    $offset = Get-OffsetWarnings $text

    if ($chain.Count -gt 0) {
        $errors += [pscustomobject]@{ Zone = $zone; Detail = ($chain -join "; ") }
    }
    if ($offset.Count -gt 0) {
        $warnings += [pscustomobject]@{ Zone = $zone; Detail = ($offset -join "; ") }
    }
}

$lines = @(
    "Zone Text ID Audit",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "Zones scanned: $scanned",
    "",
    "=== ERRORS (broken chains / gil-template bug) ===",
    "Count: $($errors.Count)"
)
if ($errors.Count -eq 0) { $lines += "  (none)" }
else { foreach ($e in ($errors | Sort-Object Zone)) { $lines += "  $($e.Zone): $($e.Detail)" } }

$lines += ""
$lines += "=== WARNINGS (offset vs CANNOT; many zones use +8 without FULL in Lua) ==="
$lines += "Count: $($warnings.Count)"
if ($warnings.Count -eq 0) { $lines += "  (none)" }
else { foreach ($w in ($warnings | Sort-Object Zone)) { $lines += "  $($w.Zone): $($w.Detail)" } }

$lines += ""
$lines += "Relative chain rules (errors):"
$lines += "  GIL = ITEM+1, KEY = GIL+2, KEY_LOST = KEY+1, NOT_HAVE_GIL = KEY+2, ITEMS = ITEM+9"
$lines += ""
$lines += "Safe fix script: tools/fix_broken_obtain_chains.ps1"

$lines | Set-Content $ReportPath -Encoding UTF8
Write-Host "Report: $ReportPath"
Write-Host "Errors: $($errors.Count), Warnings: $($warnings.Count)"
