$root = Join-Path $PSScriptRoot "..\scripts\zones"
Get-ChildItem $root -Recurse -Filter "IDs.lua" | ForEach-Object {
    $c = [IO.File]::ReadAllText($_.FullName)
    $has6385 = $c -match 'ITEM_CANNOT_BE_OBTAINED\s*=\s*6385'
    $hasFull = $c -match 'FULL_INVENTORY_AFTER_TRADE'
    $has6393Item = $c -match 'ITEM_OBTAINED\s*=\s*6393'
    if ($has6385 -and -not $hasFull -and $has6393Item) {
        $_.FullName.Replace($root + "\", "")
    }
}
