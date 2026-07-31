r"""Minimal SQL-dump parser for `INSERT INTO ... VALUES (...);` rows.

Scope: this parser handles the LandSandBoat / PegasusXI mob & item SQL dumps
(one tuple per INSERT, with quoted strings, hex binary literals, SQL
variables like ``@COMMON``, NULL, ints, floats). It is not a general-purpose
SQL parser - it is intentionally small and predictable so the audit reports
are reproducible from text alone, no MySQL/MariaDB instance required.

Public surface:

    parse_inserts(path, table) -> Iterator[list[Any]]
        Yields one Python list per row of ``INSERT INTO \`table\` VALUES (...)``.

    parse_inserts_text(text, table) -> Iterator[list[Any]]
        Same, but operates on an in-memory string (used by tests).

Token types in the returned lists:
    int            for integer literals
    float          for decimal literals containing '.'
    str            for quoted strings (unescaped)
    None           for NULL
    HexLiteral     for 0x... binary blobs (kept as the original token string)
    SqlVariable    for @IDENT tokens (kept as the original token string)
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Iterator, Iterable, Any


class HexLiteral(str):
    """Marker subclass so callers can distinguish hex blobs from regular strings."""

    __slots__ = ()


class SqlVariable(str):
    """Marker subclass for @IDENT SQL variables (e.g. @COMMON)."""

    __slots__ = ()


_INSERT_RE_CACHE: dict[str, re.Pattern[str]] = {}


def _insert_re(table: str) -> re.Pattern[str]:
    pat = _INSERT_RE_CACHE.get(table)
    if pat is None:
        # Match: INSERT INTO `table` VALUES (   ...   );
        # Capture group 1 is the tuple body without the outer parens.
        pat = re.compile(
            r"INSERT\s+INTO\s+`" + re.escape(table) + r"`\s+VALUES\s*\((.*?)\)\s*;",
            re.IGNORECASE | re.DOTALL,
        )
        _INSERT_RE_CACHE[table] = pat
    return pat


def _unescape_string(raw: str) -> str:
    out: list[str] = []
    i = 0
    while i < len(raw):
        c = raw[i]
        if c == "\\" and i + 1 < len(raw):
            nxt = raw[i + 1]
            mapping = {"n": "\n", "r": "\r", "t": "\t", "0": "\x00", "'": "'", '"': '"', "\\": "\\"}
            out.append(mapping.get(nxt, nxt))
            i += 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


_TOKEN_RE = re.compile(
    r"""
    \s*
    (?:
        '((?:[^'\\]|\\.)*)'                # 1: single-quoted string (with \\ escapes)
      | "((?:[^"\\]|\\.)*)"                # 2: double-quoted string
      | (0x[0-9A-Fa-f]+)                   # 3: hex literal
      | (@[A-Za-z_][A-Za-z0-9_]*)          # 4: SQL variable
      | (NULL)                             # 5: NULL keyword
      | (-?\d+\.\d+(?:[eE][+-]?\d+)?)      # 6: float
      | (-?\d+(?:[eE][+-]?\d+)?)           # 7: integer (or scientific without dot)
    )
    \s*
    (,|$)                                  # 8: separator
    """,
    re.VERBOSE | re.IGNORECASE,
)


def _parse_tuple(body: str) -> list[Any]:
    values: list[Any] = []
    pos = 0
    n = len(body)
    while pos < n:
        m = _TOKEN_RE.match(body, pos)
        if not m:
            stripped = body[pos:].strip()
            if not stripped:
                break
            raise ValueError(f"Cannot parse VALUES fragment at offset {pos}: {body[pos:pos + 60]!r}")
        if m.group(1) is not None:
            values.append(_unescape_string(m.group(1)))
        elif m.group(2) is not None:
            values.append(_unescape_string(m.group(2)))
        elif m.group(3) is not None:
            values.append(HexLiteral(m.group(3)))
        elif m.group(4) is not None:
            values.append(SqlVariable(m.group(4)))
        elif m.group(5) is not None:
            values.append(None)
        elif m.group(6) is not None:
            values.append(float(m.group(6)))
        elif m.group(7) is not None:
            values.append(int(m.group(7)))
        pos = m.end()
        if m.group(8) != ",":
            break
    return values


def parse_inserts_text(text: str, table: str) -> Iterator[list[Any]]:
    """Yield one list per row of INSERT INTO `table` VALUES (...) found in text."""
    for m in _insert_re(table).finditer(text):
        body = m.group(1)
        yield _parse_tuple(body)


def parse_inserts(path: str | Path, table: str) -> Iterator[list[Any]]:
    """Yield one list per row from the SQL file at ``path``."""
    p = Path(path)
    text = p.read_text(encoding="utf-8", errors="replace")
    return parse_inserts_text(text, table)


def rows_by_key(
    path: str | Path,
    table: str,
    columns: Iterable[str],
    key: str | tuple[str, ...],
) -> dict[Any, dict[str, Any]]:
    """Read an INSERT dump and return ``{key_value: row_dict}``.

    - ``columns`` is the ordered list of column names matching the INSERT order.
    - ``key`` is a single column name or a tuple of column names to use as the
      dict key. Composite keys produce a tuple key.
    """
    cols = list(columns)
    if isinstance(key, str):
        key_cols: tuple[str, ...] = (key,)
        single = True
    else:
        key_cols = tuple(key)
        single = False
    out: dict[Any, dict[str, Any]] = {}
    for row in parse_inserts(path, table):
        if len(row) != len(cols):
            raise ValueError(
                f"{table}: expected {len(cols)} columns, got {len(row)}: {row!r}"
            )
        d = dict(zip(cols, row))
        if single:
            k: Any = d[key_cols[0]]
        else:
            k = tuple(d[c] for c in key_cols)
        out[k] = d
    return out
