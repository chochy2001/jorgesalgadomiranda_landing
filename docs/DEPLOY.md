# Deploy

The site is hosted on Hostinger and deployed by FTP. This is intentional for
now: GitHub Actions billing has been an issue across the workspace and the
manual lftp deploy is fast enough (under a minute on a clean push).

## One-time setup

### 1. Install lftp
```bash
brew install lftp
```

### 2. Create your `.env`
Copy the template and fill in your real Hostinger FTP credentials:
```bash
cp .env.example .env
```
The `.env` file is gitignored. Never commit it.

```
FTP_HOST=ftp.jorgesalgadomiranda.com
FTP_USER=u123456789
FTP_PASS=your-real-password
FTP_REMOTE_DIR=/public_html
```

You can find the FTP credentials in the Hostinger panel:
**Files > FTP Accounts**.

### 3. Make the script executable (if it isn't)
```bash
chmod +x scripts/deploy.sh
```

## Deploy a new version

```bash
bun run deploy
```

This calls `scripts/deploy.sh` which:
1. Sources `.env` to load FTP credentials
2. Connects to the FTP host
3. Runs `mirror --reverse --delete` so the remote ends up exactly matching
   the local working tree
4. Excludes development-only files: `.git/`, `.env`, `.env.example`,
   `.gitignore`, `node_modules/`, `scripts/`, `package.json`, `README.md`,
   `.DS_Store`, `og.html`, `docs/`
5. Uploads in parallel (4 concurrent transfers)

A clean deploy takes 15-40 seconds depending on network.

## What gets uploaded

| File / Dir                          | Uploaded? | Reason                                |
|-------------------------------------|-----------|---------------------------------------|
| `index.html`                        | yes       | the site                              |
| `og.png`                            | yes       | Open Graph card                       |
| `cv/*.html`                         | yes       | print-ready CVs                       |
| `assets/cv/*.pdf`                   | yes       | downloadable PDF                      |
| `og.html`                           | no        | source for og.png, not needed live    |
| `docs/`                             | no        | repo documentation                    |
| `scripts/`                          | no        | local tooling                         |
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

This re-runs the same `mirror --reverse --delete` against the remote with
the old file tree, fully restoring it. Then you switch back to `main`
locally so future commits are based on current.

## Smoke test before deploy

```bash
python3 -m http.server 8765 --bind 127.0.0.1
# open http://127.0.0.1:8765/
```

Click through:
- **Hero**: title renders, code panel shows JSON without horizontal scroll
- **Theme toggle**: light <-> dark works, persists across reload
- **Lang toggle**: ES <-> EN works, the URL stays the same
- **About**: portrait visible, quick-facts box renders, 4 cards below
- **Engineering**: 6 cards with kicker (CIMIENTOS, ALCANCE, ...)
- **CV button**: opens cv/Jorge_Salgado_Miranda_CV_EN.html
- **PDF download**: assets/cv/Jorge_Salgado_Miranda_CV.pdf returns 200

## DNS

`jorgesalgadomiranda.com` -> Hostinger nameservers. CNAME for `www` -> apex.
HTTPS handled by Hostinger automatically.

## Pre-deploy checklist

- [ ] `git status` clean (working tree matches what you want shipped)
- [ ] Smoke test on `http://127.0.0.1:8765` passes
- [ ] i18n parity unchanged or improved (run the `EN={n}, ES={n}` Python
      one-liner from `CHANGELOG.md` examples)
- [ ] Commit, push to `main`, then `bun run deploy`
