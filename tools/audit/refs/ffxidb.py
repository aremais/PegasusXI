"""FFXIDB HTML drop-table scraper.

FFXIDB (http://www.ffxidb.com) is the public face of the Guildwork Windower
plugin's empirical kill dataset. It freezes at the Feb 2015 patch but is the
best TH-stratified source for retail drop rates.

URL pattern: ``http://www.ffxidb.com/zones/{zone_id}/{mob_slug}``.

Zone IDs do **not** match LSB ``mob_groups.zoneid`` one-to-one. We never
guess; callers must supply a mapping via :class:`ZoneMap`, otherwise we just
record the LSB zoneid in a TODO file for human review.

This module deliberately uses only stdlib ``html.parser`` so the tooling has
no third-party dependencies.
"""

from __future__ import annotations

import csv
import json
import re
import urllib.parse
from dataclasses import asdict, dataclass, field
from html.parser import HTMLParser
from pathlib import Path
from typing import Optional

from .confidence import kills_to_bucket
from .http_client import HttpClient, OfflineCacheMiss

FFXIDB_BASE = "http://www.ffxidb.com"
FFXIDB_ZONE_URL_TMPL = FFXIDB_BASE + "/zones/{zone_id}/{slug}"

_KILLS_FRACTION_RE = re.compile(r"(\d+)\s*/\s*(\d+)")
_PERCENT_RE = re.compile(r"(-?\d+(?:\.\d+)?)\s*%?")


def slugify(name: str) -> str:
    """Return a FFXIDB-style mob slug.

    Rules derived from observed URLs:

    * Lowercase.
    * Apostrophes removed.
    * Anything not ``[a-z0-9]`` collapses to ``-``.
    * Leading/trailing ``-`` stripped, runs collapsed.

    >>> slugify("Stroper Chyme")
    'stroper-chyme'
    >>> slugify("M'naeh Boa")
    'mnaeh-boa'
    """
    s = name.lower().replace("'", "").replace("’", "")
    s = re.sub(r"[^a-z0-9]+", "-", s)
    s = re.sub(r"-+", "-", s).strip("-")
    return s


@dataclass
class FFXIDBDrop:
    """One row in an FFXIDB drop table."""

    item_name: str
    kills_drops: Optional[int]
    kills_total: Optional[int]
    avg_pct: Optional[float]
    th0_pct: Optional[float] = None
    th1_pct: Optional[float] = None
    th2_pct: Optional[float] = None
    th3_pct: Optional[float] = None
    confidence: str = "none"
    source_url: str = ""

    def __post_init__(self) -> None:
        if not self.confidence or self.confidence == "none":
            self.confidence = kills_to_bucket(self.kills_total)


@dataclass
class FFXIDBMobPage:
    """Result of scraping a single FFXIDB mob URL."""

    zone_id: int
    mob_slug: str
    url: str
    drops: list[FFXIDBDrop] = field(default_factory=list)
    missing: bool = False
    from_cache: bool = True


