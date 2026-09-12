#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCK_FILE="$PLUGIN_ROOT/runtime/xcodebuildmcp/runtime-lock.json"
RUNTIME_ENV="$PLUGIN_ROOT/runtime/xcodebuildmcp/runtime.env"
LOCK_CHECKER="$PLUGIN_ROOT/scripts/check_xcodebuildmcp_runtime_lock.py"
RUNTIME_ROOT="${APPLE_APPDEV_XCODEBUILDMCP_RUNTIME_DIR:-$HOME/Library/Application Support/Apple AppDev Workflow/runtime/xcodebuildmcp}"
ARCHIVE=""
FORCE=0
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: setup-xcodebuildmcp-runtime.sh [options]

Options:
  --runtime-root PATH  Install root. Defaults to the shared user-level Apple AppDev Workflow runtime.
  --archive PATH       Use an already-downloaded promoted portable archive.
  --lock PATH          Alternate runtime-lock.json (qualification/testing).
  --runtime-env PATH   Alternate generated runtime.env (qualification/testing).
  --force              Preserve an existing destination as a timestamped backup.
  --dry-run            Print the exact promoted install plan without changing files.
  -h, --help           Show this help.

The installer never consults PATH for XcodeBuildMCP, npm, Node, Malt, or Homebrew.
It downloads the exact promoted GitHub archive, verifies its size and SHA-256,
checks archive containment, validates the bundled signed Node runtime, and only
then promotes the versioned runtime directory.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --runtime-root)
      RUNTIME_ROOT="${2:-}"
      shift 2
      ;;
    --archive)
      ARCHIVE="${2:-}"
      shift 2
      ;;
    --lock)
      LOCK_FILE="${2:-}"
      shift 2
      ;;
    --runtime-env)
      RUNTIME_ENV="${2:-}"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
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

[[ -n "$RUNTIME_ROOT" ]] || { echo "error: --runtime-root cannot be empty" >&2; exit 2; }
[[ -f "$LOCK_FILE" ]] || { echo "error: runtime lock is missing: $LOCK_FILE" >&2; exit 1; }
[[ -f "$RUNTIME_ENV" ]] || { echo "error: runtime environment is missing: $RUNTIME_ENV" >&2; exit 1; }
[[ -f "$LOCK_CHECKER" ]] || { echo "error: runtime lock checker is missing: $LOCK_CHECKER" >&2; exit 1; }

PYTHON_BIN="${APPLE_APPDEV_XCODEBUILDMCP_PYTHON_BIN:-/usr/bin/python3}"
CODESIGN_BIN="${APPLE_APPDEV_XCODEBUILDMCP_CODESIGN_BIN:-/usr/bin/codesign}"
[[ -x "$PYTHON_BIN" ]] || { echo "error: Python 3 is required to validate the promoted archive" >&2; exit 1; }
[[ -x "$CODESIGN_BIN" ]] || { echo "error: codesign is required to validate the bundled Node runtime" >&2; exit 1; }

"$PYTHON_BIN" "$LOCK_CHECKER" --lock "$LOCK_FILE" --runtime-env "$RUNTIME_ENV"

# runtime.env is a generated, checker-constrained part of the plugin payload.
# shellcheck disable=SC1090
source "$RUNTIME_ENV"

case "${APPLE_APPDEV_XCODEBUILDMCP_PLATFORM:-$(uname -m)}" in
  arm64|darwin-arm64)
    PLATFORM="darwin-arm64"
    EXPECTED_SHA256="$XCODEBUILDMCP_DARWIN_ARM64_SHA256"
    EXPECTED_SIZE="$XCODEBUILDMCP_DARWIN_ARM64_SIZE"
    ;;
  x86_64|darwin-x64)
    PLATFORM="darwin-x64"
    EXPECTED_SHA256="$XCODEBUILDMCP_DARWIN_X64_SHA256"
    EXPECTED_SIZE="$XCODEBUILDMCP_DARWIN_X64_SIZE"
    ;;
  *)
    echo "error: unsupported host architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

ASSET_NAME="xcodebuildmcp-$XCODEBUILDMCP_RUNTIME_VERSION-$PLATFORM.tar.gz"
ASSET_URL="https://github.com/getsentry/XcodeBuildMCP/releases/download/v$XCODEBUILDMCP_RUNTIME_VERSION/$ASSET_NAME"
DESTINATION="$RUNTIME_ROOT/releases/$XCODEBUILDMCP_RUNTIME_VERSION/$PLATFORM"

echo "XcodeBuildMCP plugin runtime install plan:"
echo "  version: $XCODEBUILDMCP_RUNTIME_VERSION"
echo "  platform: $PLATFORM"
echo "  archive SHA-256: $EXPECTED_SHA256"
echo "  destination: $DESTINATION"
if [[ -n "$ARCHIVE" ]]; then
  echo "  source: $ARCHIVE"
