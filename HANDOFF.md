# Session Handoff, 2026-04-20

This file captures the state of the site after a very long session.
It exists so the next session starts fast and no context is lost.
Keep this file updated at the end of each session; delete entries that
ship.

## Latest round (2026-04-20, continuation)

Shipped in commits `3b64f8f` + anchor whitespace fix follow-up.

- **Mobile horizontal scroll fixed.** Root cause: `.tech-tip` tooltip
  (280px wide, centered on 108px chip) extended past the viewport in
  the engineering section, pushing `documentElement.scrollWidth` to
  410 on a 390 viewport. Fix: `html` and `body` now both use
  `overflow-x: clip` instead of only `body { overflow-x: hidden }`.
  Verified 375 on 390 iPhone 12 viewport post-fix.
- **Hamburger drawer for mobile nav.** New `.nav-burger` button appears
  at `<=1060px` alongside the existing language/theme toggles. Opens a
  right-side `.nav-drawer` with backdrop blur, 9 section links in serif
  large type, focus trap, Escape to close, backdrop click to close,
  auto-close on resize back to desktop. Hamburger icon animates into an
  X when expanded. `prefers-reduced-motion` honored.
- **JSON panel typewriter.** The `.panel-body` now reveals characters
  one by one via a text-node walker that preserves the existing span
  coloring (accent for keys, fg for strings, number color for nums).
  Total duration capped at 4.8s, measured 3.45s for current 313-char
  content. Caret blinks faster while typing, slower when done. Old
  per-span stagger fade-in CSS removed to avoid competing with the
  char reveal.
- **Section anchor top whitespace fix.** Click-to-section was leaving
  ~170px of dead space between the nav and the section heading (nav
  height 69 + scroll-margin-top 96 + section padding-top 144 stacking).
  Fix: set `section[id] { scroll-margin-top: 0 }` so hash-scroll aligns
  section top with viewport top, letting the section's own padding-top
  provide the visual gap under the nav. Tuned padding to
  `clamp(104px, 8vw, 132px)` so the gap between nav bottom and heading
  lands around 43-46px on mobile and desktop.

## Where the site stands right now

- Architecture split complete
  - `index.html` ~2000 lines (HTML shell + one inline app IIFE)
  - `assets/styles.css` (all CSS)
  - `assets/i18n.js` (EN + ES dicts, 335/335 keys with parity)
  - Fonts self-hosted in `fonts/`, referenced from CSS with `../fonts/`
- Hostinger deploy via GitHub Actions FTPS. Intermittent control-socket
  timeouts from Hostinger are known; rerun the workflow and it passes.

## What was done this session (summary of the last rounds)

### Content accuracy
- Removed fabricated certifications from the Earned list. Kept only
  `B.S. Computer Engineering, UNAM` and `Google Play Store Listing`.
  Meta Developer / Google Developer / Mobile Architecture were
  invented and have been dropped. A "More on LinkedIn" placeholder
  row now points to the profile.
- PayPal / Venmo timeline rewritten to reflect the real scope:
  - Role now reads `Senior Mobile Engineer, Venmo Credit Card`
  - Blurb ends in `Current performance rating: Exceeds Expectations`
  - Bullets cover Auth Users, Push Provisioning, `VCC 2.0 (Virtual
    Credit Card)` (fix: it was wrongly labelled BCC), XML-to-Compose
    migration, feature flags, GraphQL client, accessibility pass
- Flexera rewritten to Go + Postgres + AWS. Kafka dropped from
  everywhere because it is not used in production. Kotlin attribution
  removed from Flexera too, Jorge never used it there.
- Tienda UNAM kept but the native-mobile framing is preserved
- UNAM iOS Development Lab kept (mentor + student)
- Udemy normalized to 4 real courses across every surface
  (blurb, tag, contact link description, stats strip, course list)
  - Go, C, Git & GitHub, and the free Intro to Programming in Multiple
    Languages. C++ and Kotlin courses removed because they are not
    published under Jorge.
  - Stats strip: 54K+ students, 4 courses, 4.5 instructor rating,
    3,462 reviews. Course list renders with real Udemy URLs.
- Capdesis apps grid now has `Live` or `In development` status pills.
  Descriptions rewritten from the actual capdesis.com client pages
  (IngenieríaTracker, Formulae Pro & Community, CapMenu, CapLiving,
  Lo Más Fresh, CapTienda). Web projects (León Entertainment, OPUS,
  Artipublimex, Ancare, Xun-kaab, Finca SANRO) now carry the exact
  copy from their capdesis.com client pages, not fabrications.
- "And more in the lab: GestiónInventarioQR, IoT de domótica, ARKit
  prototypes, internal tools for clients" line was invented; removed.
  Only the "See the full portfolio on capdesis.com" link remains.
- "Senior team behind every project" dropped from Capdesis descriptions
  (social link + contact tier card + exp timeline were all fabricating
  an internal team). Replaced with specialist freelancers framing.
