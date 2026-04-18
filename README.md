# jorgesalgadomiranda_landing

Personal website of Jorge Salgado Miranda. Software Architect, Mobile · Web · Security.

Live at [jorgesalgadomiranda.com](https://jorgesalgadomiranda.com/).

## Stack

- Vanilla HTML / CSS / JS, no framework
- Instrument Serif · Geist · Geist Mono from Google Fonts
- Bilingual ES / EN (auto-detected, togglable, persisted in `localStorage`)
- Dark / light theme (auto-detected, togglable, persisted)
- Static hosting on Hostinger, deployed over FTP

## Structure

```
.
├── index.html                           Main landing page (self-contained: inline CSS + JS + i18n)
├── cv/
│   ├── Jorge_Salgado_Miranda_CV_EN.html Print-ready CV, English
│   └── Jorge_Salgado_Miranda_CV_ES.html Print-ready CV, Spanish
├── assets/
│   └── cv/
│       └── Jorge_Salgado_Miranda_CV.pdf Downloadable PDF resume
├── package.json                         Dev server + deploy scripts (bun)
└── scripts/
    └── deploy.sh                        FTP deploy to Hostinger
```

## Develop

```bash
bun run dev
```

Serves the site on `http://localhost:3000`.

## Deploy

Set FTP credentials in `.env` (see `.env.example`), then:

```bash
bun run deploy
```

This uploads the site to `public_html/` on Hostinger via `lftp`.

## Pending manual assets

- `og.png` (1200×630) for Open Graph / Twitter cards, referenced from the HTML
- Real brand logos for the Capdesis client cards (currently monogram placeholders)
