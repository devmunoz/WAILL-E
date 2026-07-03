#!/usr/bin/env sh

set -eu

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [target-project-path]
  curl -fsSL https://raw.githubusercontent.com/devmunoz/WAILL-E/main/install.sh | bash
  curl -fsSL https://raw.githubusercontent.com/devmunoz/WAILL-E/main/install.sh | bash -s -- /path/to/your/project

Installs WAILL-E into a project by downloading the latest release package.
EOF
}

REPO_OWNER="devmunoz"
REPO_NAME="WAILL-E"
ASSET_NAME="waill-e-package.tar.gz"
RELEASE_URL_DEFAULT="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest/download/${ASSET_NAME}"
RELEASE_URL="${WAILLE_RELEASE_URL:-$RELEASE_URL_DEFAULT}"

TARGET_DIR=${1:-"$PWD"}
TMP_DIR=""

cleanup() {
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}

trap cleanup EXIT INT TERM

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

TMP_DIR=$(mktemp -d)
ARCHIVE_PATH="$TMP_DIR/$ASSET_NAME"
EXTRACT_DIR="$TMP_DIR/extracted"
mkdir -p "$EXTRACT_DIR"

echo "Downloading WAILL-E package from latest release..."
curl -fsSL "$RELEASE_URL" -o "$ARCHIVE_PATH"

echo "Extracting package..."
tar -xzf "$ARCHIVE_PATH" -C "$EXTRACT_DIR"

if [ ! -f "$EXTRACT_DIR/WAILL-E.md" ]; then
  echo "Error: package does not contain WAILL-E.md" >&2
  exit 1
fi

if [ ! -d "$EXTRACT_DIR/.agents" ]; then
  echo "Error: package does not contain .agents directory" >&2
  exit 1
fi

if [ -f "$TARGET_DIR/AGENTS.md" ]; then
  cp "$EXTRACT_DIR/WAILL-E.md" "$TARGET_DIR/WAILL-E.md"

  if ! grep -Fq "WAILL-E.md](WAILL-E.md)" "$TARGET_DIR/AGENTS.md"; then
    printf "\nSee [WAILL-E.md](WAILL-E.md).\n" >> "$TARGET_DIR/AGENTS.md"
  fi

  echo "Copied WAILL-E.md and updated AGENTS.md reference."
else
  cp "$EXTRACT_DIR/WAILL-E.md" "$TARGET_DIR/AGENTS.md"
  echo "Copied WAILL-E.md to AGENTS.md."
fi

cp -R "$EXTRACT_DIR/.agents" "$TARGET_DIR/"
echo "Copied .agents directory."
echo "WAILL-E installation completed in: $TARGET_DIR"
