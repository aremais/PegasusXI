"""Reference-aware aggregation for the audit reports.

Given a mob name (or a list of names), pull whatever data the BG Wiki /
FFXIclopedia / FFXIDB clients have in their cache or can fetch live, and
collapse it into a small ``ReferenceRow`` used by the report writers.

This module never *requires* live access: every individual lookup may return
``None`` / empty, and the row records that as ``confidence='none'``.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Iterable, Optional

from ..schemas import decode_detects
from .bgwiki import BGWikiClient
from .confidence import agreement_bucket, best_of
from .ffxiclopedia import FFXIclopediaClient
from .ffxidb import FFXIDBClient, FFXIDBDrop


@dataclass
class DetectionRefRow:
    """Aggregated detection lookup for one mob across wiki references."""

    mob_name: str
    bgwiki_bitmask: Optional[int] = None
    bgwiki_decoded: str = ""
    bgwiki_confidence: str = "none"
    bgwiki_url: str = ""
    bgwiki_notes: str = ""
    ffxiclopedia_bitmask: Optional[int] = None
    ffxiclopedia_decoded: str = ""
    ffxiclopedia_confidence: str = "none"
    ffxiclopedia_url: str = ""
    ffxiclopedia_notes: str = ""
    agreement: str = "none"

    def headline_confidence(self) -> str:
        return best_of([self.bgwiki_confidence, self.ffxiclopedia_confidence])


@dataclass
class DropRefRow:
    """Aggregated FFXIDB drop lookup for one (mob, item) pair."""

    mob_name: str
    item_name: str
    ffxidb_avg_pct: Optional[float] = None
    ffxidb_th0_pct: Optional[float] = None
    ffxidb_th1_pct: Optional[float] = None
    ffxidb_th2_pct: Optional[float] = None
    ffxidb_th3_pct: Optional[float] = None
    ffxidb_kills: Optional[int] = None
    ffxidb_confidence: str = "none"
    ffxidb_url: str = ""
    bgwiki_drops: int = 0
    bgwiki_kills: int = 0
    bgwiki_confidence: str = "none"
    bgwiki_url: str = ""

    @property
    def bgwiki_pct(self) -> Optional[float]:
        if self.bgwiki_kills <= 0:
            return None
        return 100.0 * self.bgwiki_drops / self.bgwiki_kills


def lookup_detection(
    mob_name: str,
    *,
    bgwiki: Optional[BGWikiClient] = None,
    ffxiclopedia: Optional[FFXIclopediaClient] = None,
) -> DetectionRefRow:
    row = DetectionRefRow(mob_name=mob_name)
    if bgwiki is not None:
        page = bgwiki.get_page(mob_name)
        if not page.missing:
            parse = page.detection()
            row.bgwiki_bitmask = parse.bitmask
            row.bgwiki_decoded = decode_detects(parse.bitmask) if parse.bitmask is not None else ""
            row.bgwiki_confidence = parse.confidence
            row.bgwiki_url = page.url
            row.bgwiki_notes = "; ".join(parse.notes)
    if ffxiclopedia is not None:
        page = ffxiclopedia.get_page(mob_name)
        if not page.missing:
            parse = page.detection()
            row.ffxiclopedia_bitmask = parse.bitmask
            row.ffxiclopedia_decoded = decode_detects(parse.bitmask) if parse.bitmask is not None else ""
            row.ffxiclopedia_confidence = parse.confidence
            row.ffxiclopedia_url = page.url
            row.ffxiclopedia_notes = "; ".join(parse.notes)
    row.agreement = agreement_bucket([row.bgwiki_decoded or None, row.ffxiclopedia_decoded or None])
    return row


def lookup_ffxidb_drops(
    mob_name: str,
    *,
    lsb_zoneid: int,
    client: FFXIDBClient,
) -> dict[str, FFXIDBDrop]:
    """Return ``{item_name_lower: FFXIDBDrop}`` for the given mob, or ``{}``."""
    page = client.fetch_mob(lsb_zoneid, mob_name)
    if page.missing or not page.drops:
        return {}
    return {d.item_name.lower(): d for d in page.drops}


def names_from_file(path: str) -> list[str]:
    """Read newline-delimited mob names from ``path``; lines starting with # are ignored."""
    out: list[str] = []
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            s = line.strip()
            if not s or s.startswith("#"):
                continue
            out.append(s)
    return out
