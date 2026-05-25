"""FFXIclopedia (Fandom) MediaWiki API fetcher.

Endpoint: https://ffxiclopedia.fandom.com/api.php

API shape is identical to :mod:`bgwiki`, so we reuse the same client logic.
"""

from __future__ import annotations

from .bgwiki import BGWikiClient, WikiPage  # noqa: F401  (re-exported for callers)

FFXICLOPEDIA_API = "https://ffxiclopedia.fandom.com/api.php"
FFXICLOPEDIA_PAGE_BASE = "https://ffxiclopedia.fandom.com/wiki/"


class FFXIclopediaClient(BGWikiClient):
    """FFXIclopedia client. Same wire shape as BG Wiki; different cache namespace."""

    def __init__(self, *, allow_fetch: bool = True, **http_kwargs) -> None:
        super().__init__(api_url=FFXICLOPEDIA_API, allow_fetch=allow_fetch, **http_kwargs)
        self.http.source = "ffxiclopedia"
        new_dir = self.http.cache_dir.parent / "ffxiclopedia"
        new_dir.mkdir(parents=True, exist_ok=True)
        self.http.cache_dir = new_dir

    def _page_browse_url(self, title: str) -> str:
        import urllib.parse
        return FFXICLOPEDIA_PAGE_BASE + urllib.parse.quote(title.replace(" ", "_"))
