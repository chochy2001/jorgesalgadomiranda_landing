# Tickets

Living audit log for `jorgesalgadomiranda.com`. Captures everything
that has shipped recently, what is in progress, and what is waiting on
the user so nothing slips between sessions.

Last refreshed: 2026-04-21.

---

## Legend

| Tag | Meaning |
|---|---|
| SHIPPED | Merged to main, deployed to production, verified live. |
| IN PROGRESS | Code exists or partial rollout, not fully done. |
| BLOCKED | Cannot progress without the user (credentials, manual action, pending content). |
| BACKLOG | Idea worth doing eventually, not scheduled. |
| WONTDO | Evaluated, decided against, documented so it stops getting re-proposed. |

Priority column: P0 critical, P1 high, P2 medium, P3 nice-to-have.

---

## SHIPPED 2026-04-21

| ID | Priority | Title | Why it mattered |
|---|---|---|---|
| T-001 | P0 | Fix mobile horizontal scroll by clipping html/body overflow-x | Tooltip on 108 px chip was pushing docScrollW to 410 px on a 390 px viewport, dragging the whole page left under the thumb. |
| T-002 | P0 | Hamburger drawer with focus trap, Escape close, auto-close on resize | Below 1060 px the full nav hid with no alternative. Site was unnavigable on mobile. |
| T-003 | P0 | Versioned asset URLs per deploy (workflow rewrites `assets/styles.css` to `...?v=SHA`) | Cloudflare had cached the pre-hamburger stylesheet for 7 days; new HTML met old CSS and the drawer links leaked unstyled into the top-left of the live page. |
| T-004 | P1 | Short-TTL HTML via .htaccess (`max-age=300, must-revalidate`) | HTML is the doc that carries the versioned asset URLs, so it must not be pinned by CDN edges for 24 h. |
| T-005 | P0 | CSP img-src allowlist devicon CDN, then swap to self-hosted | Strict CSP blocked 27 devicon logos with `violates the following Content Security Policy directive`. First loosened the allowlist, then self-hosted the SVGs under `assets/logos/` and re-tightened CSP. |
| T-006 | P1 | Self-host 22 devicon SVGs under `assets/logos/` | Removes a CDN dependency, removes a DNS lookup, shrinks CSP. Assets covered by the 6-month `mod_expires` rule. |
| T-007 | P2 | Remove draft legal pages from sitemap.xml | `/legal/privacy.html` and `/legal/terms.html` are still DRAFT. They should not be advertised to search engines until the user reviews the copy. |
| T-008 | P2 | Theme-color meta for dark and light | Mobile Chrome painting the address bar in the correct surface color, one less visual tell that this is a plain HTML site. |
| T-009 | P1 | Compress og.png 294 KB to 39 KB via pngquant | Social share previews now load instantly on slow networks. Dimensions preserved 1200x630. Quality band 75-92 kept visible fidelity. |
| T-010 | P1 | Rebuild `assets/cv/*.pdf` from the updated HTML CVs | The PDFs were drifting from HTML after the Venmo and Udemy content updates. Verified via `pdftotext`: VCC 2.0, GraphQL, Compose migration, Linux (Debian, Ubuntu, Kali), Udemy Senior Instructor all present. No em/en dashes. |
| T-011 | P2 | Typewriter animation on `.panel-body` with `contain: layout paint style` on the hero panel | Hero serif scramble was jittering the JSON panel sideways. Adding `contain` isolates the render tree; delaying the typewriter 2 s lets the scramble settle first. |

Verified live after Cloudflare purge:

- Drawer renders correctly.
- Stack logos visible in both the list and the tech-strip.
- OG card fetched fresh on Twitter and LinkedIn scrapers.
- CV PDFs are in sync with HTML content.

---

## BLOCKED, need user action

