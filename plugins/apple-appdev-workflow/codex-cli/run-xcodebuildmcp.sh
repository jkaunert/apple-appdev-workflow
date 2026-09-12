#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_ENV="$PLUGIN_ROOT/runtime/xcodebuildmcp/runtime.env"
RUNTIME_LOCK="$PLUGIN_ROOT/runtime/xcodebuildmcp/runtime-lock.json"
LOCK_CHECKER="$PLUGIN_ROOT/scripts/check_xcodebuildmcp_runtime_lock.py"
PYTHON_BIN="${APPLE_APPDEV_XCODEBUILDMCP_PYTHON_BIN:-/usr/bin/python3}"

if [[ ! -f "$RUNTIME_ENV" || ! -f "$RUNTIME_LOCK" || ! -f "$LOCK_CHECKER" ]]; then
  echo "Missing promoted XcodeBuildMCP runtime contract under: $PLUGIN_ROOT" >&2
  exit 1
fi
if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Missing XcodeBuildMCP runtime-lock verifier: $PYTHON_BIN" >&2
  exit 1
fi

# Validate the exact, non-executable key/value grammar before sourcing the
# generated environment file. This runs for every MCP/CLI launch so a modified
# installed artifact fails closed instead of becoming shell input.
if ! "$PYTHON_BIN" "$LOCK_CHECKER" \
  --lock "$RUNTIME_LOCK" \
  --runtime-env "$RUNTIME_ENV" >/dev/null; then
  echo "Promoted XcodeBuildMCP runtime contract failed validation." >&2
  exit 1
fi

# runtime.env is generated from runtime-lock.json and has just passed the strict
# exact-key/value parser above.
# shellcheck disable=SC1090
source "$RUNTIME_ENV"

case "${APPLE_APPDEV_XCODEBUILDMCP_PLATFORM:-$(uname -m)}" in
  arm64|darwin-arm64)
    PLATFORM="darwin-arm64"
    EXPECTED_ARCHIVE_SHA256="$XCODEBUILDMCP_DARWIN_ARM64_SHA256"
    EXPECTED_ARCHIVE_SIZE="$XCODEBUILDMCP_DARWIN_ARM64_SIZE"
    ;;
  x86_64|darwin-x64)
    PLATFORM="darwin-x64"
    EXPECTED_ARCHIVE_SHA256="$XCODEBUILDMCP_DARWIN_X64_SHA256"
    EXPECTED_ARCHIVE_SIZE="$XCODEBUILDMCP_DARWIN_X64_SIZE"
    ;;
  *)
    echo "XcodeBuildMCP portable runtime is unsupported on $(uname -s) $(uname -m)." >&2
    exit 1
    ;;
esac

EMBEDDED_ROOT="$PLUGIN_ROOT/runtime/xcodebuildmcp"
DEFAULT_EXTERNAL_ROOT="$HOME/Library/Application Support/Apple AppDev Workflow/runtime/xcodebuildmcp"
SETUP_SCRIPT="${APPLE_APPDEV_XCODEBUILDMCP_SETUP_BIN:-$PLUGIN_ROOT/codex-cli/setup-xcodebuildmcp-runtime.sh}"
AUTO_PROVISION="${APPLE_APPDEV_XCODEBUILDMCP_AUTO_PROVISION:-true}"
PROVISION_WAIT_SECONDS="${APPLE_APPDEV_XCODEBUILDMCP_PROVISION_WAIT_SECONDS:-600}"

if [[ -n "${APPLE_APPDEV_XCODEBUILDMCP_RUNTIME_DIR:-}" ]]; then
  RUNTIME_ROOT="$APPLE_APPDEV_XCODEBUILDMCP_RUNTIME_DIR"
  RUNTIME_SOURCE="override"
elif [[ -d "$EMBEDDED_ROOT/releases/$XCODEBUILDMCP_RUNTIME_VERSION/$PLATFORM" ]]; then
  RUNTIME_ROOT="$EMBEDDED_ROOT"
  RUNTIME_SOURCE="embedded"
else
  RUNTIME_ROOT="$DEFAULT_EXTERNAL_ROOT"
  RUNTIME_SOURCE="external"
fi

