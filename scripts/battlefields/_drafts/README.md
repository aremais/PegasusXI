# Battlefield drafts

Scripts here are **not loaded** at startup. `GetContainerFilenamesList()` only scans
`scripts/battlefields/<zone>/<file>.lua` (four path segments).

When a draft is ready to ship:

1. Confirm zone ID, entry/exit NPCs, mob pools, and phantom gems in `scripts/globals/htbf.lua`.
2. Uncomment the script body and `return content:register()`.
3. Move the file to `scripts/battlefields/<Zone_Name>/`.
