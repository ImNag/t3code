#!/bin/zsh

set -e

RELEASE_DIR="release"

# Trust the project's .mise.toml so non-interactive IDE shells don't block on a prompt.
if command -v mise >/dev/null 2>&1; then
  mise trust --quiet 2>/dev/null || true
fi

echo "Installing dependencies..."
bun install

echo "Cleaning ${RELEASE_DIR} folder..."
rm -rf "${RELEASE_DIR}"

echo "Building Mac ARM64 (M1) DMG..."
bun run dist:desktop:dmg:arm64

echo "Build complete. Artifacts in ${RELEASE_DIR}/"

DMG_FILE=$(find "${RELEASE_DIR}" -name "*.dmg" -type f | head -1)
if [ -n "${DMG_FILE}" ]; then
  echo "Opening ${DMG_FILE}..."
  open "${DMG_FILE}"
else
  echo "No .dmg file found in ${RELEASE_DIR}/"
fi