- Google Developers social link still shown (URL is real) but
  description rewritten to not claim credentials, since none of the
  earned badges were real.

### Testimonials
- Section reframed from "Testimonials" to "Feedback themes" with a
  lede clarifying the quotes are paraphrased recurring patterns, not
  direct quotes from named people, and that the cited numbers are
  verifiable.
- Six themes covering PayPal/Venmo, Tienda UNAM, Udemy students,
  Capdesis clients, Flexera, UNAM iOS Lab.
- Rotator has prev/next circular buttons, hairline dots, keyboard
  arrow nav, auto-rotate 9s, pauses on hover/focus/offscreen.
- Viewport min-height tuned so the controls stay put between slides.

### Social links
- Bare name list replaced with icon + serif name + description + CTA
  per platform. LinkedIn, GitHub, Capdesis (real logo), Udemy, YouTube,
  Google Developers (four-color G), WhatsApp.
- "Where you'll find me online" intro above the list.

### Direct email block
- Moved under the Cal.com CTA and Capdesis tier card inside the left
  column so the form no longer has dead space next to a short left
  column.
- Kicker `Direct email`, the email as a serif italic link, hint
  underneath.

### Form TOPIC select
- Native chrome stripped (`appearance: none`), custom SVG chevron,
  `padding-right: 44px`. Fixes the pegged-to-the-right arrow.

### Tech logo strip (section 05 proper)
- Grid of 20 chips with hover tooltips attributing each tech to real
  projects. Keyboard accessible via focus button overlay.
- gRPC and Next.js removed (not in use).
- Linux tooltip mentions Debian, Ubuntu, Kali specifically (not Arch).

### Stack section 05 overhaul
- Every `.stack-list li` now carries a `.stack-tip` tooltip with:
  short domain label (e.g. "Android core") and a one-paragraph
  description naming the real projects + context (e.g. Kotlin / Compose
  is attributed to Venmo Credit Card and Tienda UNAM, with the XML to
  Compose migration called out; Self-hosted VPS + Tailscale describes
  the actual 2-VPS Capdesis mesh; AWS lists the real services used at
  Flexera One).
- 36 tooltips injected via a Python one-shot. All 6 columns covered.

### Experience timeline, collapsible
- Each `.tl-item` is now expandable. Default state is the first (most
  recent) item open, the rest collapsed showing only the meta +
  role + blurb.
- Click or keyboard Enter/Space toggles. `aria-expanded` and
  `aria-controls` wired. CSS uses `grid-template-rows: 0fr` -> `1fr`
  trick for smooth height animation, with `prefers-reduced-motion`
  opt-out.
- Udemy item also got 3 bullets + chips so every card has something to
  expand.

### Hero JSON panel
- `runScramble` duration extended (min 900ms, scales with length).
- `.panel-body::after` blinking caret, CSS `@keyframes blink`.
- Staggered fade-in of each code key/string inside the panel so it
  animates in like it's being populated progressively.
- New `runTypewriter` helper available for future use (not yet
  wired to any element).

### Responsive + grammar pass
- Nav: transitional breakpoint at 1100px tightens link padding; collapse
  at 1060px so ES/EN + theme toggle no longer overflow at iPad landscape.
  Brand text hides below 620px.
- Section kicker: switched to `flex-wrap`, tighter at <=480px. Fixes
  horizontal scroll at 360 and 390.
- Removed redundant `.web-thumb-tag` overlay (both it and `.web-badge`
  were rendering, looked duplicated).
- Grammar: `Lead a team` -> `Leading a team`. `toda México` -> `todo
  México`. `Cap Living` -> `CapLiving`. Oss intro comma splice fixed.
- `cert.title2` HTML fallback aligned with i18n value.

### Marquee
- Two explicit `.marquee-group` containers with identical content, grid
  sized so `translateX(-50%)` lands pixel-perfect. Pauses on hover.

## Known pending work (for next session)

Priority ordered. High at top.

### H1, finish the "microanimations pass" the user asked for
- JSON panel typewriter is now live (shipped 2026-04-20). Section titles
  could still get a letter-by-letter reveal using the same node walker
  pattern applied to `.section-title em`.
- Card hover lift everywhere (engineering, cases, apps grid, web grid)
  should be consistent. Today they're close but slightly different.
- Button press state (scale 0.98) missing on `.btn-primary`, `.btn-ghost`,
  `.cal-cta`, form submit, testimonial nav.
- Timeline: when opening an item, animate the bullet points in with a
  staggered fade (they currently just appear because `.tl-body` does
  one big height transition).

### H2, finish the stack overhaul the user specifically asked for
- Add inline logos for every stack item (Kotlin glyph, Swift bird,
  AWS cube, etc.). Today only the `.tech-strip` (between Stack and OSS)
  has logos. The 36 `.stack-list li` entries carry tooltips but no
  logos next to the name.
- Source: `https://cdn.jsdelivr.net/gh/devicons/devicon/icons/<name>/<name>-original.svg`
  already used for some entries in the tech-strip.
