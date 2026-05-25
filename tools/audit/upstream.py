"""Fetch (or cache) upstream LandSandBoat SQL files for diffing.

By default we use raw.githubusercontent.com for the ``base`` branch. Caches
are written under ``tools/audit/cache/<branch>/<filename>`` and reused on
subsequent runs. Pass ``--no-fetch`` from the CLI to require an existing
cached copy; that mode is suitable for CI / hermetic tests.
"""

from __future__ import annotations

import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

UPSTREAM_REPO = "LandSandBoat/server"
UPSTREAM_BRANCH = "base"
UPSTREAM_URL_TMPL = "https://raw.githubusercontent.com/{repo}/{branch}/sql/{name}"

DEFAULT_CACHE_DIR = Path(__file__).parent / "cache"

AUDITED_FILES = [
    "mob_pools.sql",
    "mob_species_system.sql",
    "mob_pool_mods.sql",
    "mob_droplist.sql",
    "mob_groups.sql",
    "item_basic.sql",
]


def upstream_path(
    name: str,
    *,
    branch: str = UPSTREAM_BRANCH,
    cache_dir: Path = DEFAULT_CACHE_DIR,
    repo: str = UPSTREAM_REPO,
    allow_fetch: bool = True,
    timeout: float = 30.0,
) -> Path:
    """Return a local Path to the upstream copy of ``name``.

    If the file is already cached, return it. Otherwise, fetch over HTTPS
    (unless ``allow_fetch=False``). When ``allow_fetch`` is False and the
    file is missing, raises ``FileNotFoundError``.
    """
    target_dir = cache_dir / branch
    target_dir.mkdir(parents=True, exist_ok=True)
    target = target_dir / name
    if target.exists() and target.stat().st_size > 0:
        return target
    if not allow_fetch:
        raise FileNotFoundError(
            f"Upstream cache miss for {name}; rerun without --no-fetch or pre-populate {target}"
        )
    url = UPSTREAM_URL_TMPL.format(repo=repo, branch=branch, name=name)
    print(f"[upstream] fetching {url}", file=sys.stderr)
    try:
        with urllib.request.urlopen(url, timeout=timeout) as resp:
            data = resp.read()
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Failed to fetch {url}: {exc}") from exc
    target.write_bytes(data)
    return target


def ensure_all(
    *, branch: str = UPSTREAM_BRANCH, cache_dir: Path = DEFAULT_CACHE_DIR, allow_fetch: bool = True
) -> dict[str, Path]:
    return {
        name: upstream_path(
            name, branch=branch, cache_dir=cache_dir, allow_fetch=allow_fetch
        )
        for name in AUDITED_FILES
    }


def env_offline() -> bool:
    return os.environ.get("AUDIT_OFFLINE", "").lower() in {"1", "true", "yes"}
