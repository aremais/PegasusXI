# Pegasus Tunic Item Name Client Mod

Renames item **10293** from **Chocobo Shirt** to **Pegasus Tunic** in the FFXI client.

## Status

The patched DAT is not committed to this repository. CI sanity checks read changed files as UTF-8 text, and binary DAT files fail that check.

Distribute the patched DAT separately with the client pack or XIView/XIPivot overlay.

## What this changes

| Location | Old value | New value |
| --- | --- | --- |
| Item ID | 10293 | 10293 (unchanged) |
| English name | Chocobo Shirt | Pegasus Tunic |
| Japanese name | チョコボシャツ | ペガサスタニック |

Server-side renames are handled by:

- `sql/custom/rename_chocobo_shirt_to_pegasus_tunic.sql`
- `src/map/autotranslate.cpp` (autotranslate link text)

The client still reads inventory names and help text from local item DAT records, not from the server.

## Recommended tooling

Use [FFXIDat / FFXIDatProcessor](https://github.com/XiyanFlowC/FFXIDat) to extract, edit, and rebuild item records.

General workflow:

1. Back up your FFXI `ROM` folder.
2. Export item data from the item DAT files to CSV/Lua.
3. Find item ID **10293**.
4. Change the English name to `Pegasus Tunic`.
5. Change the Japanese name to `ペガサスタニック` if your client pack ships JP strings.
6. Rebuild the DAT and test in-game before distributing.

Item 10293 is body equipment. It lives in one of the armor/expansion item DAT files (not the general/usable tables). If you use FFXIDatProcessor's item export, search by ID rather than guessing the file.

## Autotranslate (optional client-side)

Chat autotranslate links for this item also exist in:

```text
ROM\168\25.DAT
```

The server already maps this entry to **Pegasus Tunic** in `src/map/autotranslate.cpp`. Patch `25.DAT` only if you want autotranslate links to show the new name before the server rewrites them, or for offline/client-only contexts.

## Install notes

This is not a server-side code change. It must ship with the client files or an XIView/XIPivot overlay.

Recommended install locations:

Direct client replacement:

```text
SquareEnix\FINAL FANTASY XI\ROM\<category>\<file>.DAT
```

XIView/XIPivot overlay replacement:

```text
polplugins\DATs\xiview\ROM\<category>\<file>.dat
```

If XIView is bundled with the client, patch the overlay copy too — it can override the base ROM file.

## Verification

1. Apply `sql/custom/rename_chocobo_shirt_to_pegasus_tunic.sql` on the live DB.
2. Restart map servers.
3. Install the patched client DAT.
4. Log in and check item 10293:
   - Inventory name shows **Pegasus Tunic**
   - Help text no longer says **Chocobo Shirt**
   - `//Pegasus Tunic` autotranslate works in chat
