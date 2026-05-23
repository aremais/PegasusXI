# PegasusXI vs LandSandBoat Audit Tooling

Phase 1 (#200) of the broader retail/reference audit effort tracked in PRs
#198/#199 added the SQL-diff harness. Phase 2 (this revision) layers in
**reference-aware** lookups against BG Wiki, FFXIclopedia, and FFXIDB so each
row of the divergence report can be triaged against retail/community data.

**This PR still does not change any mob data.** It only adds tooling, tests,
and tiny fixture-driven sample outputs. Reports are review queues, not
automatic patches.

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

# Reference-aware (phase 2): add BG Wiki + FFXIclopedia detection columns.
# Names-file scopes the live wiki lookups to a hand-picked subset.
python3 -m tools.audit pools --with-refs --names-file mobs.txt

# Reference-aware drops: pass --zone-map (LSB->FFXIDB) and a TODO output
# path; rows whose mapping is missing land in the TODO file instead of
# being silently skipped.
python3 -m tools.audit drops --with-refs \
    --zone-map tools/audit/zone_map.json \
    --ffxidb-todo tools/audit/reports/ffxidb_todo.csv \
    --names-file mobs.txt

# Fully offline reference run (CI / hermetic): cache must be pre-populated.
AUDIT_OFFLINE=1 python3 -m tools.audit pools --with-refs --no-fetch
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

## Phase 2 (this revision)

What landed in phase 2 — wired into the CLI behind `--with-refs`:

### Reference fetchers (`tools/audit/refs/`)

- `http_client.py` — shared cached HTTP client. Cache layout is
  `tools/audit/cache/refs/<source>/<sha1>.body` plus a sibling `.meta`
  JSON. Includes timeout, per-source rate limit (default 1s), bounded
  retries with exponential backoff, polite `User-Agent`, and an offline
  mode (`allow_fetch=False` or `AUDIT_OFFLINE=1`) that turns any cache miss
  into a clearly-labelled `OfflineCacheMiss` instead of going to the
  network. CI uses offline mode.
- `bgwiki.py` — pulls per-mob wikitext via the BG Wiki MediaWiki API
  (`https://www.bg-wiki.com/ffxi/api.php`, `action=query&prop=revisions`).
  HTML pages are Cloudflare-gated, but the API endpoint is open. Returns a
  `WikiPage` with a `detection()` and `drop_rates()` helper.
- `ffxiclopedia.py` — same shape, against Fandom
  (`https://ffxiclopedia.fandom.com/api.php`). Uses its own cache namespace.
- `ffxidb.py` — parses FFXIDB drop-table HTML
  (`http://www.ffxidb.com/zones/{zone_id}/{mob_slug}`) using stdlib
  `html.parser`. Includes a `slugify(name)` helper and a `ZoneMap` for the
  LSB→FFXIDB zoneid mapping that does not exist mechanically. Any lookup
  that can't be resolved (missing zone mapping, page returns no drop
  table) is appended to a `--ffxidb-todo` CSV instead of silently
  skipped.
- `wikitext.py` — robust parser for detection note codes
  (`A`, `L`, `S`, `H`, `M`, `HP`, `T`, `Sc`, plus full-word variants and
  `WS`/`JA`/`Ability` for ability-class detection) and
  `{{Drop Rate|drops|kills}}` templates. Returns a `DetectionParse` with
  an explicit `confidence` field; if the input is ambiguous (meta flags
  `A/L/TS/TH` only, no sense type) the bitmask comes back as `None`
  rather than being silently downgraded to `DETECT_NONE`.
- `confidence.py` — kill-count bucket thresholds
  (`high>=500, medium>=50, low>0, else none`) and an agreement-bucket
  helper for cross-source detection comparisons.

### CLI

- `python3 -m tools.audit pools --with-refs [--no-fetch] [--names-file FILE]`
  adds `bgwiki_detects`, `bgwiki_confidence`, `bgwiki_url`,
  `ffxiclopedia_detects`, `ffxiclopedia_confidence`,
  `ffxiclopedia_url`, `ref_agreement`, `ref_headline_confidence` columns
  to the pool CSV. The Markdown summary adds three columns
  (`bgwiki_detects`, `ffxiclopedia_detects`, `ref_agreement`).
- `python3 -m tools.audit drops --with-refs [--no-fetch] [--zone-map JSON] [--ffxidb-todo CSV] [--names-file FILE]`
  adds `ffxidb_avg_pct`, `ffxidb_th0_pct`, `ffxidb_th1_pct`,
  `ffxidb_th2_pct`, `ffxidb_th3_pct`, `ffxidb_kills`,
  `ffxidb_confidence`, `ffxidb_url`, `bgwiki_drop_pct`, `bgwiki_kills`,
  `bgwiki_confidence`, `bgwiki_url` columns.

