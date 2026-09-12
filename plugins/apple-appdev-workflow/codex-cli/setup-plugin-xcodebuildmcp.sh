#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
FORCE_RUNTIME=0
CHECK_ONLY=0

usage() {
  cat <<'EOF'
Usage: setup-plugin-xcodebuildmcp.sh [options]

Options:
  --codex-home PATH  Codex home whose config is checked/reconciled.
  --force-runtime    Preserve and replace an existing nonmatching shared runtime.
  --check            Diagnose only; do not install or change configuration.
  -h, --help         Show this help.

This provisions the exact promoted, shared XcodeBuildMCP portable runtime and
removes only global XcodeBuildMCP tables that would shadow the plugin-owned MCP.
Every changed config receives a timestamped rollback backup. Other MCP servers,
PATH entries, Malt, Homebrew, and globally installed binaries are untouched.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codex-home)
      TARGET_CODEX_HOME="${2:-}"
      shift 2
      ;;
    --force-runtime)
      FORCE_RUNTIME=1
      shift
      ;;
    --check)
      CHECK_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ -n "$TARGET_CODEX_HOME" ]] || { echo "error: --codex-home cannot be empty" >&2; exit 2; }
CONFIG_FILE="$TARGET_CODEX_HOME/config.toml"
PYTHON_BIN="${APPLE_APPDEV_XCODEBUILDMCP_PYTHON_BIN:-/usr/bin/python3}"

if [[ "$CHECK_ONLY" == "1" ]]; then
  "$PYTHON_BIN" "$PLUGIN_ROOT/scripts/check_xcodebuildmcp_runtime_lock.py" \
    --probe-launcher "$SCRIPT_DIR/run-xcodebuildmcp.sh"
  "$PYTHON_BIN" "$PLUGIN_ROOT/scripts/reconcile_plugin_xcodebuildmcp_registration.py" \
    --config "$CONFIG_FILE" \
    --check
  exit 0
fi

if [[ "$FORCE_RUNTIME" == "1" ]]; then
  "$SCRIPT_DIR/setup-xcodebuildmcp-runtime.sh" --force
else
  "$SCRIPT_DIR/setup-xcodebuildmcp-runtime.sh"
fi
"$PYTHON_BIN" "$PLUGIN_ROOT/scripts/reconcile_plugin_xcodebuildmcp_registration.py" \
  --config "$CONFIG_FILE" \
  --apply
"$PYTHON_BIN" "$PLUGIN_ROOT/scripts/check_xcodebuildmcp_runtime_lock.py" \
  --probe-launcher "$SCRIPT_DIR/run-xcodebuildmcp.sh"

echo "Plugin-owned XcodeBuildMCP is provisioned for: $TARGET_CODEX_HOME"
echo "Restart that Codex host so it reloads the plugin MCP catalog."