class _DropTableParser(HTMLParser):
    """Streaming HTML parser that pulls every ``<table>`` of drop rows.

    FFXIDB's drop tables look like (Feb 2015 snapshot):

    ``<table class="drops">``
    ``  <tr><th>Item</th><th>Kills</th><th>Average</th><th>TH0</th>...</tr>``
    ``  <tr><td>Bronze Ingot</td><td>123 / 456</td><td>26.9%</td>...</tr>``

    We do not rely on class names — we accept any table whose header row
    contains the literal text ``Average``, ``TH0``, ``TH1`` etc.
    """

    AVG_HEADERS = {"average", "avg", "avg.", "avg pct"}
    TH_HEADERS = {"th0": "th0", "th1": "th1", "th2": "th2", "th3": "th3", "th3+": "th3"}
    ITEM_HEADERS = {"item", "name"}
    KILL_HEADERS = {"kills", "count", "kills (drops/total)"}

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self._in_table = False
        self._in_tr = False
        self._in_cell = False
        self._cell_tag: Optional[str] = None
        self._cell_text: list[str] = []
        self._current_row: list[str] = []
        self._current_row_is_header = False
        self._header_indices: dict[str, int] = {}
        self.rows: list[list[str]] = []
        self.headers: dict[str, int] = {}

    def handle_starttag(self, tag, attrs):
        if tag == "table":
            self._in_table = True
            self._header_indices = {}
            self.rows = []
            self.headers = {}
        elif tag == "tr" and self._in_table:
            self._in_tr = True
            self._current_row = []
            self._current_row_is_header = False
        elif tag in ("td", "th") and self._in_tr:
            self._in_cell = True
            self._cell_tag = tag
            self._cell_text = []
            if tag == "th":
                self._current_row_is_header = True

    def handle_endtag(self, tag):
        if tag in ("td", "th") and self._in_cell:
            text = " ".join("".join(self._cell_text).split())
            self._current_row.append(text)
            self._in_cell = False
            self._cell_tag = None
            self._cell_text = []
        elif tag == "tr" and self._in_tr:
            if self._current_row_is_header:
                self._maybe_record_headers(self._current_row)
            elif self._header_indices:
                self.rows.append(list(self._current_row))
            self._in_tr = False
            self._current_row = []
            self._current_row_is_header = False
        elif tag == "table":
            if self._header_indices and not self.headers:
                self.headers = dict(self._header_indices)
            self._in_table = False

    def handle_data(self, data):
        if self._in_cell:
            self._cell_text.append(data)

    def _maybe_record_headers(self, row: list[str]) -> None:
        idx: dict[str, int] = {}
        for i, cell in enumerate(row):
            label = cell.strip().lower()
            if label in self.AVG_HEADERS:
                idx["avg"] = i
            elif label in self.TH_HEADERS:
                idx[self.TH_HEADERS[label]] = i
            elif label in self.ITEM_HEADERS:
                idx["item"] = i
            elif label in self.KILL_HEADERS:
                idx["kills"] = i
        if "item" in idx and ("avg" in idx or any(k in idx for k in ("th0", "th1", "th2", "th3"))):
            self._header_indices = idx


def _parse_percent(cell: str) -> Optional[float]:
    if not cell:
        return None
    m = _PERCENT_RE.search(cell)
    if not m:
        return None
    try:
        return float(m.group(1))
    except ValueError:
        return None


def _parse_kill_fraction(cell: str) -> tuple[Optional[int], Optional[int]]:
    if not cell:
        return None, None
    m = _KILLS_FRACTION_RE.search(cell)
    if m:
        return int(m.group(1)), int(m.group(2))
    m2 = re.search(r"\d+", cell)
    if m2:
        return None, int(m2.group(0))
    return None, None


def parse_ffxidb_html(html: str, *, source_url: str = "") -> list[FFXIDBDrop]:
    """Parse FFXIDB mob-page HTML into a list of :class:`FFXIDBDrop`."""
    parser = _DropTableParser()
    try:
        parser.feed(html)
    except Exception:  # malformed HTML
        return []
    if not parser.headers or "item" not in parser.headers:
        return []
    out: list[FFXIDBDrop] = []
    for row in parser.rows:
        get = lambda key: row[parser.headers[key]] if key in parser.headers and parser.headers[key] < len(row) else ""
        item_name = get("item").strip()
        if not item_name or item_name.lower() in {"item", "name", "total"}:
            continue
        drops, kills = _parse_kill_fraction(get("kills"))
        out.append(
            FFXIDBDrop(
                item_name=item_name,
                kills_drops=drops,
                kills_total=kills,
                avg_pct=_parse_percent(get("avg")),
                th0_pct=_parse_percent(get("th0")),
                th1_pct=_parse_percent(get("th1")),
                th2_pct=_parse_percent(get("th2")),
                th3_pct=_parse_percent(get("th3")),
                source_url=source_url,
            )
        )
    return out


@dataclass
class ZoneMap:
    """LSB zoneid -> FFXIDB zoneid mapping.

    The mapping is *not* derivable mechanically; FFXIDB's numbering is its own.
    Build one progressively. Anywhere a mapping is missing we emit a TODO
    record instead of skipping silently.
    """

    lsb_to_ffxidb: dict[int, int] = field(default_factory=dict)

    @classmethod
    def from_json(cls, path: Path) -> "ZoneMap":
        if not path.exists():
            return cls()
        data = json.loads(path.read_text(encoding="utf-8"))
        return cls(lsb_to_ffxidb={int(k): int(v) for k, v in data.items()})

    def to_json(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            json.dumps({str(k): v for k, v in sorted(self.lsb_to_ffxidb.items())}, indent=2),
            encoding="utf-8",
        )

    def ffxidb_zone(self, lsb_zoneid: int) -> Optional[int]:
        return self.lsb_to_ffxidb.get(lsb_zoneid)