RUNTIME_DIR="$RUNTIME_ROOT/releases/$XCODEBUILDMCP_RUNTIME_VERSION/$PLATFORM"
RECEIPT="$RUNTIME_DIR/runtime-receipt.env"
BINARY="$RUNTIME_DIR/bin/xcodebuildmcp"
DOCTOR_BINARY="$RUNTIME_DIR/bin/xcodebuildmcp-doctor"
NODE_RUNTIME="$RUNTIME_DIR/libexec/node-runtime"

case "$AUTO_PROVISION" in
  1|true|TRUE|yes|YES)
    AUTO_PROVISION=1
    ;;
  0|false|FALSE|no|NO)
    AUTO_PROVISION=0
    ;;
  *)
    echo "APPLE_APPDEV_XCODEBUILDMCP_AUTO_PROVISION must be true or false." >&2
    exit 1
    ;;
esac
if [[ ! "$PROVISION_WAIT_SECONDS" =~ ^[1-9][0-9]{0,3}$ ]] \
  || (( 10#$PROVISION_WAIT_SECONDS > 3600 )); then
  echo "APPLE_APPDEV_XCODEBUILDMCP_PROVISION_WAIT_SECONDS must be 1 through 3600." >&2
  exit 1
fi

if [[ ! -f "$RECEIPT" && "$AUTO_PROVISION" == "1" && "$RUNTIME_SOURCE" != "embedded" ]]; then
  if [[ ! -x "$SETUP_SCRIPT" ]]; then
    echo "Plugin-owned XcodeBuildMCP setup helper is missing or not executable: $SETUP_SCRIPT" >&2
    exit 1
  fi
  /bin/mkdir -p "$RUNTIME_ROOT"
  PROVISION_LOCK="$RUNTIME_ROOT/.provision-$XCODEBUILDMCP_RUNTIME_VERSION-$PLATFORM.lock"
  PROVISION_LOCK_OWNED=0
  cleanup_provision_lock() {
    if [[ "$PROVISION_LOCK_OWNED" == "1" && -d "$PROVISION_LOCK" ]]; then
      /bin/rmdir "$PROVISION_LOCK" >/dev/null 2>&1 || true
    fi
  }
  elapsed=0
  announced_wait=0
  while [[ ! -f "$RECEIPT" && "$elapsed" -lt "$PROVISION_WAIT_SECONDS" ]]; do
    if /bin/mkdir "$PROVISION_LOCK" 2>/dev/null; then
      PROVISION_LOCK_OWNED=1
      trap cleanup_provision_lock EXIT HUP INT TERM
      echo "Provisioning locked XcodeBuildMCP runtime on first use..." >&2
      "$SETUP_SCRIPT" --runtime-root "$RUNTIME_ROOT" 1>&2
      cleanup_provision_lock
      PROVISION_LOCK_OWNED=0
      trap - EXIT HUP INT TERM
      break
    fi
    if [[ "$announced_wait" == "0" ]]; then
      echo "Waiting for another process to provision the locked XcodeBuildMCP runtime..." >&2
      announced_wait=1
    fi
    /bin/sleep 1
    elapsed=$((elapsed + 1))
  done
fi

receipt_value() {
  local key="$1"
  /usr/bin/awk -F= -v wanted="$key" '
    $1 == wanted { count += 1; value = substr($0, index($0, "=") + 1) }
    END { if (count == 1) print value; else exit 1 }
  ' "$RECEIPT"
}

if [[ ! -f "$RECEIPT" ]]; then
  echo "Plugin-owned XcodeBuildMCP runtime is not provisioned: $RECEIPT" >&2
  if [[ "$RUNTIME_SOURCE" == "embedded" ]]; then
    echo "The embedded runtime is incomplete; reinstall the plugin artifact." >&2
  elif [[ "$AUTO_PROVISION" == "0" ]]; then
    echo "Automatic provisioning is disabled. Run $PLUGIN_ROOT/codex-cli/setup-xcodebuildmcp-runtime.sh to provision the shared user runtime." >&2
  else
    echo "Automatic provisioning did not complete. Review the preceding verified-download error and retry." >&2
  fi
  exit 1
fi

if /usr/bin/grep -Ev '^(SCHEMA_VERSION|RUNTIME|VERSION|PLATFORM|ARCHIVE_SHA256|ARCHIVE_SIZE)=[A-Za-z0-9._+-]+$' "$RECEIPT" | /usr/bin/grep -q .; then
  echo "XcodeBuildMCP runtime receipt contains unsupported content: $RECEIPT" >&2
  exit 1
fi

RECEIPT_SCHEMA="$(receipt_value SCHEMA_VERSION)" || {
  echo "Invalid XcodeBuildMCP runtime receipt schema field: $RECEIPT" >&2
  exit 1
}
RECEIPT_RUNTIME="$(receipt_value RUNTIME)" || {
  echo "Invalid XcodeBuildMCP runtime receipt runtime field: $RECEIPT" >&2
  exit 1
}
RECEIPT_VERSION="$(receipt_value VERSION)" || {
  echo "Invalid XcodeBuildMCP runtime receipt version field: $RECEIPT" >&2
  exit 1
}
RECEIPT_PLATFORM="$(receipt_value PLATFORM)" || {
  echo "Invalid XcodeBuildMCP runtime receipt platform field: $RECEIPT" >&2
  exit 1
}
RECEIPT_SHA256="$(receipt_value ARCHIVE_SHA256)" || {
  echo "Invalid XcodeBuildMCP runtime receipt digest field: $RECEIPT" >&2
  exit 1
}
RECEIPT_SIZE="$(receipt_value ARCHIVE_SIZE)" || {
  echo "Invalid XcodeBuildMCP runtime receipt size field: $RECEIPT" >&2
  exit 1
}

if [[ "$RECEIPT_SCHEMA" != "1" \
  || "$RECEIPT_RUNTIME" != "xcodebuildmcp" \
  || "$RECEIPT_VERSION" != "$XCODEBUILDMCP_RUNTIME_VERSION" \
  || "$RECEIPT_PLATFORM" != "$PLATFORM" \
  || "$RECEIPT_SHA256" != "$EXPECTED_ARCHIVE_SHA256" \
  || "$RECEIPT_SIZE" != "$EXPECTED_ARCHIVE_SIZE" ]]; then
  echo "XcodeBuildMCP runtime receipt does not match the promoted plugin lock: $RECEIPT" >&2
  exit 1
fi

if [[ ! -x "$BINARY" || ! -x "$DOCTOR_BINARY" || ! -x "$NODE_RUNTIME" ]]; then
  echo "Plugin-owned XcodeBuildMCP runtime is incomplete in $RUNTIME_DIR" >&2
  exit 1
fi

CODESIGN_BIN="${APPLE_APPDEV_XCODEBUILDMCP_CODESIGN_BIN:-/usr/bin/codesign}"
if [[ ! -x "$CODESIGN_BIN" ]]; then
  echo "Missing code-signature verifier: $CODESIGN_BIN" >&2
  exit 1
fi
if ! "$CODESIGN_BIN" --verify --strict "$NODE_RUNTIME" >/dev/null 2>&1; then
  echo "Bundled XcodeBuildMCP Node runtime failed code-signature verification: $NODE_RUNTIME" >&2
  exit 1
fi

export XCODEBUILDMCP_SENTRY_DISABLED="true"
export SENTRY_DISABLED="true"
export XCODEBUILDMCP_ENABLED_WORKFLOWS
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

if [[ "${1:-}" == "--plugin-runtime-provenance" ]]; then
  printf 'runtime=xcodebuildmcp\nversion=%s\nplatform=%s\narchive_sha256=%s\nbinary=%s\n' \
    "$XCODEBUILDMCP_RUNTIME_VERSION" \
    "$PLATFORM" \
    "$EXPECTED_ARCHIVE_SHA256" \
    "$BINARY"
  exit 0
fi

ACTUAL_VERSION="$("$BINARY" --version 2>/dev/null | /usr/bin/head -n 1)"
if [[ "$ACTUAL_VERSION" != "$XCODEBUILDMCP_RUNTIME_VERSION" ]]; then
  echo "Plugin-owned XcodeBuildMCP binary version drifted: expected " \
    "$XCODEBUILDMCP_RUNTIME_VERSION, found ${ACTUAL_VERSION:-missing}" >&2
  exit 1
fi

if [[ "${1:-}" == "doctor" ]]; then
  shift
  exec "$DOCTOR_BINARY" "$@"
fi

exec "$BINARY" "$@"
