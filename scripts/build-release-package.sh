#!/usr/bin/env sh

set -eu

SCRIPT_DIR=$(
  CDPATH= cd -- "$(dirname "$0")" && pwd
)
REPO_ROOT=$(
  CDPATH= cd -- "$SCRIPT_DIR/.." && pwd
)

OUTPUT_DIR=${1:-"$REPO_ROOT/dist"}
ASSET_NAME="waill-e-package.tar.gz"

mkdir -p "$OUTPUT_DIR"

TMP_DIR=$(mktemp -d)
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

cp "$REPO_ROOT/WAILL-E.md" "$TMP_DIR/WAILL-E.md"
cp -R "$REPO_ROOT/.agents" "$TMP_DIR/.agents"

tar -czf "$OUTPUT_DIR/$ASSET_NAME" -C "$TMP_DIR" WAILL-E.md .agents

echo "Built release package: $OUTPUT_DIR/$ASSET_NAME"