### Tests

`tools/audit/tests/test_refs.py` — 19 new tests covering confidence
buckets, detection cell parsing, wiki-link / template formatting,
drop-rate template extraction, the HTTP client's cache + offline
contract, BG Wiki / FFXIclopedia / FFXIDB client behavior against
staged cache entries, FFXIDB slug rules, the zone-map TODO mechanism,
and an end-to-end `audit pools --with-refs` run against the bundled
fixtures. Network is **never** touched; the suite stays deterministic.

### Sample reference-aware output

`tools/audit/samples/mob_pools_divergence_refs.{csv,md}` and
`tools/audit/samples/mob_droplist_divergence_refs.{csv,md}` are
regenerated by `tools/audit/samples/generate_refs_sample.py` from the
test fixtures (offline, hermetic). They illustrate what the
`--with-refs` columns look like without requiring a live fetch.

### Confidence scoring

Each ref-aware row carries one or more confidence buckets:

| Bucket | Meaning |
| --- | --- |
| `high` | Either ≥500 empirical kills (FFXIDB / wiki) **or** ≥3 independent sources agree on the same detection bitmask. |
| `medium` | ≥50 empirical kills, or 2 sources agree. |
| `low` | <50 kills, or only meta flags (`A`/`L`/`TS`/`TH`) without a sense type. |
| `none` | No reference data available. |

These mirror the methodology report
(`pegasusxi-validation-plan.pplx.md`, section 6).

## What still requires a human

1. **LSB→FFXIDB zone mapping.** FFXIDB's zone IDs are its own; we don't
   guess. Build the mapping incrementally and pass it via `--zone-map
   path/to/zone_map.json` — entries you haven't filled in show up in the
   `--ffxidb-todo` CSV. The shape of `zone_map.json` is `{"lsb_zoneid":
   ffxidb_zoneid, ...}` (string keys, integer values).
2. **Name normalisation.** PegasusXI mob names use underscores
   (`Goblin_Tinkerer`); wikis use spaces. The CLI handles the obvious
   `_ → space` swap, but apostrophes, accents, and " (Family)"
   suffixes still vary across sources. Use `--names-file` to scope
   lookups to a hand-curated subset until ergonomics improve.
3. **Drop rate semantics.** LSB's `itemRate` is `0-1000` (i.e.
   thousandths); FFXIDB reports percentages. Compare
   `itemRate / 10 == ffxidb_th0_pct` as the canonical check. FFXIDB
   averages bake in `groupRate`; wiki drop rates do not.
4. **Data age.** FFXIDB freezes at the Feb 2015 patch. For any
   post-2015 content (Adoulin, Rhapsodies, Ambuscade) FFXIDB will be
   silent — fall back to the wikis.

## Future phases

- **Phase 3 (not in this PR).** Reviewer-driven small-batch SQL
  migrations sourced from the reference-aware reports. Always
  human-approved; never mass-update.

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
├── refs/                  ← phase 2: reference-data fetchers and parsers
│   ├── http_client.py     ← cache + rate limit + retry + offline mode
│   ├── bgwiki.py          ← BG Wiki MediaWiki API
│   ├── ffxiclopedia.py    ← FFXIclopedia (Fandom) MediaWiki API
│   ├── ffxidb.py          ← FFXIDB HTML drop tables + ZoneMap
│   ├── wikitext.py        ← detection codes + Drop Rate templates
│   ├── confidence.py      ← high/medium/low/none buckets
│   └── aggregate.py       ← per-mob lookup helpers used by the audits
├── samples/               ← committed sample outputs
│   ├── mob_pools_divergence.{csv,md}
│   ├── mob_droplist_divergence.{csv,md}
│   ├── mob_pools_divergence_refs.{csv,md}      ← --with-refs sample
│   ├── mob_droplist_divergence_refs.{csv,md}
│   └── generate_refs_sample.py
├── cache/                 ← gitignored; populated on first live run
│   ├── base/              ← upstream LSB SQL
│   └── refs/<source>/     ← wiki / FFXIDB response cache
├── reports/               ← gitignored; default --output destination
└── tests/
    ├── test_audit.py      ← phase 1 tests
    ├── test_refs.py       ← phase 2 tests (offline, fixture-driven)
    └── fixtures/
        ├── local/
        ├── upstream/
        └── refs/{bgwiki,ffxiclopedia,ffxidb}/
```
