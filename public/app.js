/* Shared layout + small interactions */
const ABOUT_DROPDOWN = [
  { href: "server-info.html", label: "Server Info" },
  { href: "addons.html", label: "Addons" },
];
const TOOLS_DROPDOWN = [
  { href: "players.html", label: "Players" },
  { href: "seeking.html", label: "Seeking" },
  { href: "items.html", label: "Items" },
  { href: "bazaar.html", label: "Bazaar" },
  { href: "bcnm-ranking.html", label: "BCNM Ranking" },
  { href: "wiki.html", label: "Wiki" },
  { href: "yells.html", label: "Yells" },
];
const NAV = [
  { dropdown: true, label: "About", items: ABOUT_DROPDOWN },
  { href: "rules.html", label: "Rules" },
  { href: "news.html", label: "News" },
  { dropdown: true, label: "Tools", items: TOOLS_DROPDOWN },
];

function pathFile() {
  const p = (location.pathname || "").split("/").pop();
  return p || "index.html";
}

function navMarkup() {
  const file = pathFile();
  const deskItems = NAV.map(x => {
    if (x.dropdown) {
      const items = x.items.map(i => `<li><a href="${i.href}">${i.label}</a></li>`).join("");
      return `<li class="nav-dropdown"><button type="button" class="nav-dropdown-trigger" aria-expanded="false" aria-haspopup="true">${x.label} <span class="chevron" aria-hidden="true">▼</span></button><ul class="dropdown-menu" role="menu">${items}</ul></li>`;
    }
    const active = (x.href === file) ? "active" : "";
    return `<li><a class="${active}" href="${x.href}">${x.label}</a></li>`;
  }).join("");
  const desk = `<nav aria-label="Primary"><ul>${deskItems}</ul></nav>`;
  const mobileItems = NAV.flatMap(x => x.dropdown ? x.items : [x]);
  const mobileLinks = mobileItems.map(x => {
    const active = (x.href === file) ? "active" : "";
    return `<a class="${active}" href="${x.href}">${x.label}</a>`;
  }).join("");
  const mobile = `<div id="mobileMenu" class="mobile-menu" aria-label="Mobile navigation">${mobileLinks}</div>`;
  return { desk, mobile, links: deskItems };
}

function headerTemplate() {
  const { desk, mobile } = navMarkup();
  return `
  <header>
    <div class="container">
      <div class="nav">
        <div class="brand-wrap">
          <a class="brand" href="index.html" aria-label="PegasusXI Home">
            <img src="images/icon.png" alt="PegasusXI" class="brand-icon" width="48" height="48" />
          </a>
          <a class="brand-play" href="play-now.html">Play Now</a>
        </div>
        ${desk}

        <div class="nav-right">
          <div id="navStatus" class="nav-status" aria-live="polite">
            <span class="dot ok"></span><span class="nav-status-text">— Online</span>
          </div>
          <span class="nav-game-icon" aria-hidden="true"></span>
          <span class="nav-sep" aria-hidden="true"></span>
          <a class="nav-link" href="login.html">Login</a>
          <a class="nav-link" href="register.html">Register</a>
          <button class="btn hamburger" id="hamburger" aria-label="Open menu" aria-expanded="false">Menu</button>
        </div>
      </div>
      ${mobile}
    </div>
  </header>`;
}

