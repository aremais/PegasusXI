"""Polite, cached HTTP client used by the reference fetchers.

Design goals:

* **Cache first.** A request only hits the network if the cache is missing or
  stale. Cache directory layout is ``<root>/<source>/<sha1-of-url>.body`` plus
  a sibling ``.meta`` JSON file with the original URL and fetch timestamp.
* **Rate limit.** A per-source minimum interval between live fetches, enforced
  by sleeping. Default is conservative (1.0s).
* **Polite headers.** A descriptive ``User-Agent`` identifying the audit tool.
* **Bounded retries with backoff.** Up to ``max_retries`` retries on transient
  errors (URLError, 5xx, 429). Backoff is ``base * 2 ** attempt`` seconds.
* **Offline mode.** ``allow_fetch=False`` (or ``AUDIT_OFFLINE=1`` in env) raises
  :class:`OfflineCacheMiss` on cache miss instead of going to the network.
* **Stateless and pickle-free.** Cache entries are plain bytes plus JSON meta.
"""

from __future__ import annotations

import hashlib
import json
import os
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

DEFAULT_CACHE_DIR = Path(__file__).parent.parent / "cache" / "refs"
DEFAULT_USER_AGENT = (
    "PegasusXI-Audit/0.2 (+https://github.com/aremais/PegasusXI; tools/audit; contact via PR)"
)


class OfflineCacheMiss(FileNotFoundError):
    """Raised in offline mode when a URL is not present in the cache."""


class FetchError(RuntimeError):
    """Raised when a live fetch ultimately fails after retries."""


def env_offline() -> bool:
    return os.environ.get("AUDIT_OFFLINE", "").lower() in {"1", "true", "yes"}


@dataclass
class CachedResponse:
    url: str
    body: bytes
    from_cache: bool
    fetched_at: float

    def text(self, encoding: str = "utf-8") -> str:
        return self.body.decode(encoding, errors="replace")

    def json(self) -> dict:
        return json.loads(self.text())


class HttpClient:
    """Polite, cached HTTP GET client scoped to a single source name.

    Parameters
    ----------
    source : str
        Short name used to namespace the cache directory (e.g. ``"bgwiki"``).
    cache_dir : Path
        Cache root. Each source gets its own subdirectory.
    user_agent : str
        ``User-Agent`` header for live fetches.
    timeout : float
        Per-request timeout in seconds.
    rate_limit_s : float
        Minimum interval between consecutive live fetches from this client.
    max_retries : int
        Maximum number of retries on transient errors.
    backoff_base : float
        Backoff base in seconds; sleep = ``backoff_base * 2 ** attempt``.
    allow_fetch : bool
        If False, cache misses raise :class:`OfflineCacheMiss`.
    """

    def __init__(
        self,
        source: str,
        *,
        cache_dir: Path = DEFAULT_CACHE_DIR,
        user_agent: str = DEFAULT_USER_AGENT,
        timeout: float = 30.0,
        rate_limit_s: float = 1.0,
        max_retries: int = 3,
        backoff_base: float = 1.0,
        allow_fetch: bool = True,
    ) -> None:
        self.source = source
        self.cache_dir = Path(cache_dir) / source
        self.user_agent = user_agent
        self.timeout = timeout
        self.rate_limit_s = rate_limit_s
        self.max_retries = max_retries
        self.backoff_base = backoff_base
        self.allow_fetch = allow_fetch and not env_offline()
        self._last_fetch_ts: float = 0.0
        self.cache_dir.mkdir(parents=True, exist_ok=True)

    def _cache_key(self, url: str) -> str:
        return hashlib.sha1(url.encode("utf-8")).hexdigest()

    def _paths(self, url: str) -> tuple[Path, Path]:
        key = self._cache_key(url)
        return self.cache_dir / f"{key}.body", self.cache_dir / f"{key}.meta"

    def _load_cached(self, url: str) -> Optional[CachedResponse]:
        body_path, meta_path = self._paths(url)
        if not body_path.exists():
            return None
        body = body_path.read_bytes()
        fetched_at = 0.0
        if meta_path.exists():
            try:
                meta = json.loads(meta_path.read_text(encoding="utf-8"))
                fetched_at = float(meta.get("fetched_at", 0.0))
            except (ValueError, OSError):
                pass
        return CachedResponse(url=url, body=body, from_cache=True, fetched_at=fetched_at)

    def _write_cached(self, url: str, body: bytes) -> None:
        body_path, meta_path = self._paths(url)
        body_path.write_bytes(body)
        meta = {"url": url, "fetched_at": time.time(), "source": self.source}
        meta_path.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    def _respect_rate_limit(self) -> None:
        if self.rate_limit_s <= 0:
            return
        wait = (self._last_fetch_ts + self.rate_limit_s) - time.monotonic()
        if wait > 0:
            time.sleep(wait)

    def _is_transient(self, exc: BaseException) -> bool:
        if isinstance(exc, urllib.error.HTTPError):
            return exc.code in {408, 425, 429, 500, 502, 503, 504}
        if isinstance(exc, urllib.error.URLError):
            return True
        if isinstance(exc, TimeoutError):
            return True
        return False

    def get(self, url: str, *, headers: Optional[dict[str, str]] = None) -> CachedResponse:
        """Fetch ``url`` honoring cache, rate limit, retries, and offline mode.

        Returns a :class:`CachedResponse`. On unrecoverable failure raises
        :class:`FetchError` (live mode) or :class:`OfflineCacheMiss` (offline).
        """
        cached = self._load_cached(url)
        if cached is not None:
            return cached
        if not self.allow_fetch:
            raise OfflineCacheMiss(
                f"Offline mode: no cached entry for {url} under {self.cache_dir}"
            )

        merged_headers = {"User-Agent": self.user_agent, "Accept-Encoding": "identity"}
        if headers:
            merged_headers.update(headers)
        req = urllib.request.Request(url, headers=merged_headers)

        last_exc: Optional[BaseException] = None
        for attempt in range(self.max_retries + 1):
            self._respect_rate_limit()
            try:
                with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                    body = resp.read()
                self._last_fetch_ts = time.monotonic()
                self._write_cached(url, body)
                return CachedResponse(url=url, body=body, from_cache=False, fetched_at=time.time())
            except (urllib.error.URLError, TimeoutError) as exc:
                self._last_fetch_ts = time.monotonic()
                last_exc = exc
                if attempt >= self.max_retries or not self._is_transient(exc):
                    break
                sleep_for = self.backoff_base * (2 ** attempt)
                print(
                    f"[{self.source}] transient error on {url}: {exc!r}; "
                    f"retry {attempt + 1}/{self.max_retries} in {sleep_for:.1f}s",
                    file=sys.stderr,
                )
                time.sleep(sleep_for)
        raise FetchError(f"{self.source}: failed to fetch {url}: {last_exc!r}")
