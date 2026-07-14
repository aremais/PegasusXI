# AGENTS.md

## Cursor Cloud specific instructions

This repo is a **LandSandBoat/PegasusXI Final Fantasy XI private server** plus a small marketing/account website. There are two products:

- **Game server (primary)** — C++20 executables (`xi_connect`, `xi_search`, `xi_world`, `xi_map`, `xi_test`) built via CMake+Ninja, backed by a MariaDB `xidb` database and Lua content in `scripts/`, `modules/`, `settings/`.
- **Website (secondary)** — Node/Express app at the repo root (`index.js`, `package.json`) that serves the static site in `public/` and proxies `/api` to an external `game-api` service.

The VM snapshot already has: apt build deps + MariaDB installed, the C++ server built (executables in the repo root), the `.venv` Python env, the `ximeshes` submodule checked out, prebuilt `navmeshes/*.nav`, and a fully populated `xidb`. The update script only refreshes Node + Python deps.

### Services and how to run them

Set these SQL env vars for every game-server process and Python tool (defaults in `settings/default/network.lua` are `root/root`, which do not match this VM):

```
export XI_NETWORK_SQL_HOST=127.0.0.1 XI_NETWORK_SQL_PORT=3306 \
       XI_NETWORK_SQL_LOGIN=xiadmin XI_NETWORK_SQL_PASSWORD=password \
       XI_NETWORK_SQL_DATABASE=xidb XI_NETWORK_ZMQ_IP=127.0.0.1
```

- **MariaDB is NOT auto-started.** Start it manually each session: `sudo service mariadb start`. Credentials: db `xidb`, user `xiadmin` / `password` (root uses unix_socket, so use `sudo mariadb` or the `xiadmin` user over TCP).
- **Build the C++ server** (only if sources changed; already built in snapshot). Requires gcc-14: `CC=/usr/bin/gcc-14 CXX=/usr/bin/g++-14 cmake -G Ninja -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j$(nproc)`. Executables are emitted to the repo root, not `build/`.
- **Run the game servers** (from repo root, with env above): start `./xi_world`, `./xi_connect`, `./xi_search`, then `./xi_map --log log/map-server.log --ip 127.0.0.1 --port 54230`. Each prints `... is ready to work`.
- **Website**: `PORT=3000 npm start` (serves `public/` on :3000). `/api` proxies to `game-api` on :4000, which is **not in this repo**, so register/login pages will 502 until that external service exists.

### Non-obvious gotchas

- **Map server needs zones on localhost.** The shipped DB points every zone at a documentation IP (`198.51.100.1`, from `sql/fix_zone_settings_public_ip.sql`). The map server needs `zoneip='127.0.0.1'` or it logs `Unable to load any zones!` (critical) and crashes. Already fixed in the snapshot via `UPDATE zone_settings SET zoneip='127.0.0.1' WHERE zoneport>0;`.
- **Map first-boot is slow.** `xi_map` builds `navmeshes/*.nav` from `ximeshes/*.ximesh` on first startup (~100s for 299 zones), then caches them. The `navmeshes/` directory must exist and `ximeshes/` (a git submodule) must be checked out.
- **`dbtool.py update` breaks on a fresh DB in this fork.** It imports `sql/*.sql` alphabetically, but several `fix_*.sql` / `patch_*.sql` migrations `INSERT` into base tables (`npc_list`, `mob_droplists`, `spell_list`, `status_effects`) that sort *after* them, so a from-scratch import errors out. The snapshot DB is already populated. To repopulate from scratch, import base-table dumps first, then `fix_*`/`patch_*` files, then `triggers.sql` last (this is why the DB was seeded manually rather than via `dbtool update`).
- **Python tooling lives in `.venv`.** Use `.venv/bin/python` for `tools/dbtool.py`, `tools/ci/startup_checks.py`, and `tools/headlessxi` (the `mariadb` pip package needs the system `libmariadb-dev`).

### Testing

- **Unit tests**: `./xi_test --keep-going --output log/tests.ctrf.json` (needs the SQL env vars). Note: on this fork ~51/380 tests fail (mission/exdata content tests) and it may crash during shutdown (`lua_close`) — these are pre-existing, not environment issues.
- **End-to-end startup + headless login**: `.venv/bin/python -m tools.ci.startup_checks` boots all four servers and, on Linux, logs a test character in via `tools/headlessxi` (`HXIClient`). It fails on any `error`/`warning`/`crash` line, so run it only against a clean build with the localhost zone fix applied.
- **Website**: `curl -s localhost:3000/` should return the `PegasusXI • Home` page.
- **Lint/CI helpers**: `tools/ci/sanity_checks.sh`, `tools/ci/lua_lang_server.py`, clang-tidy (see `dev.docker-compose.yml` / `docker/README.md`).