function footerTemplate() {
  const y = new Date().getFullYear();
  const discordUrl = "https://discord.gg/DZC7RM9y";
  return `
  <footer class="site-footer">
    <div class="container">
      <div class="footer-sep"></div>
      <div class="footer-inner">
        <div class="footer-brand">
          <a href="index.html" class="footer-logo-wrap" aria-label="PegasusXI Home">
            <img src="images/icon.png" alt="" class="footer-logo" width="40" height="40" />
            <span class="footer-brand-text">PegasusXI</span>
          </a>
          <div class="footer-social" aria-label="Social links">
            <a href="${discordUrl}" target="_blank" rel="noopener noreferrer" aria-label="Discord" class="footer-social-icon">${discordIcon}</a>
            <a href="https://twitter.com/pegasusxi" target="_blank" rel="noopener noreferrer" aria-label="Twitter" class="footer-social-icon">${socialIcon("twitter")}</a>
            <a href="https://youtube.com/@pegasusxi" target="_blank" rel="noopener noreferrer" aria-label="YouTube" class="footer-social-icon">${socialIcon("youtube")}</a>
            <a href="https://twitch.tv/pegasusxi" target="_blank" rel="noopener noreferrer" aria-label="Twitch" class="footer-social-icon">${socialIcon("twitch")}</a>
            <a href="https://reddit.com/r/pegasusxi" target="_blank" rel="noopener noreferrer" aria-label="Reddit" class="footer-social-icon">${socialIcon("reddit")}</a>
          </div>
          <div class="footer-lang">English</div>
          <a href="https://crowdin.com" target="_blank" rel="noopener noreferrer" class="footer-translate">Help translate <span aria-hidden="true">❤</span></a>
        </div>
        <div class="footer-col">
          <h4 class="footer-heading">Information</h4>
          <ul class="footer-links">
            <li><a href="play-now.html">Play Now</a></li>
            <li><a href="server-info.html">Server Info</a></li>
            <li><a href="addons.html">Addons</a></li>
            <li><a href="privacy.html">Privacy Policy</a></li>
            <li><a href="rules.html">Rules</a></li>
            <li><a href="news.html">News</a></li>
            <li><a href="staff-coc.html">Staff Code of Conduct</a></li>
          </ul>
        </div>
        <div class="footer-col">
          <h4 class="footer-heading">Tools</h4>
          <ul class="footer-links">
            <li><a href="players.html">Players</a></li>
            <li><a href="seeking.html">Seeking</a></li>
            <li><a href="items.html">Items</a></li>
            <li><a href="bazaar.html">Bazaar</a></li>
            <li><a href="bcnm-ranking.html">BCNM Ranking</a></li>
            <li><a href="wiki.html">Wiki</a></li>
            <li><a href="yells.html">Yells</a></li>
          </ul>
        </div>
        <div class="footer-legal">
          <p class="footer-disclaimer">All FINAL FANTASY XI content and images ©2002–${y} SQUARE ENIX CO., LTD. FINAL FANTASY® is a registered trademark of SQUARE ENIX CO., LTD. PegasusXI staff are not affiliated with SQUARE ENIX CO., LTD. and have no ownership over any FINAL FANTASY XI content and images. Website images and artwork may not be used without permission of the artist. All rights reserved.</p>
        </div>
      </div>
    </div>
  </footer>`;
}

const discordIcon = `<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z"/></svg>`;

function socialIcon(name) {
  const icons = {
    twitter: '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>',
    youtube: '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/></svg>',
    twitch: '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M11.571 4.714h1.715v5.143H11.57zm4.715 0H18v5.143h-1.714zM6 0L1.714 4.286v15.428h5.143V24l4.286-4.286h3.428L22.286 12V0zm14.571 11.143l-3.428 3.428h-3.429l-3 3v-3H6.857V1.714h13.714Z"/></svg>',
    reddit: '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0zm5.01 4.744c.688 0 1.25.561 1.25 1.249a1.25 1.25 0 0 1-2.498.056l-2.597-.547-.8 3.747c1.824.07 3.48.632 4.674 1.488.308-.309.73-.491 1.207-.491.968 0 1.754.786 1.754 1.754 0 .968-.786 1.754-1.754 1.754-.431 0-.83-.157-1.137-.423a7.35 7.35 0 0 1-2.572 1.529l-.018 2.17 2.098.027v.077c0 .968.786 1.754 1.754 1.754.968 0 1.754-.786 1.754-1.754 0-.968-.786-1.754-1.754-1.754-.431 0-.83.157-1.137.423a7.332 7.332 0 0 1-2.537-1.553l-.016-2.054 2.074-.026c.065-.001.129-.004.193-.006 1.613-.063 3.2-.646 4.36-1.6.308.264.707.421 1.137.421.968 0 1.754-.786 1.754-1.754 0-.968-.786-1.754-1.754-1.754-.968 0-1.754.786-1.754 1.754 0 0 0 .754 1.596 7.364 7.364 0 0 1-2.01 1.352 7.26 7.26 0 0 1-1.438.14 7.364 7.364 0 0 1-2.01-1.352 1.754 1.754 0 0 0 .754-1.596c0-.968-.786-1.754-1.754-1.754-.968 0-1.754.786-1.754 1.754 0 .968.786 1.754 1.754 1.754.43 0 .83-.157 1.137-.421 1.16.954 2.747 1.537 4.36 1.6.064.002.128.005.193.006l2.074.026-.016 2.054a7.332 7.332 0 0 1-2.537 1.553c-.308-.266-.707-.423-1.137-.423-.968 0-1.754.786-1.754 1.754 0 .968.786 1.754 1.754 1.754.968 0 1.754-.786 1.754-1.754v-.077l2.098-.027.018-2.17a7.35 7.35 0 0 1-2.572-1.529c-.308.266-.707.423-1.137.423-.968 0-1.754-.786-1.754-1.754 0-.968.786-1.754 1.754-1.754.477 0 .899.182 1.207.491 1.194-.856 2.85-1.418 4.674-1.488l.8-3.747-2.597.547a1.25 1.25 0 0 1-2.498-.056c0-.688.562-1.25 1.25-1.25z"/></svg>'
  };
  return icons[name] || "";
}

