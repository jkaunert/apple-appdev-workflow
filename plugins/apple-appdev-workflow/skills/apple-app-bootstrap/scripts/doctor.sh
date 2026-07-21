#!/usr/bin/env bash
set -euo pipefail

MODE="new"
BACKEND="xcodegen"
OUTPUT=""
RELEASE_INTENT_VALUES=("none")
RELEASE_INTENT="none"

usage() {
  cat <<USAGE
Usage: doctor.sh [--mode new|adopt] [--backend xcodegen|tuist] [--release-intent none|testflight-aware|app-store-aware|testflight-aware,app-store-aware] [--output /path/to/project]
USAGE
}

trim() {
  local value="$1"
  value="${value#${value%%[![:space:]]*}}"
  value="${value%${value##*[![:space:]]}}"
  printf '%s' "$value"
}

normalize_release_intents() {
  local -a raw_values=("$@")
  local has_testflight=0
  local has_app_store=0

  if [[ ${#raw_values[@]} -eq 0 ]]; then
    printf 'none\n'
    return 0
  fi

  for raw in "${raw_values[@]}"; do
    local -a parts=()
    IFS=',' read -ra parts <<< "$raw"
    for part in "${parts[@]}"; do
      local value
      value="$(trim "$part")"
      [[ -z "$value" ]] && continue
      case "$value" in
        none)
          ;;
        testflight-aware)
          has_testflight=1
          ;;
        app-store-aware)
          has_app_store=1
          ;;
        *)
          echo "Unsupported release intent: $value" >&2
          return 1
          ;;
      esac
    done
  done

  local normalized=""
  local sep=""
  if [[ $has_testflight -eq 1 ]]; then
    normalized+="testflight-aware"
    sep=","
  fi
  if [[ $has_app_store -eq 1 ]]; then
    normalized+="${sep}app-store-aware"
  fi
  printf '%s\n' "${normalized:-none}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"
      shift 2
      ;;
    --backend)
      BACKEND="$2"
      shift 2
      ;;
    --output)
      OUTPUT="$2"
      shift 2
      ;;
    --release-intent)
      RELEASE_INTENT_VALUES+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

missing=0
warnings=0

if ! RELEASE_INTENT="$(normalize_release_intents "${RELEASE_INTENT_VALUES[@]}")"; then
  exit 1
fi

if [[ "$BACKEND" != "xcodegen" && "$BACKEND" != "tuist" ]]; then
  echo "Unsupported backend: $BACKEND" >&2
  exit 1
fi

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "ok: $cmd"
  else
    echo "missing: $cmd"
    missing=1
  fi
}

check_mise_provider() {
  if command -v mise >/dev/null 2>&1; then
    local mise_version
    mise_version="$(mise --version 2>/dev/null | head -n 1 | tr -d '\r' || true)"
    if [[ -n "$mise_version" ]]; then
      echo "info: mise provider available ($mise_version)"
    else
      echo "info: mise provider available"
    fi
    echo "info: prefer project-scoped or one-off Tuist via Mise for reproducible validation; bootstrap will not run mise install/use automatically"
  else
    echo "info: mise provider missing; project-scoped Tuist management is unavailable unless another tool exposes tuist on PATH"
  fi
}

warn() {
  echo "warning: $1"
  warnings=1
}

echo "Apple App Bootstrap doctor"
echo "mode: $MODE"
echo "backend: $BACKEND"
echo "release intent: $RELEASE_INTENT"

check_cmd xcode-select
check_cmd xcodebuild
check_cmd xcrun
check_cmd python3
check_cmd git

if [[ "$MODE" == "new" ]]; then
  if [[ "$BACKEND" == "xcodegen" ]]; then
    check_cmd xcodegen
  elif [[ "$BACKEND" == "tuist" ]]; then
    check_mise_provider
    check_cmd tuist
    if command -v tuist >/dev/null 2>&1; then
      tuist_version="$(tuist version 2>/dev/null | head -n 1 | tr -d '\r' || true)"
      if [[ -n "$tuist_version" ]]; then
        echo "ok: tuist version $tuist_version"
      else
        warn "tuist CLI exists but version evidence was unavailable"
      fi
    fi
  fi
else
  echo "info: adopt mode does not require XcodeGen"
  if [[ "$BACKEND" == "tuist" ]]; then
    check_mise_provider
    check_cmd tuist
  fi
fi

if [[ -n "$OUTPUT" ]]; then
  if [[ ! -e "$OUTPUT" ]]; then
    warn "output path does not exist yet: $OUTPUT"
  elif [[ "$MODE" == "adopt" ]]; then
    if [[ ! -d "$OUTPUT" ]]; then
      echo "error: adopt mode output must be a directory" >&2
      exit 1
    fi
    if find "$OUTPUT" -maxdepth 3 \( -name '*.xcodeproj' -o -name '*.xcworkspace' \) | grep -q .; then
      echo "ok: Xcode project/workspace detected under adopt path"
    elif find "$OUTPUT" -maxdepth 3 -name 'Package.swift' | grep -q .; then
      echo "ok: Swift package detected under adopt path"
    else
      warn "no .xcodeproj, .xcworkspace, or Package.swift found under adopt path"
    fi
  fi
fi

if [[ "$RELEASE_INTENT" != "none" ]]; then
  echo "info: release handoff doctor is non-executing; it does not configure signing, upload builds, create App Store Connect records, install Fastlane, or generate CI"
  echo "info: release follow-up owners: apple-release-orchestrator, apple-build-release-ops, apple-app-store-aso, apple-app-store-release-notes, apple-manual-validation, apple-testing-quality-gates"
  if [[ -n "$OUTPUT" && -d "$OUTPUT" ]]; then
    if [[ -f "$OUTPUT/README.md" ]] && grep -q '^## Release Handoff' "$OUTPUT/README.md"; then
      echo "ok: generated Release Handoff section detected"
    else
      warn "generated Release Handoff section not found in README.md"
    fi
    if [[ -f "$OUTPUT/Fastfile" ]]; then
      warn "Fastfile already exists; release automation must be reviewed outside bootstrap"
    else
      echo "ok: no default Fastlane file generated"
    fi
    if [[ -d "$OUTPUT/.github/workflows" ]]; then
      warn ".github/workflows already exists; CI release automation must be reviewed outside bootstrap"
    else
      echo "ok: no default GitHub Actions release workflow generated"
    fi
  fi
fi

if [[ -x "./codex-cli/verify-xcodebuildmcp.sh" ]]; then
  echo "info: run ./codex-cli/verify-xcodebuildmcp.sh separately to verify full XcodeBuildMCP workflow exposure"
fi

if [[ $missing -ne 0 ]]; then
  echo
  echo "Doctor check failed." >&2
  if [[ "$MODE" == "new" && "$BACKEND" == "xcodegen" ]]; then
    echo "Install XcodeGen for greenfield scaffolding: brew install xcodegen" >&2
  elif [[ "$MODE" == "new" && "$BACKEND" == "tuist" ]]; then
    echo "Install or expose Tuist for the selected backend. Prefer a project-scoped or one-off Tuist version via Mise when possible." >&2
  fi
  exit 1
fi

echo
if [[ $warnings -ne 0 ]]; then
  echo "Doctor check passed with warnings."
else
  echo "Doctor check passed."
fi
