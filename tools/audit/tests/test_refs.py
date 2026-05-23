"""Pytest tests for the reference fetchers and parsers.

All network access is replaced with hand-staged cache entries. Tests use
``allow_fetch=False`` (offline mode) — any cache miss raises immediately and
the test fails loudly.
"""

from __future__ import annotations

import hashlib
import json
import time
from pathlib import Path

import pytest

from tools.audit.refs.bgwiki import BGWikiClient
from tools.audit.refs.confidence import (
    agreement_bucket, best_of, kills_to_bucket,
)
from tools.audit.refs.ffxiclopedia import FFXIclopediaClient
from tools.audit.refs.ffxidb import (
    FFXIDBClient, ZoneMap, parse_ffxidb_html, slugify,
)
from tools.audit.refs.http_client import HttpClient, OfflineCacheMiss
from tools.audit.refs.wikitext import (
    find_detection_in_page, parse_detection_cell, parse_drop_rates,
)
from tools.audit.schemas import DETECT_FLAGS, decode_detects

FIXTURES = Path(__file__).parent / "fixtures" / "refs"


def _stage_cache(client_http: HttpClient, url: str, body: bytes) -> None:
    """Write ``body`` into ``client_http``'s cache as if it had been fetched."""
    key = hashlib.sha1(url.encode("utf-8")).hexdigest()
    client_http.cache_dir.mkdir(parents=True, exist_ok=True)
    (client_http.cache_dir / f"{key}.body").write_bytes(body)
    (client_http.cache_dir / f"{key}.meta").write_text(
        json.dumps({"url": url, "fetched_at": time.time(), "source": client_http.source}),
        encoding="utf-8",
    )


def _bgwiki_response_json(title: str, wikitext: str) -> bytes:
    payload = {
        "query": {
            "pages": [
                {
                    "title": title,
                    "revisions": [{"slots": {"main": {"content": wikitext}}}],
                }
            ]
        }
    }
    return json.dumps(payload).encode("utf-8")


@pytest.fixture
def cache_dir(tmp_path) -> Path:
    return tmp_path / "cache"


def test_kills_to_bucket():
    assert kills_to_bucket(None) == "none"
    assert kills_to_bucket(0) == "none"
    assert kills_to_bucket(10) == "low"
    assert kills_to_bucket(100) == "medium"
    assert kills_to_bucket(1000) == "high"


def test_best_of_picks_highest():
    assert best_of(["low", "medium", "none"]) == "medium"
    assert best_of(["none", "none"]) == "none"
    assert best_of(["high", "low"]) == "high"


def test_agreement_bucket():
    assert agreement_bucket(["A", "A", None]) == "medium"
    assert agreement_bucket(["A", "A", "A"]) == "high"
    assert agreement_bucket(["A", "B", "C"]) == "low"
    assert agreement_bucket([None, None]) == "none"
    assert agreement_bucket(["A"]) == "low"


def test_parse_detection_cell_basic_codes():
    parse = parse_detection_cell("A, L, S")
    assert parse.aggressive is True
    assert parse.links is True
    assert parse.bitmask is not None
    name_to_bit = {v: k for k, v in DETECT_FLAGS.items()}
    assert parse.bitmask & name_to_bit["SIGHT"]
    assert parse.confidence == "high"


def test_parse_detection_cell_multi_sense():
    parse = parse_detection_cell("S, H, Sc, HP, M")
    decoded = decode_detects(parse.bitmask)
    for label in ("SIGHT", "HEARING", "SCENT", "LOWHP", "MAGIC"):
        assert label in decoded


def test_parse_detection_cell_wiki_link():
    parse = parse_detection_cell("[[Aggressive|A]], [[Sight|S]]")
    assert parse.aggressive is True
    assert parse.bitmask and (parse.bitmask & 0x01)


def test_parse_detection_cell_only_meta_is_low_confidence():
    parse = parse_detection_cell("A, L")
    assert parse.confidence == "low"
    assert parse.bitmask is None  # no sense type


def test_find_detection_line_in_page():
    text = "Some intro.\nDetection: S, H\nMore text."
    parse = find_detection_in_page(text)
    assert parse.bitmask is not None
    assert parse.confidence == "high"


def test_parse_drop_rates_kill_counts():
    text = "Drops: {{Drop Rate|10|100}} of one item, {{Drop Rate|2|500}} of another."
    rates = parse_drop_rates(text)
    assert len(rates) == 2
    assert rates[0].drops == 10 and rates[0].kills == 100
    assert rates[0].confidence == "medium"
    assert rates[1].confidence == "high"  # 500 kills


def test_http_client_offline_miss(cache_dir):
    client = HttpClient("test", cache_dir=cache_dir, allow_fetch=False)
    with pytest.raises(OfflineCacheMiss):
        client.get("https://example.invalid/x")


def test_http_client_cache_hit(cache_dir):
    client = HttpClient("test", cache_dir=cache_dir, allow_fetch=False)
    _stage_cache(client, "https://example.invalid/x", b"hello")
    resp = client.get("https://example.invalid/x")
    assert resp.body == b"hello"
    assert resp.from_cache is True