else
  echo "  source: $ASSET_URL"
fi

if [[ "$DRY_RUN" == "1" ]]; then
  exit 0
fi

if [[ -d "$DESTINATION" && "$FORCE" != "1" ]]; then
  RECEIPT="$DESTINATION/runtime-receipt.env"
  if [[ -f "$RECEIPT" \
    && "$(/usr/bin/wc -l < "$RECEIPT" | /usr/bin/tr -d ' ')" == "6" \
    && "$(/usr/bin/grep -Fxc 'SCHEMA_VERSION=1' "$RECEIPT")" == "1" \
    && "$(/usr/bin/grep -Fxc 'RUNTIME=xcodebuildmcp' "$RECEIPT")" == "1" \
    && "$(/usr/bin/grep -Fxc "VERSION=$XCODEBUILDMCP_RUNTIME_VERSION" "$RECEIPT")" == "1" \
    && "$(/usr/bin/grep -Fxc "PLATFORM=$PLATFORM" "$RECEIPT")" == "1" \
    && "$(/usr/bin/grep -Fxc "ARCHIVE_SHA256=$EXPECTED_SHA256" "$RECEIPT")" == "1" \
    && "$(/usr/bin/grep -Fxc "ARCHIVE_SIZE=$EXPECTED_SIZE" "$RECEIPT")" == "1" \
    && -x "$DESTINATION/bin/xcodebuildmcp" \
    && -x "$DESTINATION/bin/xcodebuildmcp-doctor" \
    && -x "$DESTINATION/libexec/node-runtime" ]] \
    && "$CODESIGN_BIN" --verify --strict "$DESTINATION/libexec/node-runtime" >/dev/null 2>&1; then
    EXISTING_VERSION="$({ \
      PATH=/usr/bin:/bin:/usr/sbin:/sbin \
      XCODEBUILDMCP_SENTRY_DISABLED=true \
      SENTRY_DISABLED=true \
      "$DESTINATION/bin/xcodebuildmcp" --version; \
    } 2>/dev/null | /usr/bin/head -n 1)"
    if [[ "$EXISTING_VERSION" == "$XCODEBUILDMCP_RUNTIME_VERSION" \
      && -f "$DESTINATION/runtime-lock.json" \
      && -f "$DESTINATION/runtime.env" ]] \
      && /usr/bin/cmp -s "$LOCK_FILE" "$DESTINATION/runtime-lock.json" \
      && /usr/bin/cmp -s "$RUNTIME_ENV" "$DESTINATION/runtime.env"; then
      echo "Plugin-owned XcodeBuildMCP runtime is already current: $DESTINATION"
      exit 0
    fi
  fi
  echo "error: destination exists but does not match the promoted runtime; pass --force to preserve and replace it: $DESTINATION" >&2
  exit 1
fi

for required in /usr/bin/cmp /usr/bin/curl /usr/bin/tar /usr/bin/shasum /usr/bin/stat /bin/mkdir /bin/mv /bin/cp; do
  [[ -x "$required" ]] || { echo "error: required system tool is missing: $required" >&2; exit 1; }
done

/bin/mkdir -p "$RUNTIME_ROOT/releases" "$RUNTIME_ROOT/backups"
TEMP_ROOT="$(/usr/bin/mktemp -d "$RUNTIME_ROOT/.install.XXXXXX")"
STAGING="$TEMP_ROOT/staging"
DOWNLOADED_ARCHIVE="$TEMP_ROOT/$ASSET_NAME"
cleanup() {
  if [[ -n "${TEMP_ROOT:-}" && -d "$TEMP_ROOT" ]]; then
    /bin/rm -rf -- "$TEMP_ROOT"
  fi
}
trap cleanup EXIT HUP INT TERM
/bin/mkdir -p "$STAGING"

if [[ -n "$ARCHIVE" ]]; then
  [[ -f "$ARCHIVE" ]] || { echo "error: archive is missing: $ARCHIVE" >&2; exit 1; }
  ARCHIVE_TO_VERIFY="$ARCHIVE"
else
  /usr/bin/curl \
    --fail \
    --location \
    --proto '=https' \
    --tlsv1.2 \
    --retry 3 \
    --output "$DOWNLOADED_ARCHIVE" \
    "$ASSET_URL"
  ARCHIVE_TO_VERIFY="$DOWNLOADED_ARCHIVE"
fi

"$PYTHON_BIN" "$LOCK_CHECKER" \
  --lock "$LOCK_FILE" \
  --runtime-env "$RUNTIME_ENV" \
  --archive "$PLATFORM=$ARCHIVE_TO_VERIFY"

/usr/bin/tar -xzf "$ARCHIVE_TO_VERIFY" -C "$STAGING" --strip-components 1

for required in bin/xcodebuildmcp bin/xcodebuildmcp-doctor libexec/node-runtime libexec/_resolve-resource-root.sh libexec/package.json; do
  [[ -f "$STAGING/$required" ]] || { echo "error: extracted runtime is missing $required" >&2; exit 1; }
