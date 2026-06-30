# Mob Pool Species ID Audit

Generated: 2026-06-26 23:48 UTC
Compared: `mob_pools.sql` vs `upstream/base:sql/mob_pools.sql`

## Executive summary

Species IDs in `mob_pools` drive crystal drops (via `mob_species_system.Element`),
family stats, ecosystem, charmability, and detection. Item drops use separate
`mob_groups.dropid` tables and were not part of this audit.

| Metric | Count |
| --- | ---: |
| Local mob pools | 7,272 |
| Upstream mob pools | 8,081 |
| Shared pool IDs | 7,193 |
| **Species ID mismatches** | **0** |
| Pools matching upstream | 7,193 |
| Mismatches with crystal element change | 0 |
| Local-only pools (no upstream row) | 79 |
| Upstream-only pools (missing locally) | 888 |

**0.0%** of shared pools have incorrect species IDs.

## Report files

| File | Description |
| --- | --- |
| `tools\reports\species_audit_mismatches.csv` | All 0 mismatched pools with local vs upstream species/crystal |
| `tools\reports\species_audit_local_only.csv` | 79 custom/local pools without upstream reference |
| `tools\reports\species_audit_by_zone.csv` | Mismatch counts grouped by zone |

## Most common incorrect local species IDs

These species IDs appear most often where upstream expects something else —
likely systematic column corruption rather than random drift.

| Count | Local speciesID | Local species name |
| ---: | ---: | --- |

## Zones with the most mismatched spawn pools

| Zone | Mismatched pools | Matching pools |
| --- | ---: | ---: |

## Recommended next steps

1. Review `species_audit_local_only.csv` for intentional custom content before bulk-fixing.
2. Bulk-fix the ~0 upstream-backed mismatches (scripted UPDATE from upstream values).
3. Restart all `xi_map` processes after DB/SQL changes.
4. Spot-check crystal drops in a few signet regions (Gustaberg, Ronfaure, Saruta).
5. Run separately: `python tools/fix_mob_aggro_data.py` if resist_id/detection issues remain.

## Already fixed

South Gustaberg (zone 107): 46 pools corrected via `tools/fix_south_gustaberg_species.py`.
Those pools should show as matching upstream if re-audited in isolation.
