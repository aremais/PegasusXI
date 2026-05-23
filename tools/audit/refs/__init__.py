"""Reference-data fetchers and parsers for retail validation.

Submodules:

- ``http_client`` — shared HTTP client with cache, timeout, rate limit, retry, UA.
- ``bgwiki`` — BG Wiki MediaWiki API wikitext fetcher.
- ``ffxiclopedia`` — FFXIclopedia (Fandom) MediaWiki API wikitext fetcher.
- ``ffxidb`` — FFXIDB HTML drop-table scraper.
- ``wikitext`` — wikitext parsing (detection codes, drop rate templates).
- ``confidence`` — confidence bucket helpers (kill-count thresholds, agreement).

All fetchers honor an offline mode (``allow_fetch=False`` or env ``AUDIT_OFFLINE=1``)
that turns any cache miss into a clearly-labelled "no reference" result instead
of going to the network. This is what CI uses.
"""
