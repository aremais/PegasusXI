"""Pytest tests for the audit tooling: parser correctness and end-to-end diff counts.

These tests do not touch the network or MySQL; they run entirely against the
bundled SQL fixtures.
"""

from __future__ import annotations

import csv
from pathlib import Path

import pytest

from tools.audit import audit_drops, audit_mob_pools
from tools.audit.schemas import decode_detects
from tools.audit.sql_parser import HexLiteral, SqlVariable, parse_inserts_text

FIXTURES = Path(__file__).parent / "fixtures"


def test_sql_parser_handles_mixed_tokens():
    text = (
        "INSERT INTO `t` VALUES "
        "(1,'foo',0x0A1B,@COMMON,NULL,3.14,-5);\n"
        "INSERT INTO `t` VALUES (2,'has \\'quote\\'',0xFF,@RARE,NULL,0.0,0);\n"
    )
    rows = list(parse_inserts_text(text, "t"))
    assert len(rows) == 2
    assert rows[0] == [1, "foo", HexLiteral("0x0A1B"), SqlVariable("@COMMON"), None, 3.14, -5]
    assert isinstance(rows[0][2], HexLiteral)
    assert isinstance(rows[0][3], SqlVariable)
    assert rows[1][1] == "has 'quote'"


def test_sql_parser_skips_other_tables():
    text = (
        "INSERT INTO `other` VALUES (99,'skip');\n"
        "INSERT INTO `t` VALUES (1,'keep');\n"
    )
    rows = list(parse_inserts_text(text, "t"))
    assert rows == [[1, "keep"]]


def test_decode_detects_bitmask():
    assert decode_detects(0) == "NONE (0x00)"
    assert decode_detects(3) == "SIGHT|HEARING (0x03)"
    assert decode_detects(0x21) == "SIGHT|MAGIC (0x21)"
    assert "UNK" in decode_detects(0x800)


def test_pool_audit_end_to_end(tmp_path):
    res = audit_mob_pools.run(FIXTURES / "local", FIXTURES / "upstream", tmp_path)
    assert res["count"] == 4

    with (tmp_path / "mob_pools_divergence.csv").open() as fh:
        rows = list(csv.DictReader(fh))

    by_pool = {int(r["poolid"]): r for r in rows}
    # Pool 100: aggro and links changed locally
    assert by_pool[100]["status"] == "changed"
    assert "aggro" in by_pool[100]["changes"]
    assert "links" in by_pool[100]["changes"]
    # Pool 101: pool fields unchanged but effective detects override pushes a diff
    assert by_pool[101]["status"] == "changed"
    assert "effective_detects" in by_pool[101]["changes"]
    # Local: MOBMOD_DETECTION override = 2 (HEARING)
    assert "HEARING" in by_pool[101]["local_detects"]
    assert "override" in by_pool[101]["local_detects"]
    # Upstream: no override, species 60 detects = 1 (SIGHT)
    assert "SIGHT" in by_pool[101]["upstream_detects"]
    assert "species 60" in by_pool[101]["upstream_detects"]
    # Pool 102 local-only, 103 upstream-only
    assert by_pool[102]["status"] == "only_local"
    assert by_pool[103]["status"] == "only_upstream"


def test_drop_audit_end_to_end(tmp_path):
    res = audit_drops.run(FIXTURES / "local", FIXTURES / "upstream", tmp_path)
    assert res["count"] == 3
    with (tmp_path / "mob_droplist_divergence.csv").open() as fh:
        rows = list(csv.DictReader(fh))
    statuses = {(int(r["dropId"]), int(r["groupId"]), int(r["itemId"])): r["status"] for r in rows}
    assert statuses[(1, 0, 1000)] == "changed"
    assert statuses[(1, 0, 1002)] == "only_upstream"
    assert statuses[(2, 0, 2000)] == "only_local"
    # Item name + mob name resolution should populate
    item_names = {(int(r["itemId"])): r["item_name"] for r in rows}
    assert item_names[1000] == "goblin_tooth"
    mob_names = {(int(r["dropId"])): r["mob_names"] for r in rows}
    assert "Goblin_Tinkerer" in mob_names[1]


def test_self_check_runs(tmp_path):
    from tools.audit import self_check
    rc = self_check.main(["--output", str(tmp_path)])
    assert rc == 0
    assert (tmp_path / "mob_pools_divergence.csv").exists()
    assert (tmp_path / "mob_droplist_divergence.csv").exists()


@pytest.mark.skipif(
    not (Path(__file__).parent.parent.parent.parent / "sql" / "mob_pools.sql").exists(),
    reason="requires repo sql/ dir",
)
def test_repo_sql_parses_cleanly():
    """Smoke test: the parser must consume the real mob_pools.sql without raising."""
    from tools.audit.schemas import MOB_POOLS_COLUMNS
    from tools.audit.sql_parser import rows_by_key
    repo_root = Path(__file__).parent.parent.parent.parent
    rows = rows_by_key(repo_root / "sql" / "mob_pools.sql", "mob_pools", MOB_POOLS_COLUMNS, key="poolid")
    assert len(rows) > 100
