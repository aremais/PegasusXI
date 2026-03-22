# PegasusXI Website Server

Serves the PegasusXI static site and proxies `/api/*` to the game-api.

## Setup

```bash
cd server
npm install
```

## Configure

Edit `.env`:

- **STATIC_PATH** – Path to your PegasusXI.com folder (optional).  
  If not set, serves from `server/public`.  
  Example (Windows): `STATIC_PATH=C:\Users\arema\Documents\Current Projects\PegasusXI.com`
- **PORT** – Website port (default 3000).
- **GAME_API_URL** – Game API base URL (default http://localhost:4000).
- **GAME_API_SECRET** – Must match `API_SECRET` in game-api `.env`.

## Run

1. Start the **game-api** first (in another terminal):

   ```bash
   cd ../game-api
   npm install
   npm start
   ```

2. Start this server:

   ```bash
   npm start
   ```

3. Open http://localhost:3000 (or your PORT). Login, register, and players will use the API.

## Static files

Either:

- Set **STATIC_PATH** in `.env` to your PegasusXI.com folder, or  
- Copy the contents of PegasusXI.com into `server/public`.
