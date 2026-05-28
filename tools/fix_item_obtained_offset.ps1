# Fixes ITEM_OBTAINED and related obtain-chain text IDs that are off by -2
# (using CANNOT+6 instead of the correct retail CANNOT+8 layout).
# Run: powershell -File tools/fix_item_obtained_offset.ps1
# Dry run: powershell -File tools/fix_item_obtained_offset.ps1 -WhatIf

param([switch]$WhatIf)

$zonesRoot = Join-Path $PSScriptRoot "..\scripts\zones"
$skipZones = @("Residential_Area")

# Obtain-chain keys shifted +2 when fixing CANNOT+6 layout.
$chainKeys = @(
    "ITEM_OBTAINED",
    "GIL_OBTAINED",
    "KEYITEM_OBTAINED",
    "KEYITEM_LOST",
    "NOT_HAVE_ENOUGH_GIL",
    "YOU_OBTAIN_ITEM",
    "YOU_OBTAIN",
    "ITEMS_OBTAINED"
)

# Pre-obtain keys only shifted when they sit at CANNOT+2 (compressed layout bug).
$preObtainKeys = @("FULL_INVENTORY_AFTER_TRADE", "CANNOT_OBTAIN_THE_ITEM", "ITEM_TOO_HEAVY")

function Parse-TextIds($content) {
    $text = @{}
    [regex]::Matches($content, '(\w+)\s*=\s*(\d+)\s*,\s*--') | ForEach-Object {
        $text[$_.Groups[1].Value] = [int]$_.Groups[2].Value
    }
    return $text
}

$fixed = @()
$alreadyOk = @()
$other = @()

Get-ChildItem $zonesRoot -Recurse -Filter "IDs.lua" | ForEach-Object {
    $zone = $_.Directory.Name
    if ($skipZones -contains $zone) { return }

    $path = $_.FullName
    $content = [IO.File]::ReadAllText($path)
    $text = Parse-TextIds $content

    if (-not $text.ContainsKey("ITEM_CANNOT_BE_OBTAINED") -or -not $text.ContainsKey("ITEM_OBTAINED")) { return }

    $cannot = $text["ITEM_CANNOT_BE_OBTAINED"]
    $item = $text["ITEM_OBTAINED"]
    $expected = $cannot + 8

    if ($item -eq $expected) {
        $script:alreadyOk += $zone
        return
    }

    if ($item -ne ($cannot + 6)) {
        $script:other += [pscustomobject]@{ Zone = $zone; Cannot = $cannot; Item = $item; Expected = $expected; Offset = ($item - $cannot) }
        return
    }

    # Needs fix: shift obtain chain +2
    $new = $content
    foreach ($key in $preObtainKeys) {
        if (-not $text.ContainsKey($key)) { continue }
        if ($text[$key] -ne ($cannot + 2)) { continue }
        $oldVal = $text[$key]
        $newVal = $oldVal + 2
        $pattern = "($key\s*=\s*)$oldVal(\s*,\s*--)"
        $new = [regex]::Replace($new, $pattern, "`${1}$newVal`${2}", 1)
    }
    foreach ($key in $chainKeys) {
        if (-not $text.ContainsKey($key)) { continue }
        $oldVal = $text[$key]
        $newVal = $oldVal + 2
        $pattern = "($key\s*=\s*)$oldVal(\s*,\s*--)"
        $new = [regex]::Replace($new, $pattern, "`${1}$newVal`${2}", 1)
    }

    if ($new -ne $content) {
        if (-not $WhatIf) {
            [IO.File]::WriteAllText($path, $new)
        }
        $script:fixed += [pscustomobject]@{ Zone = $zone; Cannot = $cannot; OldItem = $item; NewItem = $expected }
    }
}

Write-Host "=== Already correct (CANNOT+8): $($alreadyOk.Count) ==="
Write-Host "=== Fixed (CANNOT+6 -> CANNOT+8): $($fixed.Count) ==="
foreach ($f in ($fixed | Sort-Object Zone)) {
    Write-Host "  $($f.Zone): ITEM $($f.OldItem) -> $($f.NewItem)"
}
Write-Host "=== Other offsets (manual review): $($other.Count) ==="
foreach ($o in ($other | Sort-Object Zone)) {
    Write-Host "  $($o.Zone): CANNOT=$($o.Cannot) ITEM=$($o.Item) expected=$($o.Expected) (offset +$($o.Offset))"
}

if ($WhatIf) { Write-Host "(dry run - no files written)" }
