"""BG Wiki MediaWiki API fetcher and per-mob lookups.

Endpoint: https://www.bg-wiki.com/ffxi/api.php

We use ``action=query&prop=revisions&rvprop=content&rvslots=main&format=json``
which returns the latest revision's raw wikitext for a page. HTML pages are
protected by Cloudflare, but the API endpoint is open.

The cache lives under ``tools/audit/cache/refs/bgwiki/``. Each request URL
hashes to a single ``<sha1>.body`` file.
"""

from __future__ import annotations

import json
import urllib.parse
from dataclasses import dataclass
from typing import Optional

from .http_client import HttpClient, OfflineCacheMiss
from .wikitext import (
    DetectionParse,
    DropRateParse,
    find_detection_in_page,
    parse_drop_rates,
)

BGWIKI_API = "https://www.bg-wiki.com/ffxi/api.php"


@dataclass
class WikiPage:
    """Result of fetching a wiki page by title."""

    title: str
    url: str
    wikitext: Optional[str]
    missing: bool = False
    from_cache: bool = True

    def detection(self) -> DetectionParse:
        if not self.wikitext:
            return DetectionParse()
        return find_detection_in_page(self.wikitext)

    def drop_rates(self) -> list[DropRateParse]:
        if not self.wikitext:
            return []
        return parse_drop_rates(self.wikitext)


class BGWikiClient:
    """Fetcher for BG Wiki page wikitext via the MediaWiki API.

    Example
    -------
    >>> client = BGWikiClient(allow_fetch=False)  # offline / CI
    >>> page = client.get_page("Goblin Tinkerer")  # raises OfflineCacheMiss if not cached
    """

    def __init__(
        self,
        *,
        api_url: str = BGWIKI_API,
        allow_fetch: bool = True,
        **http_kwargs,
    ) -> None:
        self.api_url = api_url
        self.http = HttpClient("bgwiki", allow_fetch=allow_fetch, **http_kwargs)

    def _build_query_url(self, title: str) -> str:
        params = {
            "action": "query",
            "prop": "revisions",
            "rvprop": "content",
            "rvslots": "main",
            "format": "json",
            "formatversion": "2",
            "titles": title,
            "redirects": "1",
        }
        return f"{self.api_url}?{urllib.parse.urlencode(params)}"

    def _page_browse_url(self, title: str) -> str:
        # Best-effort browseable URL for human readers
        return f"https://www.bg-wiki.com/ffxi/{urllib.parse.quote(title.replace(' ', '_'))}"

    def get_page(self, title: str) -> WikiPage:
        """Return a :class:`WikiPage` for ``title``. Cache-first, network if allowed."""
        url = self._build_query_url(title)
        try:
            resp = self.http.get(url)
        except OfflineCacheMiss:
            return WikiPage(
                title=title,
                url=self._page_browse_url(title),
                wikitext=None,
                missing=True,
                from_cache=True,
            )
        try:
            data = resp.json()
        except json.JSONDecodeError:
            return WikiPage(
                title=title,
                url=self._page_browse_url(title),
                wikitext=None,
                missing=True,
                from_cache=resp.from_cache,
            )
        pages = data.get("query", {}).get("pages", [])
        if not pages:
            return WikiPage(
                title=title,
                url=self._page_browse_url(title),
                wikitext=None,
                missing=True,
                from_cache=resp.from_cache,
            )
        page = pages[0]
        if page.get("missing"):
            return WikiPage(
                title=title,
                url=self._page_browse_url(title),
                wikitext=None,
                missing=True,
                from_cache=resp.from_cache,
            )
        revisions = page.get("revisions", [])
        if not revisions:
            return WikiPage(
                title=title,
                url=self._page_browse_url(title),
                wikitext=None,
                missing=True,
                from_cache=resp.from_cache,
            )
        slots = revisions[0].get("slots", {})
        wikitext = slots.get("main", {}).get("content")
        if wikitext is None:
            wikitext = revisions[0].get("*")
        return WikiPage(
            title=page.get("title", title),
            url=self._page_browse_url(page.get("title", title)),
            wikitext=wikitext,
            missing=wikitext is None,
            from_cache=resp.from_cache,
        )
