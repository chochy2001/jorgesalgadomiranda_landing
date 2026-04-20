#!/usr/bin/env bash
set -euo pipefail

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

: "${FTP_HOST:?FTP_HOST not set. Copy .env.example to .env and fill it in.}"
: "${FTP_USER:?FTP_USER not set}"
: "${FTP_PASS:?FTP_PASS not set}"
: "${FTP_REMOTE_DIR:=/public_html}"

if ! command -v lftp >/dev/null 2>&1; then
  echo "lftp not installed. brew install lftp" >&2
  exit 1
fi

echo "Uploading to $FTP_HOST:$FTP_REMOTE_DIR"

lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST" <<EOF
set ssl:verify-certificate yes
set ftp:ssl-force true
mirror --reverse \
  --delete \
  --verbose \
  --parallel=4 \
  --exclude-glob .git \
  --exclude-glob .git/ \
  --exclude-glob .github/ \
  --exclude-glob .env \
  --exclude-glob .env.example \
  --exclude-glob .env.local \
  --exclude-glob .gitignore \
  --exclude-glob .remember/ \
  --exclude-glob .playwright-mcp/ \
  --exclude-glob .idea/ \
  --exclude-glob .vscode/ \
  --exclude-glob node_modules/ \
  --exclude-glob scripts/ \
  --exclude-glob docs/ \
  --exclude-glob package.json \
  --exclude-glob package-lock.json \
  --exclude-glob bun.lockb \
  --exclude-glob README.md \
  --exclude-glob CLAUDE.md \
  --exclude-glob og.html \
  --exclude-glob verify-*.png \
  --exclude-glob *.log \
  --exclude-glob .DS_Store \
  ./ $FTP_REMOTE_DIR
bye
EOF

echo "Done."
