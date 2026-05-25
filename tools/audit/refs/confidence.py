"""Confidence bucket helpers for reference data.

The audit's confidence scheme is intentionally coarse:

* **high** — large empirical sample (>= 500 kills) or independent agreement
  across multiple sources.
* **medium** — moderate sample (>= 50 kills) or a single high-quality source.
* **low** — small sample (< 50 kills) or one ambiguous wiki note.
* **none** — no reference data available.

These map to the methodology report (``pegasusxi-validation-plan.pplx.md``,
section 6).
"""

from __future__ import annotations

from typing import Iterable, Optional

KILL_HIGH = 500
KILL_MEDIUM = 50

BUCKET_ORDER = {"none": 0, "low": 1, "medium": 2, "high": 3}


def kills_to_bucket(kills: Optional[int]) -> str:
    """Map an empirical kill count to one of ``high|medium|low|none``."""
    if kills is None or kills < 0:
        return "none"
    if kills >= KILL_HIGH:
        return "high"
    if kills >= KILL_MEDIUM:
        return "medium"
    if kills > 0:
        return "low"
    return "none"


def best_of(buckets: Iterable[str]) -> str:
    """Return the highest-confidence bucket from ``buckets``.

    Useful when an audit row has multiple reference inputs and we want the
    headline confidence to reflect the best of them.
    """
    best = "none"
    for b in buckets:
        if BUCKET_ORDER.get(b, 0) > BUCKET_ORDER.get(best, 0):
            best = b
    return best


def agreement_bucket(values: list[Optional[str]]) -> str:
    """Bucket based on how many non-empty inputs agree.

    Used for the detection-bitmask comparison across PegasusXI / LSB / wikis.
    Returns:

    * ``"high"`` if 3+ sources agree
    * ``"medium"`` if 2 sources agree
    * ``"low"`` if exactly one source provided a value or all disagree
    * ``"none"`` if no source provided a value
    """
    non_empty = [v for v in values if v not in (None, "")]
    if not non_empty:
        return "none"
    if len(non_empty) == 1:
        return "low"
    counts: dict[str, int] = {}
    for v in non_empty:
        counts[v] = counts.get(v, 0) + 1
    top = max(counts.values())
    if top >= 3:
        return "high"
    if top == 2:
        return "medium"
    return "low"
