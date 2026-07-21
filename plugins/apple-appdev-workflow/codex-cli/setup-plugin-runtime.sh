#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
RUNTIME_DIR="${APPLE_APPDEV_WORKFLOW_RUNTIME_DIR:-$CODEX_HOME_DIR/plugin-runtime/apple-appdev-workflow}"

if ! command -v node >/dev/null 2>&1; then
  echo "Missing Node.js. Install Node.js 18+ before provisioning plugin runtime dependencies." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "Missing npm. Install npm before provisioning plugin runtime dependencies." >&2
  exit 1
fi

mkdir -p "$RUNTIME_DIR"

cp "$REPO_ROOT/package.json" "$RUNTIME_DIR/package.json"
cp "$REPO_ROOT/package-lock.json" "$RUNTIME_DIR/package-lock.json"

cd "$RUNTIME_DIR"
npm ci

echo "Plugin runtime dependencies installed in $RUNTIME_DIR/node_modules"
echo "CLI fallbacks now available through:"
echo "  npm exec --prefix \"$RUNTIME_DIR\" -- sosumi --help"
echo "  npm exec --prefix \"$RUNTIME_DIR\" -- xcodebuildmcp --help"
echo "  npm exec --prefix \"$RUNTIME_DIR\" -- xcodebuildmcp-doctor"
echo "  npm exec --prefix \"$RUNTIME_DIR\" -- mcp-proxy --help"