done
/bin/chmod +x \
  "$STAGING/bin/xcodebuildmcp" \
  "$STAGING/bin/xcodebuildmcp-doctor" \
  "$STAGING/libexec/node-runtime" \
  "$STAGING/libexec/_resolve-resource-root.sh"

if ! "$CODESIGN_BIN" --verify --strict "$STAGING/libexec/node-runtime" >/dev/null 2>&1; then
  echo "error: bundled Node runtime failed code-signature verification" >&2
  exit 1
fi

ACTUAL_VERSION="$({ \
  PATH=/usr/bin:/bin:/usr/sbin:/sbin \
  XCODEBUILDMCP_SENTRY_DISABLED=true \
  SENTRY_DISABLED=true \
  "$STAGING/bin/xcodebuildmcp" --version; \
} 2>/dev/null | /usr/bin/head -n 1)"
if [[ "$ACTUAL_VERSION" != "$XCODEBUILDMCP_RUNTIME_VERSION" ]]; then
  echo "error: extracted runtime version mismatch; expected " \
    "$XCODEBUILDMCP_RUNTIME_VERSION, found ${ACTUAL_VERSION:-missing}" >&2
  exit 1
fi

/bin/mkdir -p "$STAGING/licenses"
while IFS=$'\t' read -r license_name license_url license_sha256; do
  [[ -n "$license_name" && -n "$license_url" && -n "$license_sha256" ]] || continue
  license_path="$STAGING/licenses/$license_name"
  /usr/bin/curl \
    --fail \
    --location \
    --proto '=https' \
    --tlsv1.2 \
    --retry 3 \
    --output "$license_path" \
    "$license_url"
  actual_license_sha256="$(/usr/bin/shasum -a 256 "$license_path" | /usr/bin/awk '{print $1}')"
  if [[ "$actual_license_sha256" != "$license_sha256" ]]; then
    echo "error: license digest mismatch for $license_name" >&2
    exit 1
  fi
done < <("$PYTHON_BIN" - "$LOCK_FILE" <<'PY'
import json
import sys

lock = json.load(open(sys.argv[1]))
for item in lock["portable"]["licenses"]:
    print(item["name"], item["url"], item["sha256"], sep="\t")
PY
)

/bin/cp "$LOCK_FILE" "$STAGING/runtime-lock.json"
/bin/cp "$RUNTIME_ENV" "$STAGING/runtime.env"
{
  printf 'SCHEMA_VERSION=1\n'
  printf 'RUNTIME=xcodebuildmcp\n'
  printf 'VERSION=%s\n' "$XCODEBUILDMCP_RUNTIME_VERSION"
  printf 'PLATFORM=%s\n' "$PLATFORM"
  printf 'ARCHIVE_SHA256=%s\n' "$EXPECTED_SHA256"
  printf 'ARCHIVE_SIZE=%s\n' "$EXPECTED_SIZE"
} > "$STAGING/runtime-receipt.env"
/bin/chmod 0644 "$STAGING/runtime-receipt.env" "$STAGING/runtime-lock.json" "$STAGING/runtime.env"

if [[ -e "$DESTINATION" ]]; then
  if [[ "$FORCE" != "1" ]]; then
    echo "error: destination already exists; pass --force to preserve and replace it: $DESTINATION" >&2
    exit 1
  fi
  BACKUP="$RUNTIME_ROOT/backups/$XCODEBUILDMCP_RUNTIME_VERSION-$PLATFORM-$(date -u +%Y%m%dT%H%M%SZ)"
  backup_suffix=1
  while [[ -e "$BACKUP" ]]; do
    BACKUP="$RUNTIME_ROOT/backups/$XCODEBUILDMCP_RUNTIME_VERSION-$PLATFORM-$(date -u +%Y%m%dT%H%M%SZ)-$backup_suffix"
    backup_suffix=$((backup_suffix + 1))
  done
  /bin/mv "$DESTINATION" "$BACKUP"
  echo "Preserved previous runtime: $BACKUP"
fi

/bin/mkdir -p "$(dirname "$DESTINATION")"
if ! /bin/mv "$STAGING" "$DESTINATION"; then
  if [[ -n "${BACKUP:-}" && -e "$BACKUP" && ! -e "$DESTINATION" ]]; then
    if ! /bin/mv "$BACKUP" "$DESTINATION"; then
      echo "error: runtime promotion failed and rollback could not restore $BACKUP" >&2
      exit 1
    fi
  fi
  echo "error: runtime promotion failed; prior runtime was restored" >&2
  exit 1
fi
echo "Installed plugin-owned XcodeBuildMCP runtime: $DESTINATION"
echo "Malt, Homebrew, PATH-installed Node, and global XcodeBuildMCP binaries were not changed."
