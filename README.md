# jorgesalgadomiranda_landing

Personal website of Jorge Salgado Miranda · Software Architect · Mobile, Web & Security.

Live at [jorgesalgadomiranda.com](https://jorgesalgadomiranda.com/).

## At a glance

- Bilingual portfolio (ES default, EN toggle), light + dark theme, fully accessible
- Engineering practice section with the real architecture I ship
- Two print-ready CV pages (EN + ES) and a downloadable PDF
- Static HTML/CSS/JS, no framework, no build step, ~150 KB total
- Hosted on Hostinger, deployed by FTP

## Quick start

```bash
bun run dev      # serves http://localhost:3000
bun run deploy   # uploads the site to Hostinger via lftp
```

## Repository layout

```
jorgesalgadomiranda_landing/
├── index.html                            Self-contained landing (inline CSS, JS, i18n)
├── og.html                               Source for the Open Graph card
├── og.png                                1200x630 social card (rendered from og.html)
├── cv/
│   ├── Jorge_Salgado_Miranda_CV_EN.html  Print-ready CV in English
│   └── Jorge_Salgado_Miranda_CV_ES.html  Print-ready CV in Spanish
├── assets/
│   └── cv/
│       └── Jorge_Salgado_Miranda_CV.pdf  Downloadable PDF resume
├── scripts/
│   └── deploy.sh                         FTP deploy via lftp
├── docs/
│   ├── ARCHITECTURE.md                   Page structure, design tokens, JS modules
│   ├── TECHNOLOGIES.md                   Every tech on the page and why it is here
│   ├── DEPLOY.md                         Step-by-step deploy and rollback
│   └── CHANGELOG.md                      What shipped, ordered by commit
├── package.json                          Dev + deploy scripts (bun)
├── .env.example                          FTP credential template
├── .gitignore
└── README.md                             This file
```

## Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - how the page is composed
- [docs/TECHNOLOGIES.md](docs/TECHNOLOGIES.md) - every dependency and runtime choice
- [docs/DEPLOY.md](docs/DEPLOY.md) - production deploy procedure
- [docs/CHANGELOG.md](docs/CHANGELOG.md) - release log

## Design system

| Token        | Dark                   | Light                  |
|--------------|------------------------|------------------------|
| Background   | `oklch(0.14 0.008 240)` | `oklch(0.985 0.003 80)` |
| Foreground   | `oklch(0.97 0.005 240)` | `oklch(0.18 0.005 240)` |
| Accent       | `oklch(0.82 0.14 210)` (cyan) | `oklch(0.52 0.15 210)` |
| Serif        | Instrument Serif       |                        |
| Sans         | Geist                  |                        |
| Mono         | Geist Mono             |                        |

Theme is detected from system preference, togglable, persisted in `localStorage`.
Language is detected from `navigator.language`, togglable, persisted.

## Contributing

This is a personal portfolio, not an open source project. If you spot a typo or
broken link, open an issue or PR.

## License

All content (text, photo, CV) is copyrighted. Source is shared as a reference
for what a self-contained, single-file portfolio can look like.
