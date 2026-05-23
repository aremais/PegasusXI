# PegasusXI vs LandSandBoat Audit Tooling

Phase 1 of the broader retail/reference audit effort tracked in PRs #198/#199.
This directory contains **read-only** tools that diff PegasusXI SQL dumps
against upstream LandSandBoat `base` and produce CSV + Markdown reports
describing every divergence in mob behavior, detection, and drops.

**This PR does not change any mob data.** It only adds tooling.

---

## What the tools do

### `audit mob_pools`

Compares each `mob_pools` row between local and upstream, plus the effective
`detects` bitmask resolved through `mob_species_system` and the
`MOBMOD_DETECTION` (mod id 16) override in `mob_pool_mods`. Fields compared:

- `speciesid`, `behavior`, `aggro`, `true_detection`, `links`
- `mobType`, `immunity`, `flag`, `entityFlags`, `roamflag`
- `spellList`, `skill_list_id`, `resist_id`
- effective detection bitmask (species default OR per-pool override)

Output: `mob_pools_divergence.csv` and `mob_pools_divergence.md`.

### `audit drops`

Compares each `(dropId, groupId, itemId)` slot in `mob_droplist` between
local and upstream. Resolves:

- `dropId` → mob name(s) via `mob_groups.dropid` ↦ `mob_pools.name`
- `itemId` → item name via `item_basic.name`

Fields compared: `dropType`, `groupRate`, `itemRate`. Note that the upstream
dump uses SQL variables (`@COMMON`, `@VRARE`, `@UNCOMMON`, …) for itemRate,
so divergences against PegasusXI's numeric rates are expected and are the
single largest signal: they tell you where PegasusXI deviates from
upstream's rate macros.

### `audit self-check`

Runs both audits against tiny bundled SQL fixtures in
`tools/audit/tests/fixtures/`. Exits 0 on the expected number of
divergences and 1 otherwise. Suitable for CI (no MySQL, no network).

---

## Usage

```bash
# Live run: fetches upstream LSB base SQL (~9 MB) into tools/audit/cache/, then diffs.
python3 -m tools.audit pools --output tools/audit/reports
python3 -m tools.audit drops --output tools/audit/reports

# Limit number of divergent rows in the output (for spot-checking):
python3 -m tools.audit pools --limit 100

# Offline / CI mode: requires a pre-populated tools/audit/cache/<branch>/ dir.
python3 -m tools.audit pools --no-fetch

# Point at an explicit upstream SQL checkout instead of fetching:
python3 -m tools.audit pools --upstream-sql /path/to/LandSandBoat/server/sql

# Deterministic dry-run for CI:
python3 -m tools.audit self-check
```

Tests:

```bash
python3 -m pytest tools/audit/tests/ -v
```

---

## What the reports do and do not prove

**They prove:** that PegasusXI has diverged from upstream LandSandBoat
`base` in the listed rows. The CSVs are deterministic and can be regenerated
on demand from SQL files alone.

**They do not prove:**

- Whether PegasusXI's value or upstream's value is correct relative to
  *retail FFXI*. Both sides may be wrong; both sides may be right for
  different content windows. Era/retail validation requires the references
  in §3 below.
- Whether the divergence is intentional. Many PegasusXI changes are
  deliberate (e.g. custom NMs, server-specific events, the 28 speciesid
  fixes in PR #199). The audit will flag them all the same.
- Anything about runtime aggro behavior beyond what's in the SQL tables. C++
  / Lua overrides (`onMobInitialize`, `setMod`, mixins) are not parsed.

Treat the reports as a **candidate list for human review**, not a list of
bugs.

---

## Sources and references

Methodology basis: `pegasusxi-validation-plan.pplx.md` (research report,
external).

### Upstream baseline

- LandSandBoat server, `base` branch:
  <https://github.com/LandSandBoat/server>
- Raw SQL: `https://raw.githubusercontent.com/LandSandBoat/server/base/sql/<name>`

### Bitmask definitions

- `DETECT` enum: `src/map/entities/mobentity.h` in LSB
- `MOBMOD_DETECTION = 16` and friends: `src/map/mob_modifier.h` in LSB

### Retail / reference data (not consumed yet — see Phase 2 below)

- BG Wiki: <https://www.bg-wiki.com/ffxi/> — MediaWiki API at
  `/ffxi/api.php` (Cloudflare-protected on the HTML pages, but the API is
  usable for raw wikitext extraction).
- FFXIclopedia: <https://ffxiclopedia.fandom.com/> — standard Fandom
  MediaWiki API.
- FFXIDB: <http://www.ffxidb.com/> — Guildwork empirical kill data, last
  freeze February 2015, TH-stratified drop rates.

Confidence levels of these sources for aggro/detection are HIGH; for drop
rates MEDIUM-LOW (sample sizes, no TH controls).

---

## Phase 2 (next, not in this PR)

Hooks the current code is structured to accept:

1. **Reference fetchers** alongside `upstream.py`:
   - `bgwiki.py` — pull per-mob wikitext via the BG Wiki MediaWiki API,
     parse zone-table detection codes (`A`, `L`, `S`, `H`, `M`, `T`, …)
     and family infoboxes.
   - `ffxiclopedia.py` — same, against Fandom.
   - `ffxidb.py` — scrape per-zone HTML pages for TH-stratified drop rates.
2. **Reference-aware report columns**: extend `audit_mob_pools.py` to add
   `bgwiki_detects`, `ffxiclopedia_detects`, `bgwiki_family`, etc.,
   flagging rows where PegasusXI agrees with neither LSB nor retail
   references.
3. **Confidence scoring** per row: agreement among (PegasusXI, LSB, BG
   Wiki, FFXIclopedia, FFXIDB) collapses to a small confidence bucket so
   reviewers can triage the most ambiguous rows first.
4. **Targeted patch generation**: only after reviewers have approved a
   batch of corrections, emit a focused SQL migration scoped to that batch
   — never a mass-update.

Nothing in this PR ships any retail-reference ingestion or any data
mutation: all of that is deferred to phase 2 so it can be reviewed
incrementally.

---

## Layout

```
tools/audit/
├── README.md              ← this file
├── __init__.py
├── __main__.py            ← `python -m tools.audit <subcommand>`
├── sql_parser.py          ← INSERT-tuple parser; preserves @VARS, 0xHEX, NULL
├── schemas.py             ← column orders + DETECT bitmask decoder
├── diff_utils.py          ← CSV / Markdown writers
├── upstream.py            ← fetch & cache raw.githubusercontent.com LSB SQL
├── audit_mob_pools.py     ← pool/species/detection audit
├── audit_drops.py         ← droplist audit
├── self_check.py          ← deterministic fixture-driven run
├── samples/               ← committed sample outputs from self-check
├── cache/                 ← gitignored; populated on first live run
├── reports/               ← gitignored; default --output destination
└── tests/
    ├── test_audit.py
    └── fixtures/
        ├── local/
        └── upstream/
```