- Layout: insert a small 18x18 logo slot before the name in each li,
  keep the level badge on the right.

### H3, design system extraction + docs
- User wants documented reusable components. Proposed structure:
  - `docs/DESIGN_SYSTEM.md` with a one-pager per component
  - Components to extract and document:
    - Section head (num + kicker)
    - Section title (span + em serif)
    - Stack chip (name + level badge + tooltip)
    - Cert item (numbered roster)
    - App card (icon + body + pills + link)
    - Web card (thumb + badge + body)
    - Contact link row (icon + body + CTA + arrow)
    - Testimonial slide (quotemark + blockquote + attribution)
    - Timeline item (marker + content, collapsible)
    - Tech chip (logo + name + hover tooltip)
    - Button primary, button ghost, cal-cta, toggle
  - For each: markup, required tokens, hover state, click state,
    responsive rules, when to use it, when not to.
- Extract design tokens into `assets/tokens.css` imported first.

### H4, responsive granularity
- **Mobile horizontal scroll + hamburger drawer shipped 2026-04-20**
  (see Latest round). Mobile is now scroll-free at 390 and the
  hamburger covers all 9 section links.
- User called out that the contact social list and the web projects
  grid could go 2-column in intermediate widths (850 to 1100) instead
  of staying 1-column. Audit and add auto-fill / auto-fit grids where
  they make sense.
- Audit log in `.playwright-mcp/` has screenshots at 360, 390, 768,
  1024, 1280, 1920, 2560, 3440 from the previous responsive sweep.
- Remaining issues from that audit:
  - Web project cards at 768 have ~450px of empty gradient space,
    single-column looks too padded.
  - Content locked at ~1280 max on 2560 and 3440 ultrawide. Decide
    whether to let the layout breathe on ultrawide or keep the
    editorial look.

### H5, LinkedIn certs sync
- Agents cannot scrape LinkedIn without auth (blocked by authwall).
- User will paste the cert list from
  `https://linkedin.com/in/jorge-salgado-miranda-74023b181/details/certifications/`
- Once pasted, replace the placeholder "More on LinkedIn" row with
  the real entries, keep the B.S. UNAM and Google Play Store Listing
  rows that are already correct.

### H6, stack copy updates from the CV
- User confirmed adding: `Riverpod`, `Kotlin Flows`, `RxJava / RxSwift`
- User said don't remove anything from the stack; only add.
- React Native is in the CV. Keep. Do not claim prod use.

### H7, Udemy review capture
- Udemy blocks HTTP scrapers. To pull real 5-star reviews verbatim the
  next session should try Playwright MCP with a signed-in session
  (user has to authorize), fetch 2-3 reviews per course, replace the
  Feedback-theme 3rd slide with a real quote.

### H8, CV update
- The printed `cv/Jorge_Salgado_Miranda_CV_EN.html` and `_ES.html` are
  now out of sync with the landing. They still say:
  - 6 Udemy courses (should be 4)
  - 50/50 iOS and Android at Venmo (user said Android-specialized)
  - Kafka in Flexera (not used)
  - Linux (Arch) (it is Debian / Ubuntu / Kali)
  - 66% latency reduction at IngenieríaTracker (needs validation)
- Next session: do the same rewrite pass on the CVs, rebuild PDFs via
  `bash scripts/build-cv-pdfs.sh`, and verify the extracted text.

### H9, color + depth
- User feedback: "la página se ve muy plana y hay muy pocos colores".
- Proposed: introduce a secondary accent (warm gold or muted lime) for
  callouts. Reserve the cyan for primary. Add subtle gradients to the
  hero panel and tier card without turning the whole thing into a
  marketing page.

### H10, Design System ticket discipline
- User mentioned they've already been writing tickets per sprint.
  Consider adding a `docs/TICKETS.md` or a Linear import list so the
  landing repo has visibility into the backlog.

## Placeholders still in `index.html` that require user-side action

See `docs/MANUAL_SETUP.md` for the full list and how to set each one.
Snapshot:
- `YOUR_UMAMI_WEBSITE_ID`, analytics
- `YOUR_CF_BEACON_TOKEN`, analytics
- `YOUR_WEB3FORMS_ACCESS_KEY`, contact form
- `jorgesalgadomiranda/30min`, Cal.com slug may need update

Every one of these is behind an `if (!startsWith("YOUR_"))` guard so
the page runs without them, just without analytics or a working form.

## Session-to-session hygiene

- `CLAUDE.md` at repo root is gitignored, up to date with the new
  architecture (2000-line shell + external CSS/JS) and with the i18n
  parity check that reads from `assets/i18n.js`.
- The auto-memory at `~/.claude/.../memory/project_personal_landing.md`
  was updated earlier in this session to reflect the new architecture
  and the redesign pass.
- Commits are authored by chochy2001, no AI references, no em or
  en-dashes in shipped copy.
