#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
"$SCRIPT_DIR/setup-xcodebuildmcp-runtime.sh"

echo "Apple AppDev Workflow runtime is provisioned."
echo "Sosumi uses the plugin-declared streamable HTTP endpoint and needs no local Node runtime."
echo "Codex native memory is user-controlled; the plugin does not enable or edit it."
echo "XcodeBuildMCP MCP and CLI entrypoints:"
echo "  \"$SCRIPT_DIR/run-xcodebuildmcp.sh\" --help"
echo "  \"$SCRIPT_DIR/run-xcodebuildmcp.sh\" doctor"

CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
if [[ -f "$CODEX_HOME_DIR/memory.json" ]]; then
  echo "Legacy Memory MCP graph detected: $CODEX_HOME_DIR/memory.json"
  echo "Back it up and stage a native-memory migration note with:"
  echo "  /usr/bin/python3 \"$REPO_ROOT/scripts/migrate_memory_mcp_to_native.py\" --codex-home \"$CODEX_HOME_DIR\""
fi