class FFXIDBClient:
    """HTTP client for FFXIDB mob HTML pages.

    Parameters
    ----------
    zone_map : ZoneMap | None
        LSB → FFXIDB zone mapping. If ``None`` or missing, ``fetch_mob``
        returns a "no zone mapping" result instead of guessing.
    allow_fetch : bool
        Offline mode toggle.
    todo_path : Path | None
        If set, missing zone mappings and unrecognised pages are appended
        as one-line CSV TODO rows for reviewer action.
    """

    def __init__(
        self,
        *,
        zone_map: Optional[ZoneMap] = None,
        allow_fetch: bool = True,
        todo_path: Optional[Path] = None,
        **http_kwargs,
    ) -> None:
        self.zone_map = zone_map or ZoneMap()
        self.http = HttpClient("ffxidb", allow_fetch=allow_fetch, **http_kwargs)
        self.todo_path = todo_path

    def _append_todo(self, reason: str, **fields: object) -> None:
        if self.todo_path is None:
            return
        self.todo_path.parent.mkdir(parents=True, exist_ok=True)
        new = not self.todo_path.exists()
        with self.todo_path.open("a", newline="", encoding="utf-8") as fh:
            w = csv.writer(fh)
            if new:
                w.writerow(["reason", "lsb_zoneid", "mob_name", "mob_slug", "tried_url"])
            w.writerow([
                reason,
                fields.get("lsb_zoneid", ""),
                fields.get("mob_name", ""),
                fields.get("mob_slug", ""),
                fields.get("tried_url", ""),
            ])

    def url_for(self, ffxidb_zone_id: int, mob_slug: str) -> str:
        return FFXIDB_ZONE_URL_TMPL.format(
            zone_id=ffxidb_zone_id, slug=urllib.parse.quote(mob_slug)
        )

    def fetch_mob(self, lsb_zoneid: int, mob_name: str) -> FFXIDBMobPage:
        slug = slugify(mob_name)
        ffxidb_zone = self.zone_map.ffxidb_zone(lsb_zoneid)
        if ffxidb_zone is None:
            tried = f"(no FFXIDB zone mapping for LSB zoneid={lsb_zoneid})"
            self._append_todo("missing_zone_mapping", lsb_zoneid=lsb_zoneid, mob_name=mob_name, mob_slug=slug, tried_url=tried)
            return FFXIDBMobPage(zone_id=-1, mob_slug=slug, url=tried, missing=True)
        url = self.url_for(ffxidb_zone, slug)
        try:
            resp = self.http.get(url)
        except OfflineCacheMiss:
            return FFXIDBMobPage(zone_id=ffxidb_zone, mob_slug=slug, url=url, missing=True)
        drops = parse_ffxidb_html(resp.text(), source_url=url)
        if not drops:
            self._append_todo("no_drops_parsed", lsb_zoneid=lsb_zoneid, mob_name=mob_name, mob_slug=slug, tried_url=url)
        return FFXIDBMobPage(
            zone_id=ffxidb_zone,
            mob_slug=slug,
            url=url,
            drops=drops,
            missing=not drops,
            from_cache=resp.from_cache,
        )

    def fetch_mob_by_zone(self, ffxidb_zone_id: int, mob_name: str) -> FFXIDBMobPage:
        """Direct fetch when a caller already knows the FFXIDB zone id."""
        slug = slugify(mob_name)
        url = self.url_for(ffxidb_zone_id, slug)
        try:
            resp = self.http.get(url)
        except OfflineCacheMiss:
            return FFXIDBMobPage(zone_id=ffxidb_zone_id, mob_slug=slug, url=url, missing=True)
        drops = parse_ffxidb_html(resp.text(), source_url=url)
        return FFXIDBMobPage(
            zone_id=ffxidb_zone_id,
            mob_slug=slug,
            url=url,
            drops=drops,
            missing=not drops,
            from_cache=resp.from_cache,
        )


def drop_to_dict(d: FFXIDBDrop) -> dict:
    return asdict(d)
