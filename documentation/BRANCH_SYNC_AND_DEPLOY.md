# PegasusXI Branch Sync & Deploy Guide

This document is the step-by-step runbook for keeping PegasusXI updated from LandSandBoat and promoting changes through **base → Test → Live**.

## Pipeline overview

```text
LandSandBoat/server (base)
        │
        │  1) Sync LSB into Base   (daily morning + manual)
        ▼
aremais/PegasusXI  base
        │
        │  2) Sync base into Test  (manual)  + changelog
        ▼
aremais/PegasusXI  Test
        │
        │  3) Deploy Test (BetaTest)  (manual)
        ▼
BetaTest game server  (downloads/builds Test)
        │
        │  4) Promote Test to Live  (manual, confirm PROMOTE)  + full changelog
        ▼
aremais/PegasusXI  Live   (identical to Test)
        │
        │  5) Deploy Live  (manual, or auto on push to Live)
        ▼
Live production game server
```

| Step | Workflow name in GitHub Actions | Trigger | What it does |
|------|----------------------------------|---------|--------------|
| 1 | **Sync LSB into Base** | Every day 08:00 UTC, or manual | Pulls new commits from [LandSandBoat/server](https://github.com/LandSandBoat/server) `base` into PegasusXI `base` |
| 2 | **Sync base into Test** | Manual only | Merges `base` → `Test`, keeps Test settings/custom workflows, writes changelog |
| 3 | **Deploy Test (BetaTest)** | Manual only | On the BetaTest server: `git pull` Test, build, restart processes |
| 4 | **Promote Test to Live** | Manual only (type `PROMOTE`) | Makes `Live` match `Test`, writes full changelog |
| 5 | **Deploy Live** | Manual, or automatic on push to `Live` | On the Live server: `git pull` Live, build, restart processes |

Actions page: https://github.com/aremais/PegasusXI/actions

---

## One-time setup (do this once)

### 1. Confirm branches exist

Your repo should have exactly these promotion branches:

- `base` — LSB mirror / integration branch (also the GitHub default branch)
- `Test` — BetaTest / QA branch
- `Live` — production branch

### 2. Keep the old bypass workflow disabled

**Sync upstream into Test** must stay **disabled**.  
That workflow skipped `base` and merged LandSandBoat straight into `Test`. The correct path is always LSB → `base` → `Test`.

Path: https://github.com/aremais/PegasusXI/actions/workflows/sync-upstream-to-test.yml

### 3. Register self-hosted runners

Deploy workflows use `runs-on: self-hosted`, so each game server needs a GitHub Actions runner app installed and online.

You need **admin access** to https://github.com/aremais/PegasusXI and **Administrator** PowerShell on each Windows server.

#### 3a. Prerequisites on each Windows server

Install these first (if missing):

1. **Git for Windows** — https://git-scm.com/download/win
2. **CMake** (added to PATH) — needed for the Deploy build steps
3. **Visual Studio Build Tools** or Visual Studio with **Desktop development with C++** (for `cmake -A x64`)
4. Outbound HTTPS access to `github.com`

Create a folder for the runner app (recommended):

```powershell
mkdir C:\actions-runner
```

#### 3b. Create the runner registration in GitHub

Do this once per machine (BetaTest, then Live):

1. Open https://github.com/aremais/PegasusXI/settings/actions/runners
2. Click **New self-hosted runner**
3. Choose:
   - **Operating system:** Windows
   - **Architecture:** x64
4. GitHub will show download + config commands with a **one-hour token**
5. Keep that page open while you configure the server (token expires in 1 hour)

#### 3c. Install on the BetaTest Windows server

On the **BetaTest** machine, open **PowerShell as Administrator**.

**Important:** On the GitHub “New self-hosted runner” page, copy the **Download** and **Extract** commands exactly (the version number changes over time). They look like this:

```powershell
cd C:\actions-runner

# Example only — prefer the commands GitHub shows you:
# Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/vX.XXX.X/actions-runner-win-x64-X.XXX.X.zip -OutFile actions-runner-win-x64-X.XXX.X.zip
# Add-Type -AssemblyName System.IO.Compression.FileSystem
# [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\actions-runner-win-x64-X.XXX.X.zip", "$PWD")
```

Then configure and register it. GitHub also shows this command with a real token already filled in — paste that whole line:

```powershell
.\config.cmd --url https://github.com/aremais/PegasusXI --token PASTE_TOKEN_HERE
```

When prompted, use answers like this:

| Prompt | Recommended answer |
|--------|--------------------|
| Runner group | press Enter (default) |
| Runner name | `betatest-server` |
| Additional labels | optional: `betatest` (not required) |
| Work folder | press Enter (`_work`) |
| Run as service? | `Y` (yes — so it survives reboots) |
| User account for service | press Enter (default) |

**Only after `config.cmd` finishes successfully**, start the runner.

First confirm the files exist:

```powershell
cd C:\actions-runner
dir *.cmd
```

You should see at least `config.cmd`, `run.cmd`, and `svc.cmd`.

Then start it (use `.\` in PowerShell):

```powershell
# Preferred: Windows service (survives reboot)
.\svc.cmd install
.\svc.cmd start

# Or run interactively in this window (stops when you close PowerShell):
.\run.cmd
```

If `config.cmd` already asked “Run runner as a service?” and you answered **Y**, the service may already be installed — just run:

```powershell
.\svc.cmd start
```

If `.\svc.cmd` is still “not recognized”, `config.cmd` was not completed or files were extracted to a different folder. Re-run the GitHub download/extract commands, then `.\config.cmd` again with a fresh token.

Confirm in GitHub:

1. Refresh https://github.com/aremais/PegasusXI/settings/actions/runners
2. You should see `betatest-server` with status **Idle** (green)
3. Labels should include `self-hosted`, `Windows`, `X64` — leave those enabled

#### 3d. Install on the Live Windows server

Repeat the same process on the **Live** machine, but use a different runner name:

```powershell
mkdir C:\actions-runner
cd C:\actions-runner

# Download + extract using the commands from a NEW "New self-hosted runner" page
# (get a fresh token — each machine needs its own)

.\config.cmd --url https://github.com/aremais/PegasusXI --token PASTE_NEW_TOKEN_HERE
```

| Prompt | Recommended answer |
|--------|--------------------|
| Runner name | `live-server` |
| Additional labels | optional: `live` |
| Run as service? | `Y` |

Then:

```powershell
.\svc.cmd install
.\svc.cmd start
```

Confirm `live-server` shows **Idle** on the runners page.

#### 3e. One physical host for both Test and Live? (optional)

If BetaTest and Live share the **same Windows machine** but different folders (`D:\server-test` and `D:\server`):

1. Install **one** runner is enough for both Deploy workflows
2. Name it something like `game-host`
3. Keep the default `self-hosted` label
4. When you run each Deploy workflow, set `repo_path`:
   - Deploy Test → `D:\server-test`
   - Deploy Live → `D:\server`

Only install two runners if they are **two different machines**.

#### 3f. Quick verification checklist

- [ ] https://github.com/aremais/PegasusXI/settings/actions/runners shows runner(s) **Idle**
- [ ] Each runner has the `self-hosted` label
- [ ] Runner service is set to **Automatic** start in Windows Services (`actions.runner.*`)
- [ ] Game repo folders exist (next section) before you run Deploy workflows

Useful service commands on the server:

```powershell
cd C:\actions-runner
.\svc.cmd status
.\svc.cmd stop
.\svc.cmd start
```

> Security note: self-hosted runners should only be used with this private repo. Do not enable them for untrusted forks/PRs.

### 4. Clone the repo on each game server

On **BetaTest** (example path used by the workflow default):

```powershell
git clone https://github.com/aremais/PegasusXI.git D:\server-test
cd D:\server-test
git checkout Test
git submodule update --init --recursive
```

On **Live** (example path used by the workflow default):

```powershell
git clone https://github.com/aremais/PegasusXI.git D:\server
cd D:\server
git checkout Live
git submodule update --init --recursive
```

If your folders differ, pass the correct path when you run the Deploy workflows (input: `repo_path`).

### 5. GitHub Environments

The repo uses:

- **Staging** — used by **Deploy Test (BetaTest)**
- **Production** — used by **Promote Test to Live** and **Deploy Live**

Optional but recommended in GitHub → Settings → Environments:

- Add required reviewers on **Production** so Live promote/deploy need approval
- Restrict **Production** to the Live server runner if you use runner groups

---

## Daily / release operator steps

### Step 1 — Sync LSB into Base (every morning)

Usually this runs automatically at **08:00 UTC**.

To run manually:

1. Open [Actions](https://github.com/aremais/PegasusXI/actions)
2. Click **Sync LSB into Base**
3. Click **Run workflow** → branch `base` → **Run workflow**
4. Open the run → read the **Summary** tab for the changelog

**Result**

- New LandSandBoat commits are merged into `base`
- Changelog is written to `changelogs/lsb-to-base-YYYY-MM-DD.md` and uploaded as an artifact
- On conflicts: LandSandBoat wins for source files; Pegasus `settings/` and workflow files are preserved

This step does **not** update Test, Live, or any game server.

---

### Step 2 — Sync base into Test (when you are ready to test)

1. Open [Actions](https://github.com/aremais/PegasusXI/actions)
2. Click **Sync base into Test**
3. Click **Run workflow** → **Run workflow**
4. Open the run → **Summary** for the merge changelog
5. Download the `base-to-test-changelog` artifact if you want a local copy

**Result**

- `base` is merged into `Test`
- Test-specific `settings/` are kept
- Existing custom Test workflows are kept; Pegasus-managed sync/deploy workflows are allowed to update
- Changelog committed as `changelogs/base-to-test-YYYY-MM-DD.md` on `Test`

**Your job after this step:** fix/test anything that broke on the Test branch / BetaTest server before promoting further.

---

### Step 3 — Deploy Test branch to the BetaTest server

1. Open [Actions](https://github.com/aremais/PegasusXI/actions)
2. Click **Deploy Test (BetaTest)**
3. Click **Run workflow**
4. Set `repo_path` if needed (default `D:\server-test`)
5. Run it and confirm the job succeeds

**What the server does**

1. Stops `xi_connect`, `xi_world`, `xi_map`, `xi_search`
2. `git fetch` + checkout `Test` + hard reset to `origin/Test`
3. Updates submodules
4. CMake configure + Release build
5. Starts the four processes again and verifies they are running

After this, BetaTest is running the same code that is on https://github.com/aremais/PegasusXI/tree/Test

---

### Step 4 — Promote Test to Live (only when Test is good)

This makes **Live match Test**. Divergent Live-only commits are discarded by design so the branches are identical.

1. Open [Actions](https://github.com/aremais/PegasusXI/actions)
2. Click **Promote Test to Live**
3. Click **Run workflow**
4. In **confirm**, type exactly: `PROMOTE`
5. Run the workflow
6. Read the **Summary** / download `test-to-live-changelog` for the full change list

**Result**

- Changelog is committed on `Test` as `changelogs/test-to-live-YYYY-MM-DD.md`
- `Live` is force-updated to that exact `Test` commit
- Workflow verifies `Test` and `Live` are **100% identical** (same SHA)

> Warning: this uses `--force-with-lease` on `Live`. Do not have long-lived unique work only on `Live`; all fixes should land on `Test` first.

---

### Step 5 — Deploy Live to the production server

You can do either:

**A. Manual (recommended while you are learning the flow)**

1. Open **Deploy Live**
2. Run workflow (set `repo_path` if not `D:\server`)

**B. Automatic**

- `Deploy Live` also triggers on pushes to the `Live` branch
- Completing Step 4 therefore can auto-start a Live deploy

**What the server does**

Same stop → pull `Live` → build → start sequence as BetaTest, against the Live checkout path.

After success, production is running https://github.com/aremais/PegasusXI/tree/Live

---

## Where to find changelogs

| Promotion | In the Actions run | In the git branch |
|-----------|--------------------|-------------------|
| LSB → base | Summary + artifact `lsb-to-base-changelog` | `base` → `changelogs/lsb-to-base-YYYY-MM-DD.md` |
| base → Test | Summary + artifact `base-to-test-changelog` | `Test` → `changelogs/base-to-test-YYYY-MM-DD.md` |
| Test → Live | Summary + artifact `test-to-live-changelog` | `Live` → `changelogs/test-to-live-YYYY-MM-DD.md` |

---

## Recommended release rhythm

1. **Morning:** let **Sync LSB into Base** run (or run it manually)
2. **When ready to QA:** run **Sync base into Test**, review the changelog, then **Deploy Test (BetaTest)**
3. **Playtest / fix on Test** until stable
4. **Go live:** run **Promote Test to Live** (`PROMOTE`), review the full changelog, confirm **Deploy Live** succeeded
5. At that point Test and Live should be the same commit SHA

---

## Manual server update (fallback without Actions deploy)

If a self-hosted runner is unavailable, you can update a server by hand:

```powershell
# BetaTest example
cd D:\server-test
# stop xi_* processes first
git fetch origin
git checkout Test
git reset --hard origin/Test
git submodule update --init --recursive
cmake -S . -B build -A x64
cmake --build build --config Release --parallel
# start xi_connect, xi_world, xi_search, xi_map
```

```powershell
# Live example
cd D:\server
# stop xi_* processes first
git fetch origin
git checkout Live
git reset --hard origin/Live
git submodule update --init --recursive
cmake -S . -B build -A x64
cmake --build build --config Release --parallel
# start xi_connect, xi_world, xi_search, xi_map
```

---

## Troubleshooting

### Sync LSB into Base fails

- Open the failed run log and check for unresolved conflicts
- Protected paths (`settings/`, `.github/workflows/`) keep the PegasusXI side; everything else prefers LandSandBoat
- If it still fails, merge locally on a branch from `base`, fix conflicts, PR into `base`, then re-run the workflow

### Sync base into Test says “already up to date”

- No new commits on `base` since the last sync — run Step 1 first, or there is simply nothing new

### Deploy cannot find `D:\server` / `D:\server-test`

- Clone the repo on that machine first (see one-time setup)
- Or pass the correct `repo_path` input when starting the workflow

### Deploy cannot find `xi_*.exe`

- Confirm the CMake build finished
- Check whether binaries landed in `build\bin\Release` or `build\Release`

### Promote Test to Live refused

- The confirm input must be exactly `PROMOTE` (case-sensitive)
- Production environment protection rules may be waiting for an approval

### Promote succeeded but Deploy Live did not start

- Check whether the self-hosted Live runner is online
- You can always run **Deploy Live** manually from the Actions tab

---

## Workflow files in this repo

| File | Workflow |
|------|----------|
| `.github/workflows/sync_lsb_to_base.yml` | Sync LSB into Base |
| `.github/workflows/sync-base-to-test.yml` | Sync base into Test |
| `.github/workflows/deploy-test.yml` | Deploy Test (BetaTest) |
| `.github/workflows/promote-test-to-live.yml` | Promote Test to Live |
| `.github/workflows/deploy-live.yml` | Deploy Live |

Do **not** re-enable `.github/workflows/sync-upstream-to-test.yml` for normal operations.
