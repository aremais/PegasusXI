# Fixes only proven broken relative chains (safe, no offset guessing).
$root = Join-Path $PSScriptRoot "..\scripts\zones"
$fixed = 0

Get-ChildItem $root -Recurse -Filter "IDs.lua" | ForEach-Object {
    $path = $_.FullName
    $content = [IO.File]::ReadAllText($path)
    $new = $content

    if ($content -match 'KEYITEM_OBTAINED\s*=\s*6394' -and $content -match 'KEYITEM_LOST\s*=\s*6397') {
        $new = [regex]::Replace($new, '(KEYITEM_LOST\s*=\s*)6397', '${1}6395', 1)
    }

    if ($content -match 'KEYITEM_OBTAINED\s*=\s*6394' -and $content -match 'NOT_HAVE_ENOUGH_GIL\s*=\s*6398') {
        $new = [regex]::Replace($new, '(NOT_HAVE_ENOUGH_GIL\s*=\s*)6398', '${1}6396', 1)
    }

    if ($content -match 'ITEM_OBTAINED\s*=\s*6391' -and $content -match 'GIL_OBTAINED\s*=\s*6393') {
        $new = [regex]::Replace($new, '(GIL_OBTAINED\s*=\s*)6393', '${1}6392', 1)
    }

    # Port San d'Oria: shifted obtain block; NOT_HAVE must follow KEY (6438+2=6440)
    if ($_.Directory.Name -eq 'Port_San_dOria' -and $content -match 'KEYITEM_OBTAINED\s*=\s*6438' -and $content -match 'NOT_HAVE_ENOUGH_GIL\s*=\s*6396') {
        $new = [regex]::Replace($new, '(NOT_HAVE_ENOUGH_GIL\s*=\s*)6396', '${1}6440', 1)
    }

    if ($new -ne $content) {
        [IO.File]::WriteAllText($path, $new)
        $script:fixed++
        Write-Host "Fixed: $($_.Directory.Name)"
    }
}

Write-Host "Total files fixed: $fixed"
