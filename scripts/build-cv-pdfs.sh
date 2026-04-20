#!/usr/bin/env bash
# Build ATS-compatible PDFs from the HTML CVs using headless Chromium.
#
# Run this whenever you update cv/*.html. Checks in the PDFs under
# assets/cv/ so GitHub Actions deploys them to the live site automatically.
#
# Usage: bash scripts/build-cv-pdfs.sh
#
# Why headless Chromium and not wkhtmltopdf?
# Chromium renders the same @media print CSS you see in the browser;
# wkhtmltopdf is still stuck on Webkit-from-2014 and drops modern CSS.
# Chromium's PDF output is text-based with embedded fonts so ATS parsers
# extract text reliably (no OCR needed).
#
# Caveat: Chromium does NOT embed PDF /Info metadata (Author, Title, Subject)
# from the HTML <meta> tags. If you need that, post-process with `exiftool`:
#   exiftool -Author="Jorge Salgado Miranda" \
#            -Title="Jorge Salgado Miranda, Software Architect CV" \
#            -Subject="Senior Software Architect CV" \
#            assets/cv/Jorge_Salgado_Miranda_CV_EN.pdf

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CV_DIR="$REPO_ROOT/cv"
OUT_DIR="$REPO_ROOT/assets/cv"

mkdir -p "$OUT_DIR"

# Detect an available Chromium-based browser (macOS + Linux).
BROWSER=""
for candidate in \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
  "/Applications/Chromium.app/Contents/MacOS/Chromium" \
  "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
  "/Applications/Arc.app/Contents/MacOS/Arc" \
  "/usr/bin/google-chrome" \
  "/usr/bin/google-chrome-stable" \
  "/usr/bin/chromium" \
  "/usr/bin/chromium-browser" ; do
  if [ -x "$candidate" ]; then
    BROWSER="$candidate"
    break
  fi
done

# Also try anything on PATH
if [ -z "$BROWSER" ]; then
  for name in google-chrome chromium chromium-browser; do
    if command -v "$name" >/dev/null 2>&1; then
      BROWSER="$(command -v "$name")"
      break
    fi
  done
fi

if [ -z "$BROWSER" ]; then
  echo "Error: no Chromium-based browser found." >&2
  echo "Install Google Chrome, Brave, Microsoft Edge, or Chromium." >&2
  exit 1
fi

echo "Using browser: $BROWSER"

render() {
  local src="$1"
  local dst="$2"
  echo "Rendering $(basename "$src") -> $(basename "$dst")"
  "$BROWSER" \
    --headless=new \
    --disable-gpu \
    --no-sandbox \
    --hide-scrollbars \
    --no-pdf-header-footer \
    --virtual-time-budget=8000 \
    --run-all-compositor-stages-before-draw \
    --print-to-pdf-no-header \
    --print-to-pdf="$dst" \
    "file://$src" 2>/dev/null || {
      echo "  (retrying without --print-to-pdf-no-header, some Chromium builds differ)"
      "$BROWSER" \
        --headless=new \
        --disable-gpu \
        --no-sandbox \
        --no-pdf-header-footer \
        --virtual-time-budget=8000 \
        --run-all-compositor-stages-before-draw \
        --print-to-pdf="$dst" \
        "file://$src" 2>/dev/null
    }
}

render "$CV_DIR/Jorge_Salgado_Miranda_CV_EN.html" "$OUT_DIR/Jorge_Salgado_Miranda_CV_EN.pdf"
render "$CV_DIR/Jorge_Salgado_Miranda_CV_ES.html" "$OUT_DIR/Jorge_Salgado_Miranda_CV_ES.pdf"

# Default download = EN version (most recruiters/ATS expect English).
cp "$OUT_DIR/Jorge_Salgado_Miranda_CV_EN.pdf" "$OUT_DIR/Jorge_Salgado_Miranda_CV.pdf"

# Stamp PDF metadata if exiftool is available (optional but nice for ATS).
if command -v exiftool >/dev/null 2>&1; then
  for pdf in "$OUT_DIR"/Jorge_Salgado_Miranda_CV_EN.pdf \
             "$OUT_DIR"/Jorge_Salgado_Miranda_CV.pdf; do
    exiftool -overwrite_original \
      -Author="Jorge Salgado Miranda" \
      -Title="Jorge Salgado Miranda, Software Architect, CV" \
      -Subject="Senior Software Architect CV (EN)" \
      -Keywords="Software Architect, Mobile Engineer, iOS, Android, Flutter, Kotlin, Swift, Go, AWS, Security, Clean Architecture" \
      "$pdf" >/dev/null
  done
  exiftool -overwrite_original \
    -Author="Jorge Salgado Miranda" \
    -Title="Jorge Salgado Miranda, Arquitecto de Software, CV" \
    -Subject="CV de Arquitecto de Software Senior (ES)" \
    -Keywords="Arquitecto de Software, Mobile, iOS, Android, Flutter, Kotlin, Swift, Go, AWS, Seguridad, Clean Architecture" \
    "$OUT_DIR/Jorge_Salgado_Miranda_CV_ES.pdf" >/dev/null
  echo "PDF metadata stamped via exiftool."
else
  echo "Hint: install exiftool (brew install exiftool) to embed PDF Author/Title/Subject metadata."
fi

echo ""
echo "Built:"
ls -lh "$OUT_DIR"/*.pdf
echo ""
echo "Next: commit the refreshed PDFs so CI deploys them."
