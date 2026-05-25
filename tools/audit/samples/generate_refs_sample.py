"""Regenerate the bundled reference-aware sample outputs from test fixtures.

Run from the repo root::

    python3 tools/audit/samples/generate_refs_sample.py

This produces ``mob_pools_divergence_refs.{csv,md}`` and
``mob_droplist_divergence_refs.{csv,md}`` under ``tools/audit/samples/``.

The script is hermetic: it stages cache entries from the bundled fixtures
under a tmpdir and runs both audits in offline mode. It is **not** part of
the test suite or CI — it exists so reviewers can see what reference-aware
output looks like without running a live fetch.
"""

from __future__ import annotations

import hashlib
import json
import shutil
import tempfile
import time
from pathlib import Path


def _stage(cache_dir: Path, source: str, url: str, body: bytes) -> None:
    d = cache_dir / source
    d.mkdir(parents=True, exist_ok=True)
    key = hashlib.sha1(url.encode("utf-8")).hexdigest()
    (d / f"{key}.body").write_bytes(body)
    (d / f"{key}.meta").write_text(
        json.dumps({"url": url, "fetched_at": time.time(), "source": source}),
        encoding="utf-8",
    )


def _bgwiki_response_json(title: str, wikitext: str) -> bytes:
    payload = {
        "query": {
            "pages": [
                {"title": title, "revisions": [{"slots": {"main": {"content": wikitext}}}]}
            ]
        }
    }
    return json.dumps(payload).encode("utf-8")


def main() -> int:
    here = Path(__file__).resolve().parent
    audit_root = here.parent
    fixtures = audit_root / "tests" / "fixtures"
    refs = fixtures / "refs"

    with tempfile.TemporaryDirectory() as tmp:
        cache_root = Path(tmp) / "cache" / "refs"

        from tools.audit import audit_drops, audit_mob_pools
        from tools.audit.refs.bgwiki import BGWIKI_API, BGWikiClient
        from tools.audit.refs.ffxiclopedia import FFXICLOPEDIA_API, FFXIclopediaClient
        from tools.audit.refs.ffxidb import FFXIDBClient, ZoneMap

        # ---- BG Wiki cache: Goblin Tinkerer, River Crab
        for title, fname in [
            ("Goblin Tinkerer", "goblin_tinkerer.wikitext"),
            ("River Crab", "river_crab.wikitext"),
        ]:
            import urllib.parse
            params = {
                "action": "query", "prop": "revisions", "rvprop": "content",
                "rvslots": "main", "format": "json", "formatversion": "2",
                "titles": title, "redirects": "1",
            }
            url = f"{BGWIKI_API}?{urllib.parse.urlencode(params)}"
            wikitext = (refs / "bgwiki" / fname).read_text()
            _stage(cache_root, "bgwiki", url, _bgwiki_response_json(title, wikitext))

        # ---- FFXIclopedia cache: River Crab
        import urllib.parse
        params = {
            "action": "query", "prop": "revisions", "rvprop": "content",
            "rvslots": "main", "format": "json", "formatversion": "2",
            "titles": "River Crab", "redirects": "1",
        }
        url = f"{FFXICLOPEDIA_API}?{urllib.parse.urlencode(params)}"
        wikitext = (refs / "ffxiclopedia" / "river_crab.wikitext").read_text()
        _stage(cache_root, "ffxiclopedia", url, _bgwiki_response_json("River Crab", wikitext))

        # ---- FFXIDB cache: zoneid 100 / river-crab; LSB zoneid 1 maps to FFXIDB 100
        html = (refs / "ffxidb" / "river_crab.html").read_bytes()
        ffxidb_url = "http://www.ffxidb.com/zones/100/river-crab"
        _stage(cache_root, "ffxidb", ffxidb_url, html)

        bg = BGWikiClient(allow_fetch=False, cache_dir=cache_root)
        fc = FFXIclopediaClient(allow_fetch=False, cache_dir=cache_root)
        zm = ZoneMap(lsb_to_ffxidb={1: 100})
        ffxidb = FFXIDBClient(zone_map=zm, allow_fetch=False, cache_dir=cache_root)

        out_final = audit_root / "samples"
        tmp_out = Path(tmp) / "out"
        tmp_out.mkdir(parents=True, exist_ok=True)
        audit_mob_pools.run(
            fixtures / "local", fixtures / "upstream", tmp_out,
            with_refs=True, bgwiki_client=bg, ffxiclopedia_client=fc,
        )
        shutil.copyfile(tmp_out / "mob_pools_divergence.csv", out_final / "mob_pools_divergence_refs.csv")
        shutil.copyfile(tmp_out / "mob_pools_divergence.md", out_final / "mob_pools_divergence_refs.md")

        audit_drops.run(
            fixtures / "local", fixtures / "upstream", tmp_out,
            with_refs=True, bgwiki_client=bg, ffxidb_client=ffxidb,
        )
        shutil.copyfile(tmp_out / "mob_droplist_divergence.csv", out_final / "mob_droplist_divergence_refs.csv")
        shutil.copyfile(tmp_out / "mob_droplist_divergence.md", out_final / "mob_droplist_divergence_refs.md")

    print("Wrote reference-aware sample outputs under tools/audit/samples/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
