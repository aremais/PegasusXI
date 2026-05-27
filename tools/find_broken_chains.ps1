# Finds zones where obtain message IDs break the relative chain (real runtime bugs).
$root = Join-Path $PSScriptRoot "..\scripts\zones"
$skip = @("Residential_Area")

function Parse($content) {
    $t = @{}
    [regex]::Matches($content, '(\w+)\s*=\s*(\d+)\s*,\s*--') | ForEach-Object { $t[$_.Groups[1].Value] = [int]$_.Groups[2].Value }
    return $t
}

$broken = @()
Get-ChildItem $root -Recurse -Filter "IDs.lua" | ForEach-Object {
    $zone = $_.Directory.Name
    if ($skip -contains $zone) { return }
    $t = Parse ([IO.File]::ReadAllText($_.FullName))
    if (-not $t["ITEM_OBTAINED"] -or $t["ITEM_OBTAINED"] -eq 0) { return }

    $issues = @()
    if ($t["GIL_OBTAINED"] -and $t["GIL_OBTAINED"] -ne ($t["ITEM_OBTAINED"] + 1)) {
        $issues += "GIL=$($t['GIL_OBTAINED']) want $($t['ITEM_OBTAINED']+1)"
    }
    if ($t["GIL_OBTAINED"] -and $t["KEYITEM_OBTAINED"] -and $t["KEYITEM_OBTAINED"] -ne ($t["GIL_OBTAINED"] + 2)) {
        $issues += "KEY=$($t['KEYITEM_OBTAINED']) want $($t['GIL_OBTAINED']+2)"
    }
    if ($t["KEYITEM_OBTAINED"] -and $t["KEYITEM_LOST"] -and $t["KEYITEM_LOST"] -ne ($t["KEYITEM_OBTAINED"] + 1)) {
        $issues += "KEY_LOST=$($t['KEYITEM_LOST']) want $($t['KEYITEM_OBTAINED']+1)"
    }
    if ($t["KEYITEM_OBTAINED"] -and $t["NOT_HAVE_ENOUGH_GIL"] -and $t["NOT_HAVE_ENOUGH_GIL"] -ne ($t["KEYITEM_OBTAINED"] + 2)) {
        $issues += "NO_GIL=$($t['NOT_HAVE_ENOUGH_GIL']) want $($t['KEYITEM_OBTAINED']+2)"
    }
    if ($t["ITEMS_OBTAINED"] -and $t["ITEMS_OBTAINED"] -ne ($t["ITEM_OBTAINED"] + 9)) {
        $issues += "ITEMS=$($t['ITEMS_OBTAINED']) want $($t['ITEM_OBTAINED']+9)"
    }
    if ($t["ITEM_OBTAINED"] -eq $t["GIL_OBTAINED"]) {
        $issues += "ITEM==GIL"
    }

    # Classic gil-template bug: compact 6385 zone using city item slot
    if ($t["ITEM_CANNOT_BE_OBTAINED"] -eq 6385 -and -not $t["FULL_INVENTORY_AFTER_TRADE"]) {
        if ($t["ITEM_OBTAINED"] -ge 6393) { $issues += "CRITICAL compact uses ITEM $($t['ITEM_OBTAINED']) (expect 6391)" }
    }

    if ($issues.Count -gt 0) {
        $broken += [pscustomobject]@{ Zone = $zone; Issues = ($issues -join "; ") }
    }
}

Write-Host "Broken chains: $($broken.Count)"
$broken | Sort-Object Zone | ForEach-Object { Write-Host "$($_.Zone): $($_.Issues)" }