function injectHeaderFixStyles() {
  if (document.getElementById("header-fix-styles")) return;
  const style = document.createElement("style");
  style.id = "header-fix-styles";
  style.textContent = [
    "header .nav{display:flex!important;flex-wrap:nowrap!important;align-items:center!important}",
    "header .brand-wrap{display:flex!important;flex-direction:row!important;flex-wrap:nowrap!important;align-items:center!important;gap:8px!important}",
    "header .brand-icon{width:48px!important;height:48px!important;max-width:48px!important;max-height:48px!important;display:block!important;object-fit:contain!important}",
    "header nav ul{display:flex!important;flex-wrap:nowrap!important;flex-direction:row!important;align-items:center!important}",
    "header .nav-dropdown{display:flex!important;flex-direction:column!important;align-items:flex-start!important}",
    "header .nav-dropdown .dropdown-menu{display:block!important;position:absolute!important;top:100%!important;left:0!important;opacity:0!important;visibility:hidden!important;pointer-events:none!important}",
    "header .nav-dropdown:hover .dropdown-menu,header .nav-dropdown.open .dropdown-menu{opacity:1!important;visibility:visible!important;pointer-events:auto!important}",
    "header .nav-dropdown .dropdown-menu li{display:block!important;width:100%!important}"
  ].join("");
  document.head.appendChild(style);
}

function mountLayout() {
  injectHeaderFixStyles();
  const headerMount = document.getElementById("siteHeader");
  const footerMount = document.getElementById("siteFooter");
  if (headerMount) headerMount.innerHTML = headerTemplate();
  if (footerMount) footerMount.innerHTML = footerTemplate();

  const burger = document.getElementById("hamburger");
  const mobileMenu = document.getElementById("mobileMenu");
  if (burger && mobileMenu) {
    burger.addEventListener("click", () => {
      const open = mobileMenu.style.display === "block";
      mobileMenu.style.display = open ? "none" : "block";
      burger.setAttribute("aria-expanded", String(!open));
    });
  }

  document.querySelectorAll(".nav-dropdown").forEach(wrap => {
    const trigger = wrap.querySelector(".nav-dropdown-trigger");
    const menu = wrap.querySelector(".dropdown-menu");
    if (!trigger || !menu) return;
    trigger.addEventListener("click", (e) => {
      e.stopPropagation();
      const open = wrap.classList.toggle("open");
      trigger.setAttribute("aria-expanded", String(open));
    });
  });
  document.addEventListener("click", () => {
    document.querySelectorAll(".nav-dropdown").forEach(w => {
      w.classList.remove("open");
      const t = w.querySelector(".nav-dropdown-trigger");
      if (t) t.setAttribute("aria-expanded", "false");
    });
  });
}

async function loadStatus() {
  const el = document.getElementById("serverStatus");
  const navEl = document.getElementById("navStatus");
  if (!el && !navEl) return;

  try {
    const res = await fetch("status.json", { cache: "no-store" });
    const data = await res.json();
    const ok = !!data.online;
    const dot = `<span class="dot ${ok ? "ok" : "bad"}"></span>`;
    const label = ok ? "Online" : "Offline";
    const players = (typeof data.playersOnline === "number") ? data.playersOnline : "—";
    const playersText = (typeof data.playersOnline === "number") ? `${data.playersOnline} Online` : "— Online";
    const updated = data.lastUpdate ? new Date(data.lastUpdate).toLocaleString() : "—";

    if (el) {
      el.innerHTML = `
        <div class="pill">${dot} <strong style="font-size:12px">${label}</strong> <span style="opacity:.8">·</span> ${players} online</div>
        <div class="small" style="margin-top:8px">Last update: <span class="kbd">${updated}</span></div>
      `;
    }
    if (navEl) {
      navEl.innerHTML = `${dot}<span class="nav-status-text">${playersText}</span>`;
    }
  } catch (e) {
    if (el) el.innerHTML = `<div class="pill"><span class="dot bad"></span> Status unavailable</div>`;
    if (navEl) navEl.innerHTML = `<span class="dot bad"></span><span class="nav-status-text">— Online</span>`;
  }
}

async function loadNewsList() {
  const mount = document.getElementById("newsList");
  if (!mount) return;

  try {
    const res = await fetch("news.json", { cache: "no-store" });
    const data = await res.json();
    const items = (data.posts || []).slice(0, 8);
    mount.innerHTML = items.map(p => `
      <article class="post">
        <div class="meta"><span>${p.date}</span><span>·</span><span>${p.tag}</span></div>
        <strong>${p.title}</strong>
        <p>${p.excerpt}</p>
      </article>
    `).join("");
  } catch (e) {
    mount.innerHTML = `<div class="small">No news available yet.</div>`;
  }
}

document.addEventListener("DOMContentLoaded", async () => {
  mountLayout();
  await loadStatus();
  await loadNewsList();
});
