#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/run-xcodebuildmcp.sh" --plugin-runtime-provenance >/dev/null

echo "Plugin runtime looks present:"
echo "  Sosumi: direct streamable HTTP (no local runtime)"
echo "  Memory: Codex native memory (no plugin runtime)"
echo "  $SCRIPT_DIR/run-xcodebuildmcp.sh (promoted portable runtime)"