| ID | Priority | Title | What you have to do |
|---|---|---|---|
| T-101 | P2 | Paste LinkedIn certifications list so the Certifications section can cite real credentials instead of placeholder copy | Send me the list (title, issuer, year, credential URL if any). I will format it into the same card grid the section already uses. |
| T-102 | P3 | Validate the IngenieriaTracker "66 percent latency reduction" claim | Point me at the metric source (Grafana panel, internal doc, commit) so I can rephrase the case study with the real number and method. If the number is soft, we can replace with "materially faster" or drop the claim. |
| T-103 | P2 | Capture real Udemy reviews for the Udemy section | Needs a Playwright run with your authenticated Udemy instructor session, which I cannot do. You can either export reviews from the Udemy dashboard and paste them, or run a short scraping session locally and hand me the JSON. |
| T-104 | P1 | Add a Cloudflare Cache Rule for `*.css?*` and `*.js?*` to restore edge caching | Right now CF returns `cf-cache-status: DYNAMIC` for versioned asset URLs because default CF rules bypass cache when a query string is present. In CF dashboard: Caching, Cache Rules, create a rule matching `(http.request.uri.path.extension in {"css" "js"})` with Eligible for cache, TTL 1 week. This shaves ~50 ms off cold CSS loads. Optional but easy. |
| T-105 | P3 | Decide on the legal pages | Either publish them (remove the DRAFT banner, add a small footer link, re-include in sitemap), or leave them draft and do not link from anywhere. They are currently orphan URLs. |
| T-106 | P3 | Install `exiftool` once for PDF metadata stamping | `brew install exiftool`. The build script already detects and uses it to embed Author, Title, Subject, Keywords into the PDF `/Info` dictionary, which some ATS parsers read. Without it the PDFs still work, just without Info metadata. |

---

## BACKLOG

| ID | Priority | Title | Notes |
|---|---|---|---|
| T-201 | P3 | Split design tokens into `assets/tokens.css` | `styles.css` is 2723 lines. Tokens live in `:root` and `[data-theme="light"]` blocks. Extracting would shrink the main stylesheet and let other pages (404, CVs, legal) import the same token file. |
| T-202 | P3 | Self-host the tech logos hotlinked from `assets.zyrosite.com` | CLAUDE.md flags these as legacy-but-stable, user opted out for now. Revisit when the Zyro CDN finally dies. |
| T-203 | P3 | Replace the timeline expand animation with a CSS `interpolate-size: allow-keywords` implementation once Safari stable ships it | Current `grid-template-rows: 0fr -> 1fr` trick is fine, but `interpolate-size` would let us animate to `auto` with no hack. |
| T-204 | P3 | Add a `humans.txt` file | Classic attribution and fun easter egg. Owner, thanks, tech stack. |
| T-205 | P3 | Publish an atom feed if a writing section is ever added | Premature until content exists. |
| T-206 | P2 | Add a `downloads.json` or similar so the Cal.com CTA and CV download can be A/B tested | Only worth doing if we ever want to measure click-through. Today we have Umami and CF Web Analytics watching page views, but not per-CTA conversions. |

---

## WONTDO

| ID | Evaluated | Why we are not doing it |
|---|---|---|
| T-301 | Migrate to Astro | Current site is 37 KB total, FCP 640 ms, load 777 ms. Astro output for a single-page portfolio would be in the same ballpark. The cost is a Node build step, a rewrite of 2482 lines into components, and risk of breaking watermarks, animations, i18n timing, focus traps. Revisit only if we start publishing blog posts or multiple case studies. |
| T-302 | Self-host the Instrument Serif and Geist fonts from Google Fonts | Already self-hosted. |
| T-303 | Use a bundler | No runtime dependency, no bundler, no lockfile. Deploy is literally FTP upload of HTML + CSS + JS files. A bundler would add complexity without user-visible benefit. |

---

## How to add or update a ticket

1. Pick an unused ID in the right range (T-001 through T-099 shipped, T-101 through T-199 blocked, T-201 through T-299 backlog, T-301 through T-399 wontdo).
2. Fill in priority, title, context. For BLOCKED, write exactly what the user has to do, not a vague "ask user". For SHIPPED, write the pain you were relieving, not the fix itself (the commit message already explains the fix).
3. Keep the table compact. If a ticket needs more than a couple sentences, link to a doc under `docs/` or to a commit.
4. When a ticket ships, move it to SHIPPED with the same ID. When a ticket is abandoned, move to WONTDO with the rationale, not just a stub.
5. Update the "Last refreshed" line at the top.

---

## Related docs

- `docs/ARCHITECTURE.md` explains how the site is built.
- `docs/DESIGN_SYSTEM.md` explains the visual vocabulary.
- `docs/DEPLOY.md` explains the deploy flow and cache-bust mechanism.
- `docs/MANUAL_SETUP.md` is the user-only checklist for external service tokens.
- `CLAUDE.md` (gitignored) captures the hard rules for future-me.
