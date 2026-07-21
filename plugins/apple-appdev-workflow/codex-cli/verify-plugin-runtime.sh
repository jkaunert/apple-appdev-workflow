#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
RUNTIME_DIR="${APPLE_APPDEV_WORKFLOW_RUNTIME_DIR:-$CODEX_HOME_DIR/plugin-runtime/apple-appdev-workflow}"
NODE_MODULES_BIN="$RUNTIME_DIR/node_modules/.bin"

missing=0

for bin in sosumi xcodebuildmcp xcodebuildmcp-doctor mcp-server-memory mcp-remote mcp-proxy; do
  if [[ ! -x "$NODE_MODULES_BIN/$bin" ]]; then
    echo "Missing plugin runtime binary: $NODE_MODULES_BIN/$bin" >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "Plugin runtime is incomplete in $RUNTIME_DIR. Run ./codex-cli/setup-plugin-runtime.sh first." >&2
  exit 1
fi

echo "Plugin runtime binaries look present:"
echo "  $NODE_MODULES_BIN/sosumi"
echo "  $NODE_MODULES_BIN/xcodebuildmcp"
echo "  $NODE_MODULES_BIN/xcodebuildmcp-doctor"
echo "  $NODE_MODULES_BIN/mcp-server-memory"
echo "  $NODE_MODULES_BIN/mcp-remote"
echo "  $NODE_MODULES_BIN/mcp-proxy"
