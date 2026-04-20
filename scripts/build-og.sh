#!/usr/bin/env bash
# Render the Open Graph card (og.html) to og.png at exactly 1200x630 using
# headless Chromium.
#
# Run this whenever you update og.html (brand copy, stats, positioning).
# Commit the refreshed og.png so Cloudflare / social crawlers pick it up.
#
# Usage: bash scripts/build-og.sh
#
# Why headless Chromium? Same renderer as the preview, honours the same
# @font-face woff2 files, and produces a text-rich PNG with sub-pixel
# font antialiasing. No Node, no Puppeteer, no dependencies beyond a
# browser that ships on every dev laptop.
#
# Caveat: Chrome's --headless=new reserves ~87 invisible pixels inside
# --window-size on macOS (Chrome 147, stable across 120+). Asking for
# --window-size=1200,630 directly clips the bottom of the card because
# the body lays out at 630 but the effective viewport is ~543. We render
# at a taller window so the full 1200x630 body is visible, then crop the
# top 1200x630 with sips (built into macOS) / ImageMagick (Linux).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/og.html"
OUT="$REPO_ROOT/og.png"

# Requested output dimensions and the over-rendered window size that
# compensates for Chrome's reserved viewport area.
OUT_W=1200
OUT_H=630
RENDER_H=760  # > 630 + Chrome's ~87px reserve, with cushion

if [ ! -f "$SRC" ]; then
  echo "Error: $SRC not found." >&2
  exit 1
fi

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
echo "Rendering $(basename "$SRC") -> $(basename "$OUT") (${OUT_W}x${OUT_H})"

TMP_PNG="$(mktemp -t og_render.XXXXXX).png"
cleanup() { rm -f "$TMP_PNG"; }
trap cleanup EXIT

"$BROWSER" \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --hide-scrollbars \
  --force-device-scale-factor=1 \
  --run-all-compositor-stages-before-draw \
  --virtual-time-budget=5000 \
  --window-size=${OUT_W},${RENDER_H} \
  --screenshot="$TMP_PNG" \
  "file://$SRC" 2>/dev/null

if [ ! -f "$TMP_PNG" ]; then
  echo "Error: Chromium did not produce a screenshot." >&2
  exit 1
fi

# Crop the top OUT_W x OUT_H to get the OG card exactly.
crop_topleft() {
  local src="$1" dst="$2" w="$3" h="$4"
  if command -v sips >/dev/null 2>&1; then
    # sips --cropToHeightWidth HEIGHT WIDTH keeps the centre; offset it
    # to the top-left instead so we grab the visible body.
    sips --cropToHeightWidth "$h" "$w" --cropOffset 0 0 "$src" --out "$dst" >/dev/null
  elif command -v magick >/dev/null 2>&1; then
    magick "$src" -crop "${w}x${h}+0+0" +repage "$dst"
  elif command -v convert >/dev/null 2>&1; then
    convert "$src" -crop "${w}x${h}+0+0" +repage "$dst"
  else
    echo "Warning: no sips/magick/convert found; copying without crop." >&2
    cp "$src" "$dst"
  fi
}

crop_topleft "$TMP_PNG" "$OUT" "$OUT_W" "$OUT_H"

# Verify final dimensions.
if command -v sips >/dev/null 2>&1; then
  FINAL_DIMS="$(sips -g pixelWidth -g pixelHeight "$OUT" 2>/dev/null \
    | awk '/pixel(Width|Height)/ {print $2}' | paste -sd'x' -)"
  echo "Final PNG: $FINAL_DIMS"
fi

echo ""
echo "Built:"
ls -lh "$OUT"
echo ""
echo "Next: commit the refreshed og.png so CI deploys it."
