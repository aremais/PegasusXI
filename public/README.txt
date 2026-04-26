PegasusXI Static Site (starter)

How to run locally:
- Option A (Python):  python -m http.server 8080
- Option B (Node):    npx serve .  (or: npm i -g serve then: serve .)

Then open:
- http://localhost:8080/index.html

Deploy:
- Any static host works (IIS, nginx, Cloudflare Pages, etc.)

Where to customize:
- styles.css: colors + flare look
- app.js: nav links + status/news loaders
- status.json: online/players/motd
- news.json: posts for News + homepage
