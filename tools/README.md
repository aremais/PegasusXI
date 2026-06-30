Tools
========================

## Database Tool
`python dbtool.py`  
`python dbtool.py backup` - creates a whole database backup in `../sql/backups/`  
`python dbtool.py backup lite` - creates a backup only of tables defined in settings  
`python dbtool.py update` - performs an express update with backup and migrations if necessary  
`python dbtool.py update full` - performs a full update with backup and migrations  
`python dbtool.py migrate` - checks and performs any needed migrations  
`python dbtool.py ah-indexes` - apply auction house search indexes with per-index progress (or Maintenance Tasks → 6)  
`python tools/apply_ah_indexes.py` - same indexes, standalone script with progress output

### Server DB recovery (stuck AH / missing triggers)
Stop all `xi_*` processes, then from repo root:

`.\tools\recover_server.ps1` — kills stuck DB queries, installs required triggers, truncates auction house (fresh empty AH)

`.\tools\recover_server.ps1 -StartServers` — same, then launches connect/search/world/map

`.\tools\recover_server.ps1 -KeepAh` — skip AH truncate

`.\tools\recover_server.ps1 -WithIndexes` — also apply search indexes (can be slow)

`.\tools\import_lsb_mob_tables.ps1 -CloneFromGit` — import only LandSandBoat `base` mob SQL into xidb (stop `xi_*` first; prompts unless `-Force`)

This tool creates or connects to the database defined in `../settings/network.lua`. It 
allows the user to backup or restore the database, import any `custom.sql` 
stored in `../sql/backups/`, and import the latest SQL files provided by LandSandBoat 
Development. This tool also handles data migrations for character data.

## Price Checker
`python price_checker.py`

This tool checks NPC and guild shop prices to see if anything is being sold for less than the buyback price.

## Festive Moogle Tool
`python give_items.py`

This tool is used to distribute the following items:  
- Nomad Cap  
- Moogle Cap  
- Moogle Rod  
- Harpsichord  
- Stuffed Chocobo  
- Tidal Talisman  
- Destrier Beret  
- Pegasus Tunic  

## Announce
`python announce.py "<your message>"`

Sends `<your message>` to every character, in every zone, on every map process.  

Setup
========================

## Installing Python
`python3 --version` or `py -3 --version`

**This requires Python 3 and pip.**  
**Website:** https://www.python.org/downloads/  
Download the latest version from the website or check your package manager.

## Installing Dependencies
`pip install -r requirements.txt`

**MariaDB** - MariaDB is required to interact with the database.  
**GitPython** - GitPython is required to compare database versions.  
**PyYAML** - PyYAML is required to read/write settings.  
**Colorama** - Colorama is required to make colored terminal text.  
**zmq** - ZeroMQ is required for sending messages to the server.  
**Pylint** - Pylint is a static code analyser.  
**Black** - Black is a Python code formatter.  

## Other
`./install-systemd-service.sh` - Installs a systemd service for running the servers on Linux.  
`./run_clang_format.py` - Formats C++ code. Run from repo root.  