def test_bgwiki_offline_with_staged_cache(cache_dir):
    client = BGWikiClient(allow_fetch=False, cache_dir=cache_dir)
    wikitext = (FIXTURES / "bgwiki" / "river_crab.wikitext").read_text()
    url = client._build_query_url("River Crab")
    _stage_cache(client.http, url, _bgwiki_response_json("River Crab", wikitext))

    page = client.get_page("River Crab")
    assert not page.missing
    detection = page.detection()
    assert detection.bitmask is not None
    assert "SIGHT" in decode_detects(detection.bitmask)
    assert "HEARING" in decode_detects(detection.bitmask)

    rates = page.drop_rates()
    assert len(rates) == 1
    assert rates[0].kills == 456


def test_bgwiki_offline_missing_page_no_raise(cache_dir):
    client = BGWikiClient(allow_fetch=False, cache_dir=cache_dir)
    page = client.get_page("Nonexistent Mob")
    assert page.missing is True


def test_ffxiclopedia_uses_separate_cache_namespace(cache_dir):
    client = FFXIclopediaClient(allow_fetch=False, cache_dir=cache_dir)
    assert client.http.source == "ffxiclopedia"
    assert client.http.cache_dir.name == "ffxiclopedia"
    wikitext = (FIXTURES / "ffxiclopedia" / "river_crab.wikitext").read_text()
    url = client._build_query_url("River Crab")
    _stage_cache(client.http, url, _bgwiki_response_json("River Crab", wikitext))
    page = client.get_page("River Crab")
    assert not page.missing
    detection = page.detection()
    assert detection.bitmask is not None


def test_ffxidb_slugify_rules():
    assert slugify("River Crab") == "river-crab"
    assert slugify("M'naeh Boa") == "mnaeh-boa"
    assert slugify("Stroper Chyme") == "stroper-chyme"
    assert slugify("Hpemde") == "hpemde"


def test_ffxidb_parse_html_fixture():
    html = (FIXTURES / "ffxidb" / "river_crab.html").read_text()
    drops = parse_ffxidb_html(html, source_url="http://x/y")
    by_name = {d.item_name: d for d in drops}
    assert "Bronze Ingot" in by_name
    bronze = by_name["Bronze Ingot"]
    assert bronze.avg_pct == 26.9
    assert bronze.th0_pct == 19.7
    assert bronze.kills_total == 456
    assert bronze.confidence == "medium"  # 456 < 500

    # Tiny Item should be low confidence (10 kills)
    assert by_name["Tiny Item"].confidence == "low"


def test_ffxidb_zone_map_missing_emits_todo(tmp_path, cache_dir):
    todo = tmp_path / "todo.csv"
    client = FFXIDBClient(zone_map=ZoneMap(), allow_fetch=False,
                          cache_dir=cache_dir, todo_path=todo)
    page = client.fetch_mob(lsb_zoneid=999, mob_name="Some Mob")
    assert page.missing
    assert todo.exists()
    text = todo.read_text()
    assert "missing_zone_mapping" in text
    assert "999" in text
    assert "some-mob" in text


def test_ffxidb_offline_with_staged_cache(tmp_path, cache_dir):
    zm = ZoneMap(lsb_to_ffxidb={5: 100})
    client = FFXIDBClient(zone_map=zm, allow_fetch=False, cache_dir=cache_dir)
    url = client.url_for(100, "river-crab")
    html = (FIXTURES / "ffxidb" / "river_crab.html").read_text().encode("utf-8")
    _stage_cache(client.http, url, html)

    page = client.fetch_mob(lsb_zoneid=5, mob_name="River Crab")
    assert not page.missing
    assert page.zone_id == 100
    assert page.mob_slug == "river-crab"
    by_name = {d.item_name: d for d in page.drops}
    assert "Bronze Ingot" in by_name
    assert by_name["Bronze Ingot"].th0_pct == 19.7


def test_pool_audit_with_refs_offline(tmp_path, cache_dir):
    """Smoke test: pools audit with --with-refs in offline mode produces ref columns."""
    from tools.audit import audit_mob_pools

    bg = BGWikiClient(allow_fetch=False, cache_dir=cache_dir)
    # Stage a wiki page for "Goblin Tinkerer" (fixture pool 100's name).
    wikitext = (FIXTURES / "bgwiki" / "goblin_tinkerer.wikitext").read_text()
    url = bg._build_query_url("Goblin Tinkerer")
    _stage_cache(bg.http, url, _bgwiki_response_json("Goblin Tinkerer", wikitext))

    fc = FFXIclopediaClient(allow_fetch=False, cache_dir=cache_dir)

    pool_fixtures = Path(__file__).parent / "fixtures"
    res = audit_mob_pools.run(
        pool_fixtures / "local", pool_fixtures / "upstream", tmp_path,
        with_refs=True,
        bgwiki_client=bg,
        ffxiclopedia_client=fc,
    )
    assert res["count"] == 4

    import csv as _csv
    with (tmp_path / "mob_pools_divergence.csv").open() as fh:
        rows = list(_csv.DictReader(fh))
    by_pool = {int(r["poolid"]): r for r in rows}
    # Goblin_Tinkerer pool 100 should have BG Wiki detection populated.
    gob = by_pool[100]
    assert "bgwiki_detects" in gob
    assert "SIGHT" in gob["bgwiki_detects"]
    assert "HEARING" in gob["bgwiki_detects"]
    assert gob["bgwiki_confidence"] == "high"
    # FFXIclopedia not cached for this name => empty
    assert gob["ffxiclopedia_detects"] == ""
