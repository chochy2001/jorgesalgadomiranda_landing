# Deploy

The site is hosted on Hostinger and deploys two ways, both via FTP:

1. **Automatic** on every push to `main` via GitHub Actions (preferred).
2. **Manual** from your laptop via `bun run deploy` (fallback if Actions
   billing is paused or you want to test before pushing).

## Automatic deploy: GitHub Actions

### Setup (once)

Go to `github.com/chochy2001/jorgesalgadomiranda_landing/settings/secrets/actions`
and create these **four repository secrets**:

| Secret name        | Example value        | Notes                                     |
|--------------------|----------------------|-------------------------------------------|
| `FTP_HOST`         | `ftp.jorgesalgadomiranda.com` or `files.hostinger.com` | Same value you'd put in an FTP client |
| `FTP_USER`         | `u1234567`           | Hostinger panel > Files > FTP Accounts     |
| `FTP_PASSWORD`     | `your-real-password` | Password from the same panel               |
| `FTP_REMOTE_DIR`   | `public_html`        | Relative path (no leading slash)           |

Exact names matter. The workflow at `.github/workflows/deploy.yml` reads
them as `${{ secrets.FTP_HOST }}`, etc.

### How it runs

Every push to `main` triggers the workflow. You can also trigger it
manually from the Actions tab using the "Run workflow" button (the
workflow is registered with `workflow_dispatch`).

Flow:
1. `actions/checkout@v4` pulls the repo.
2. `SamKirkland/FTP-Deploy-Action@v4.3.5` mirrors the working tree to the
   FTP server on port 21 (plain FTP; Hostinger doesn't offer FTPS).
3. The action uses the same exclude list as the local deploy script, so
   `.git*`, `.github/`, `docs/`, `scripts/`, `.env*`, `node_modules/`,
   `bun.lockb`, `package*.json`, `README.md` and `og.html` never leave
   the repo.

Typical duration: 30-60 seconds.

### Status checks

Watch the run live at
`github.com/chochy2001/jorgesalgadomiranda_landing/actions`.

If a run fails, the most common causes are:
- Wrong secret value (typo in the password, trailing whitespace).
- Hostinger FTP account temporarily rate-limited. The action retries
  within the same run.
- Concurrency lock from a still-running deploy. The `concurrency` block
  in the workflow serializes deploys so you won't race yourself.

## Manual deploy (fallback)

Requires `lftp` on your machine:

```bash
brew install lftp
cp .env.example .env
# fill in FTP_HOST, FTP_USER, FTP_PASS, FTP_REMOTE_DIR
bun run deploy
```

The script at `scripts/deploy.sh` uses the same exclude list as the
GitHub Actions workflow, so both deploy paths produce byte-identical
remotes.

## What gets uploaded

| File / Dir                          | Uploaded? | Reason                                |
|-------------------------------------|-----------|---------------------------------------|
| `index.html`                        | yes       | the site                              |
| `og.png`                            | yes       | Open Graph card                       |
| `cv/*.html`                         | yes       | print-ready CVs                       |
| `assets/cv/*.pdf`                   | yes       | downloadable PDF                      |
| `fonts/*.woff2`                     | yes       | self-hosted font files                |
| `og.html`                           | no        | source for og.png, not needed live    |
| `docs/`                             | no        | repo documentation                    |
| `scripts/`                          | no        | local tooling                         |
| `.github/`                          | no        | CI config                             |
| `.env*`, `.gitignore`, `.git/`      | no        | private / dev-only                    |
| `package.json`, `README.md`         | no        | repo metadata                         |

## Rollback

Hostinger does not give you per-file version history. If a deploy breaks
production, the cleanest rollback is:

```bash
git checkout <last-good-commit>
bun run deploy
git checkout main
```

This re-runs the same mirror against the remote with the old file tree,
restoring it. Then switch back to `main` locally so future commits are
based on current.

Alternatively, trigger the GitHub Actions workflow manually pointing at
the last-good commit via the "Run workflow" UI.

## Smoke test before deploy

```bash
python3 -m http.server 8765 --bind 127.0.0.1
# open http://127.0.0.1:8765/
```

Click through:
- Hero: title renders, code panel shows JSON without horizontal scroll
- Theme toggle: light <-> dark works, persists across reload
- Lang toggle: ES <-> EN works
- About: portrait visible, quick-facts box renders, 4 cards below
- Engineering: 6 cards with kicker (CIMIENTOS, ALCANCE, ...)
- CV button: opens `cv/Jorge_Salgado_Miranda_CV_EN.html`
- PDF download: `assets/cv/Jorge_Salgado_Miranda_CV.pdf` returns 200

## DNS

`jorgesalgadomiranda.com` -> Hostinger nameservers. CNAME for `www` ->
apex. HTTPS handled by Hostinger automatically.

## Pre-deploy checklist

- [ ] `git status` clean
- [ ] Smoke test on `http://127.0.0.1:8765` passes
- [ ] i18n parity unchanged or improved (run the `EN={n}, ES={n}` Python
      check from `CHANGELOG.md` examples)
- [ ] Commit, push to `main`, watch the Actions tab
