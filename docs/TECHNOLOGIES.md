# Technologies

This document lists every external dependency and runtime choice in the
project, what it is, why it's here, and how it's used. The goal is that any
engineer who clones the repo can reproduce or audit the stack without
guesswork.

## Runtime (the deployed website)

### Vanilla HTML, CSS, JavaScript
The whole site is one `index.html` with inline `<style>` and `<script>` tags.
- Why: no build step, no bundler, no framework, no dependency upgrades to
  chase. The site loads in one round trip and renders without JavaScript.
- How: edit `index.html` directly. There is no transpilation; the browser
  reads what you write.

### Google Fonts: Instrument Serif + Geist + Geist Mono
- Why: Instrument Serif gives the editorial weight to titles. Geist is a
  sharp neo-grotesque designed by Vercel; reads cleanly at any size. Geist
  Mono carries kickers, code, and stat labels.
- How: loaded via `<link rel="stylesheet" media="print" onload="this.media='all'">`
  with a `<noscript>` fallback. Non-blocking; the page paints with system
  fonts first, then upgrades.

### OKLCH + color-mix
- Why: predictable perceptual lightness across the whole gamut, makes
  light/dark contrast deterministic.
- How: every color in the design tokens uses `oklch(L C H)`. Hover states
  use `color-mix(in oklab, var(--accent) 12%, transparent)` for translucent
  accent washes.

### IntersectionObserver
- Why: trigger reveal/count-up/scramble animations only when the user
  reaches them, not on page load.
- How: one observer, threshold 0.15, rootMargin -60px from bottom. On
  intersection: add `.in-view`, run any nested counters or scrambles, then
  unobserve.

### CSS `prefers-reduced-motion` + `pointer: coarse`
- Why: respect the user's OS-level accessibility setting and don't run
  cursor effects on touch devices.
- How: every transition is shortened to 0.01ms inside the media query, and
  the JS reads both queries before registering cursor/magnetic/tilt
  handlers.

## Hosted assets (CDN hotlinks)

### `assets.zyrosite.com`
- What: Jorge's existing Zyro CDN from his previous site.
- Why: contains the personal portrait, brand logos (PayPal, Venmo, Flexera,
  Tienda UNAM, iOS Lab UNAM, Udemy), and tech stack icons. All are Jorge's
  own assets, hotlinking is safe.
- How: every image URL embeds the Cloudflare image-resizing transform
  (`/cdn-cgi/image/format=auto,w=W,h=H,fit=contain/...`) so the CDN serves
  the exact pixel size the layout needs.

### `capdesis.com/images/products/` and `/images/clients/`
- What: real Capdesis product logos and client brand marks.
- Why: removes the placeholder monogram look and gives the page real brand
  identity.
- How: hotlinked from `<img>` tags in the Capdesis section. Every image
  has an `onerror` handler that falls back to the two-letter monogram if
  the URL ever 404s.

## Local development tooling

### Bun
- Why: fast TypeScript-aware runtime with a built-in static server. The
  team standard across all Capdesis projects.
- How: `bun run dev` invokes `bunx serve . -l 3000` for local preview.
- Install: `curl -fsSL https://bun.sh/install | bash`

### lftp
- Why: parallel, resumable FTP mirror with exclude globs. Hostinger only
  exposes FTP; lftp handles concurrency and incremental upload cleanly.
- How: `bun run deploy` calls `scripts/deploy.sh`, which runs `lftp -u
  ${FTP_USER},${FTP_PASS} ${FTP_HOST}` with a `mirror --reverse --delete`
  command.
- Install: `brew install lftp`

### Python `http.server`
- Why: zero-dependency local probe in CI and during testing.
- How: `python3 -m http.server 8770 --bind 127.0.0.1 --directory .`
- Install: bundled with macOS.

### Playwright (used during development only)
- Why: visual verification of the rendered page across themes and viewports.
- How: invoked from the agent's MCP tool to take screenshots; never shipped
  with the site.

## Authoring conventions

### i18n keys
Every translatable string lives in two places: an `<element data-i18n="key">`
in the HTML, and the same `key` inside both `I18N.en` and `I18N.es`. The
EN dict is the source of truth; the HTML default text matches it. The
parity check (`docs/CHANGELOG.md` shows past runs) catches drift.

### CSS naming
BEM-ish: `.section-name`, `.section-name-element`, `.section-name-element--modifier`
(no `--modifier` in this codebase yet, but the naming would extend that way).
Custom properties are scoped to `:root` and overridden in
`[data-theme="light"]`.

### JavaScript style
- One IIFE wrapping the whole app
- `const` over `let`; never `var`
- No dependencies (zero `import`)
- Immediately frozen objects for any global write
- Explicit `null`-checks before touching DOM nodes that may not exist on
  every page (the same script runs on the landing and never breaks the CV
  pages because they don't load it)

## Outside the runtime

### git
Conventional commit messages are not enforced, but commits read like commit
messages, not changelogs. Every commit is authored as
`Jorge Salgado Miranda <54371626+chochy2001@users.noreply.github.com>` to
keep history consistent.

### GitHub
Repo lives at `github.com/chochy2001/jorgesalgadomiranda_landing`. SSH
remote, push to `main` deploys nothing automatically (CI/CD is intentional
manual via FTP for now).
