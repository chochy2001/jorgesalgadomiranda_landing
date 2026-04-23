# GitHub Actions secrets

Full reference for every secret the `Deploy to Hostinger` workflow
reads. All secrets live under:

> `Settings > Secrets and variables > Actions > Repository secrets`

Last updated: 2026-04-23.

---

## TL;DR

Configure 3 required. 3 are optional, only for enabling integrations
that would otherwise stay on placeholder. Total: 6.

| Name | Status | What breaks without it |
|---|---|---|
| `FTP_HOST` | REQUIRED | Deploy cannot connect to Hostinger. |
| `FTP_USER` | REQUIRED | Deploy fails authentication. |
| `FTP_PASSWORD` | REQUIRED | Deploy fails authentication. |
| `UMAMI_WEBSITE_ID` | optional | Umami analytics script skips init (IIFE detects the `YOUR_` prefix). |
| `CF_BEACON_TOKEN` | optional | Cloudflare Web Analytics beacon skips init. |
| `WEB3FORMS_ACCESS_KEY` | optional | Contact form submit returns a rejection toast before sending. |

The optional ones are injected into `index.html` at deploy time,
replacing their respective `YOUR_*` placeholder strings. The committed
HTML stays token-free, so forks of this repo are still safe to run.

---

## Required: FTP credentials

These three were already configured when the deploy workflow was
first wired up. If one is missing or stale, the deploy aborts at the
`Sanitize FTP host` or `Deploy via FTPS` step.

### FTP_HOST

- **What:** bare hostname of your Hostinger FTP account.
- **Example value:** `ftp.jorgesalgadomiranda.com` (no scheme, no path,
  no trailing slash, no spaces). The workflow sanitizes extra characters
  but warns when it has to.
- **Where to find:** hPanel -> Files -> FTP Accounts.

### FTP_USER

- **What:** username of your Hostinger FTP account. Usually the
  Hostinger-generated string, not your email.
- **Where to find:** hPanel -> Files -> FTP Accounts.

### FTP_PASSWORD

- **What:** password for the FTP_USER account.
- **Rotation:** every 3 to 6 months, from hPanel. Update this secret
  right after and trigger a manual deploy to confirm.
- **Scope reminder:** Hostinger FTP users are chrooted to
  `public_html/` on this plan; the workflow uses `server-dir: ./` on
  purpose so files do NOT double-nest.

---

## Optional: production tokens injected at deploy

Each of these is a placeholder string in the committed HTML. The
workflow replaces the placeholder with the secret value right before
uploading, so the real token never lives in the repository.

If the secret is not set, the replacement is silently skipped and the
corresponding IIFE / form guard treats the placeholder as "not yet
configured" and does nothing.

### UMAMI_WEBSITE_ID

- **What:** Website ID from your self-hosted Umami at
  `stats.capdesis.com`.
- **Placeholder in HTML:** `YOUR_UMAMI_WEBSITE_ID` on
  `index.html` line 124 (inside the analytics IIFE).
- **Where to find:** stats.capdesis.com -> Settings -> Websites. A UUID
  like `01234567-89ab-cdef-0123-456789abcdef`.
- **Docs:** see `docs/MANUAL_SETUP.md` section 1.

### CF_BEACON_TOKEN

- **What:** token for the Cloudflare Web Analytics client beacon.
- **Placeholder in HTML:** `YOUR_CF_BEACON_TOKEN` on
  `index.html` line 125.
- **Where to find:** Cloudflare dashboard -> Analytics & Logs -> Web
  Analytics -> your site -> Manage Site -> copy the `token=` value from
  the JavaScript snippet.
- **Docs:** see `docs/MANUAL_SETUP.md` section 2b.

### WEB3FORMS_ACCESS_KEY

- **What:** access key for the Web3Forms free tier that powers the
  contact form.
- **Placeholder in HTML:** `YOUR_WEB3FORMS_ACCESS_KEY` on
  `index.html` line 1824 (hidden input in the contact form).
- **Where to find:** https://web3forms.com after signing up. Free tier
  is 250 submissions a month, delivered to the email associated with
  your Web3Forms account.
- **Docs:** see `docs/MANUAL_SETUP.md` section 4.

---

## Not managed through GitHub Secrets

Some values are NOT stored in GitHub because the deploy does not need
them. They live elsewhere:

| Value | Lives where | Why not in GitHub |
|---|---|---|
| Cal.com API key (`CAL_API_KEY`) | Local `.env` only (gitignored, chmod 600) | No CI automation reads it today. If that changes later, promote it to a secret. |
| Local FTP values for manual deploy | Local `.env` | `scripts/deploy.sh` reads them for the local fallback path. GitHub Actions uses the repo secrets. |
| Cloudflare API token / DNS token | Cloudflare dashboard | No CI operation needs it. |
| Hostinger account password | Hostinger hPanel | Account-level credential, not per-deploy. |

---

## How the workflow reads each secret

From `.github/workflows/deploy.yml`:

- Step `Sanitize FTP host` reads `FTP_HOST`.
- Step `Inject production tokens` reads `UMAMI_WEBSITE_ID`,
  `CF_BEACON_TOKEN`, `WEB3FORMS_ACCESS_KEY`. Each substitution is a
  Python call that reads the secret from the environment and rewrites
  `index.html` only if the env var is non-empty.
- Step `Deploy via FTPS` reads `FTP_USER` and `FTP_PASSWORD`.
- Step `Post-deploy smoke test` reads no secrets. It curls each key
  URL up to 3 times and fails the job if any path does not return 200.

---

## Rotation checklist

When you rotate any of the above:

1. Generate the new value in the upstream service (Hostinger panel,
   Umami, Cloudflare, Web3Forms).
2. In GitHub: `Settings > Secrets and variables > Actions >
   Repository secrets`, click `Update` on the existing entry and paste
   the new value. Do NOT delete and recreate, because the empty window
   between delete and create can make a concurrent deploy fail.
3. Trigger `workflow_dispatch` on the Deploy to Hostinger workflow to
   verify the new value works.
4. Confirm the live site is healthy via the smoke-test logs or by
   opening https://jorgesalgadomiranda.com/ in an incognito tab.

---

## Adding a new secret

If you add a new integration that needs a CI-side token:

1. Add the placeholder string to the relevant file (e.g.
   `YOUR_NEW_INTEGRATION_TOKEN`).
2. Add an entry to `.env.example` with the same name and the value
   `your-new-integration-token` as a documentation hint.
3. Add a step in `.github/workflows/deploy.yml` that substitutes the
   placeholder, following the same conditional pattern.
4. Add a row to this document and to `docs/MANUAL_SETUP.md`.
