require("dotenv").config();
const path = require("path");
const express = require("express");
const { createProxyMiddleware } = require("http-proxy-middleware");

const PORT = Number(process.env.PORT) || 3000;
const GAME_API_URL = process.env.GAME_API_URL || "http://localhost:4000";
const GAME_API_SECRET = process.env.GAME_API_SECRET || "";
const STATIC_PATH = process.env.STATIC_PATH || path.join(__dirname, "public");

const app = express();

// Proxy /api/* to game-api (add secret header for server-to-server auth)
app.use(
  "/api",
  createProxyMiddleware({
    target: GAME_API_URL,
    changeOrigin: true,
    pathRewrite: { "^/api": "/api" },
    onProxyReq: (proxyReq) => {
      if (GAME_API_SECRET) {
        proxyReq.setHeader("X-API-Secret", GAME_API_SECRET);
      }
    },
    onError: (err, req, res) => {
      console.error("[proxy error]", err.message);
      res.status(502).json({ error: "API unavailable" });
    },
  })
);

// Serve static site (PegasusXI.com files)
// Set STATIC_PATH in .env to your site folder, e.g. C:\Users\arema\Documents\Current Projects\PegasusXI.com
app.use(express.static(STATIC_PATH));

app.listen(PORT, () => {
  console.log(`PegasusXI website server on http://localhost:${PORT}`);
  console.log(`  Static files from: ${STATIC_PATH}`);
  console.log(`  API proxy /api -> ${GAME_API_URL}`);
});
