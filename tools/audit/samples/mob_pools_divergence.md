# Mob pool / species / detection divergence (PegasusXI vs LandSandBoat base)

## Summary by status

| status | count |
| --- | --- |
| changed | 2 |
| only_local | 1 |
| only_upstream | 1 |

## Divergent pools (top 4)

| poolid | name | status | changes | local_detects | upstream_detects |
| --- | --- | --- | --- | --- | --- |
| 100 | Goblin_Tinkerer | changed | aggro,links | SIGHT\|HEARING (0x03) [species 50] | SIGHT\|HEARING (0x03) [species 50] |
| 101 | River_Crab | changed | effective_detects | HEARING (0x02) [override (MOBMOD_DETECTION=2)] | SIGHT (0x01) [species 60] |
| 102 | Local_Only_Mob | only_local | (local-only pool) | NONE (0x00) [species 70] |  |
| 103 | Upstream_Only_Mob | only_upstream | (missing locally) |  | NONE (0x00) [species 80] |
