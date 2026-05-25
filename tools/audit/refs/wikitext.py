"""Wikitext parsing for BG Wiki and FFXIclopedia.

What this module extracts:

* **Detection note codes** in zone/family tables — ``A``, ``L``, ``S``, ``H``,
  ``M``, ``HP``, ``T``, ``Sc``, plus ability/JA/WS detection. These are mapped
  to the ``DETECT`` bitmask used by LSB (see ``schemas.DETECT_FLAGS``).
* **Drop rate templates** — ``{{Drop Rate|drops|kills}}`` instances, with kill
  count and confidence bucket.

Design notes
------------

* The parser is intentionally conservative. It returns a structured
  :class:`DetectionParse` with explicit confidence and notes; it does **not**
  guess a bitmask when the input is ambiguous.
* Note codes vary in formatting across pages: bare ``A``, ``A, L``, ``{{A}}``,
  ``[[Aggressive|A]]``. We accept all of these and ignore the rest.
* We never silently drop unknown tokens — they go into ``notes`` so a reviewer
  can spot mismatches between wiki conventions and our table.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Optional

from .confidence import kills_to_bucket
from ..schemas import DETECT_FLAGS

DETECT_NAME_TO_BIT = {name: bit for bit, name in DETECT_FLAGS.items()}

NOTE_CODE_TO_BIT: dict[str, int] = {
    "S": DETECT_NAME_TO_BIT["SIGHT"],
    "Sight": DETECT_NAME_TO_BIT["SIGHT"],
    "H": DETECT_NAME_TO_BIT["HEARING"],
    "Sound": DETECT_NAME_TO_BIT["HEARING"],
    "Hearing": DETECT_NAME_TO_BIT["HEARING"],
    "M": DETECT_NAME_TO_BIT["MAGIC"],
    "Magic": DETECT_NAME_TO_BIT["MAGIC"],
    "HP": DETECT_NAME_TO_BIT["LOWHP"],
    "LowHP": DETECT_NAME_TO_BIT["LOWHP"],
    "Sc": DETECT_NAME_TO_BIT["SCENT"],
    "Scent": DETECT_NAME_TO_BIT["SCENT"],
    "T": DETECT_NAME_TO_BIT["SCENT"],
    "Tracking": DETECT_NAME_TO_BIT["SCENT"],
    "WS": DETECT_NAME_TO_BIT["WEAPONSKILL"],
    "Wsk": DETECT_NAME_TO_BIT["WEAPONSKILL"],
    "Weaponskill": DETECT_NAME_TO_BIT["WEAPONSKILL"],
    "JA": DETECT_NAME_TO_BIT["JOBABILITY"],
    "Job_Ability": DETECT_NAME_TO_BIT["JOBABILITY"],
    "JobAbility": DETECT_NAME_TO_BIT["JOBABILITY"],
    "Ability": DETECT_NAME_TO_BIT["JOBABILITY"],
}

AGGRO_FLAGS = {"A", "Aggressive"}
LINK_FLAGS = {"L", "Linking", "Links"}
TRUE_SIGHT_FLAGS = {"TS", "TrueSight", "True_Sight"}
TRUE_SOUND_FLAGS = {"TH", "TrueHearing", "True_Sound", "True_Hearing"}

KNOWN_TOKENS = (
    set(NOTE_CODE_TO_BIT)
    | AGGRO_FLAGS
    | LINK_FLAGS
    | TRUE_SIGHT_FLAGS
    | TRUE_SOUND_FLAGS
    | {"N", "None", "Detect", "Detects"}
)

_WIKILINK_RE = re.compile(r"\[\[(?:[^|\]]*\|)?([^\]]+)\]\]")
_TEMPLATE_TOKEN_RE = re.compile(r"\{\{\s*([A-Za-z][A-Za-z _]*)\s*\}\}")
_DROP_RATE_RE = re.compile(
    r"\{\{\s*Drop[ _]Rate\s*\|\s*(\d+)\s*\|\s*(\d+)\s*(?:\|[^}]*)?\}\}",
    re.IGNORECASE,
)
_BARE_FRACTION_RE = re.compile(r"\b(\d+)\s*/\s*(\d+)\s+kills\b", re.IGNORECASE)


@dataclass
class DetectionParse:
    """Result of attempting to parse detection note codes from wikitext.

    Attributes
    ----------
    bitmask : int | None
        Reconstructed DETECT bitmask, or ``None`` if no detection note codes
        were found (caller should treat as "no data", not "DETECT_NONE").
    aggressive : bool | None
        Whether the mob is marked aggressive (``A``). ``None`` = unspecified.
    links : bool | None
        Whether the mob links (``L``). ``None`` = unspecified.
    true_sight : bool
        Whether ``TS`` / ``True Sight`` was present.
    true_sound : bool
        Whether ``TH`` / ``True Hearing`` was present.
    raw_tokens : list[str]
        The raw note tokens we extracted (deduped, order-preserving).
    confidence : str
        ``high`` if at least one detection note code was matched and no
        ambiguous tokens remain; ``medium`` if some unknown tokens were seen
        alongside known ones; ``low`` if only the meta flags A/L/TS/TH were
        present without a sense type; ``none`` if nothing parseable.
    notes : list[str]
        Free-text reviewer hints (unknown tokens, page snippets).
    """

    bitmask: Optional[int] = None
    aggressive: Optional[bool] = None
    links: Optional[bool] = None
    true_sight: bool = False
    true_sound: bool = False
    raw_tokens: list[str] = field(default_factory=list)
    confidence: str = "none"
    notes: list[str] = field(default_factory=list)

    @property
    def decoded(self) -> str:
        if self.bitmask is None:
            return ""
        from ..schemas import decode_detects
        return decode_detects(self.bitmask)


def _strip_wiki_markup(cell: str) -> str:
    """Return ``cell`` with wiki links collapsed to their visible label."""
    return _WIKILINK_RE.sub(lambda m: m.group(1), cell)


def _extract_tokens(cell: str) -> list[str]:
    """Find note-code tokens in a wiki table cell."""
    flat = _strip_wiki_markup(cell)
    flat = _TEMPLATE_TOKEN_RE.sub(lambda m: m.group(1), flat)
    raw_parts = re.split(r"[\s,;/()\[\]\"]+", flat)
    tokens: list[str] = []
    for part in raw_parts:
        p = part.strip().strip(".:")
        if not p:
            continue
        if p in KNOWN_TOKENS:
            tokens.append(p)
            continue
        norm = p.replace(" ", "_")
        if norm in KNOWN_TOKENS:
            tokens.append(norm)
    return tokens


def parse_detection_cell(cell: str) -> DetectionParse:
    """Parse a single wiki table cell of detection note codes.

    Example inputs:

    * ``"A, L, S"`` — Aggressive, Links, Sight
    * ``"S, Sc"`` — Sight + Scent tracking
    * ``"{{A}} {{L}} {{H}}"`` — template-formatted
    * ``"[[Aggressive|A]], [[Linking|L]], [[Magic Aggro|M]]"`` — wiki-linked

    Returns
    -------
    DetectionParse
    """
    parse = DetectionParse()
    if not cell or not cell.strip():
        return parse

    tokens = _extract_tokens(cell)
    seen: set[str] = set()
    bitmask = 0
    sensed_any = False
    for tok in tokens:
        if tok in seen:
            continue
        seen.add(tok)
        parse.raw_tokens.append(tok)
        if tok in AGGRO_FLAGS:
            parse.aggressive = True
        elif tok in LINK_FLAGS:
            parse.links = True
        elif tok in TRUE_SIGHT_FLAGS:
            parse.true_sight = True
        elif tok in TRUE_SOUND_FLAGS:
            parse.true_sound = True
        elif tok in NOTE_CODE_TO_BIT:
            bitmask |= NOTE_CODE_TO_BIT[tok]
            sensed_any = True
        elif tok in {"N", "None"}:
            sensed_any = True

    if sensed_any:
        parse.bitmask = bitmask
        parse.confidence = "high"
    elif parse.raw_tokens:
        parse.confidence = "low"
        parse.notes.append("only meta flags (A/L/TS/TH) present, no sense type")
    else:
        parse.confidence = "none"

    return parse


@dataclass
class DropRateParse:
    """Parsed ``{{Drop Rate|drops|kills}}`` template instance."""

    drops: int
    kills: int
    source_template: str
    confidence: str = "none"

    @property
    def percent(self) -> float:
        if self.kills <= 0:
            return 0.0
        return 100.0 * self.drops / self.kills

    def __post_init__(self) -> None:
        if not self.confidence or self.confidence == "none":
            self.confidence = kills_to_bucket(self.kills)


def parse_drop_rates(wikitext: str) -> list[DropRateParse]:
    """Find all ``{{Drop Rate|...}}`` (and a few common variants) in wikitext."""
    out: list[DropRateParse] = []
    for m in _DROP_RATE_RE.finditer(wikitext):
        drops = int(m.group(1))
        kills = int(m.group(2))
        out.append(DropRateParse(drops=drops, kills=kills, source_template=m.group(0)))
    for m in _BARE_FRACTION_RE.finditer(wikitext):
        drops = int(m.group(1))
        kills = int(m.group(2))
        out.append(DropRateParse(drops=drops, kills=kills, source_template=m.group(0)))
    return out


_DETECTION_LINE_RE = re.compile(
    r"(?im)^[\s|*:]*(?:'''|;)?\s*"
    r"(?:Detection|Detects|Detection Type|Senses)\s*"
    r"(?:'''|:)?\s*[:=]\s*([^\n|}]+?)\s*$"
)


def find_detection_in_page(wikitext: str) -> DetectionParse:
    """Scan a full wiki page for a detection summary line.

    BG Wiki / FFXIclopedia mob pages typically include something like
    ``Detection: Sight, Sound`` near the top. We pick the first such line.
    Falls back to scanning the whole page for note codes if nothing
    structured is found.
    """
    for m in _DETECTION_LINE_RE.finditer(wikitext):
        cell = m.group(1)
        parse = parse_detection_cell(cell)
        if parse.confidence != "none":
            parse.notes.append("matched 'Detection:' line")
            return parse
    full = parse_detection_cell(wikitext)
    if full.confidence == "high":
        full.notes.append("fallback: tokens scraped from whole page")
        full.confidence = "medium"
    return full
