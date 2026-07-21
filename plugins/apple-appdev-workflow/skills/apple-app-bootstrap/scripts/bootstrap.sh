#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  bootstrap.sh --mode new --name "My App" --bundle-id com.example.MyApp --platform ios|macos --ui swiftui --output /path/to/output [options]
  bootstrap.sh --mode adopt --output /path/to/existing/project [options]

Options:
  --deployment-target VALUE
  --allow-default-deployment-target
  --layout-mode single-target|app-plus-packages
  --packages AppCore,AppServices,AppDesignSystem,AppTestSupport
  --repo-policy init-main-only|harness-topic-ready|legacy-codex-dev
  --branch-policy init-main-only|harness-topic-ready|legacy-codex-dev  # compatibility alias for --repo-policy
  --forge-provider github|gitlab|generic
  --package-test-policy defer|include
  --release-intent none|testflight-aware|app-store-aware|testflight-aware,app-store-aware
  --backend xcodegen|tuist
  --report-file /path/to/report.md
  --dry-run
  --regenerate
USAGE
}

MODE="new"
APP_NAME=""
BUNDLE_ID=""
PLATFORM=""
UI="swiftui"
OUTPUT=""
DEPLOYMENT_TARGET=""
DEPLOYMENT_TARGET_SOURCE="explicit"
ALLOW_DEFAULT_DEPLOYMENT_TARGET=0
LAYOUT_MODE="single-target"
PACKAGES=""
BRANCH_POLICY="init-main-only"
FORGE_PROVIDER="github"
PACKAGE_TEST_POLICY="defer"
RELEASE_INTENT_VALUES=("none")
RELEASE_INTENT="none"
BACKEND="xcodegen"
TUIST_VERSION=""
MISE_STATUS="not checked"
MISE_VERSION=""
REPORT_FILE=""
DRY_RUN=0
REGENERATE=0
DEPLOYMENT_TARGET_OBSERVED=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"
      shift 2
      ;;
    --name)
      APP_NAME="$2"
      shift 2
      ;;
    --bundle-id)
      BUNDLE_ID="$2"
      shift 2
      ;;
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    --ui)
      UI="$2"
      shift 2
      ;;
    --output)
      OUTPUT="$2"
      shift 2
      ;;
    --deployment-target)
      DEPLOYMENT_TARGET="$2"
      shift 2
      ;;
    --allow-default-deployment-target)
      ALLOW_DEFAULT_DEPLOYMENT_TARGET=1
      shift
      ;;
    --layout-mode)
      LAYOUT_MODE="$2"
      shift 2
      ;;
    --packages)
      PACKAGES="$2"
      shift 2
      ;;
    --repo-policy|--branch-policy)
      BRANCH_POLICY="$2"
      shift 2
      ;;
    --forge-provider)
      FORGE_PROVIDER="$2"
      shift 2
      ;;
    --package-test-policy)
      PACKAGE_TEST_POLICY="$2"
      shift 2
      ;;
    --release-intent)
      RELEASE_INTENT_VALUES+=("$2")
      shift 2
      ;;
    --backend)
      BACKEND="$2"
      shift 2
      ;;
    --report-file)
      REPORT_FILE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --regenerate)
      REGENERATE=1
      shift
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

if [[ -z "$OUTPUT" ]]; then
  echo "Missing --output" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$SCRIPT_DIR/../templates/xcodegen"
RENDER="$SCRIPT_DIR/render_template.py"

sanitize_product_name() {
  printf '%s' "$1" | tr -cd '[:alnum:]'
}

trim() {
  local value="$1"
  value="${value#${value%%[![:space:]]*}}"
  value="${value%${value##*[![:space:]]}}"
  printf '%s' "$value"
}

join_csv() {
  local raw="$1"
  [[ -z "$raw" ]] && return 0
  local sep=""
  local out=""
  local -a items=()
  IFS=',' read -ra items <<< "$raw"
  for item in "${items[@]}"; do
    local part
    part="$(trim "$item")"
    [[ -z "$part" ]] && continue
    out+="${sep}${part}"
    sep=", "
  done
  printf '%s' "$out"
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

release_intent_has() {
  local needle="$1"
  case ",$RELEASE_INTENT," in
    *",$needle,"*) return 0 ;;
    *) return 1 ;;
  esac
}

release_intent_label() {
  if release_intent_has "testflight-aware" && release_intent_has "app-store-aware"; then
    printf 'TestFlight-aware and App Store-aware'
  elif release_intent_has "testflight-aware"; then
    printf 'TestFlight-aware'
  elif release_intent_has "app-store-aware"; then
    printf 'App Store-aware'
  else
    printf 'none'
  fi
}

preflight_tuist() {
  probe_mise

  if ! command -v tuist >/dev/null 2>&1; then
    echo "Tuist backend selected but the tuist CLI was not found. Install Tuist, expose a project-scoped Tuist on PATH, or use --backend xcodegen." >&2
    if [[ "$MISE_STATUS" == "available" ]]; then
      echo "Mise is available; prefer a project-scoped or one-off Tuist install for reproducible validation rather than a hidden global dependency." >&2
    else
      echo "Mise was not found; install Tuist globally for this host or install Mise to manage a project-scoped Tuist version." >&2
    fi
    exit 1
  fi

  TUIST_VERSION="$(tuist version 2>/dev/null | head -n 1 | tr -d '\r' || true)"
  if [[ -z "$TUIST_VERSION" ]]; then
    echo "Tuist backend selected but 'tuist version' did not return version evidence." >&2
    exit 1
  fi
}

probe_mise() {
  if command -v mise >/dev/null 2>&1; then
    MISE_STATUS="available"
    MISE_VERSION="$(mise --version 2>/dev/null | head -n 1 | tr -d '\r' || true)"
  else
    MISE_STATUS="missing"
    MISE_VERSION=""
  fi
}

join_packages_section() {
  local raw="$1"
  [[ -z "$raw" ]] && return 0
  local section=""
  local -a items=()
  IFS=',' read -ra items <<< "$raw"
  for item in "${items[@]}"; do
    local pkg
    pkg="$(trim "$item")"
    [[ -z "$pkg" ]] && continue
    section+="packages:\n"
    break
  done
  if [[ -n "$section" ]]; then
    section="packages:\n"
    for item in "${items[@]}"; do
      local pkg
      pkg="$(trim "$item")"
      [[ -z "$pkg" ]] && continue
      section+="  ${pkg}:\n    path: Packages/${pkg}\n"
    done
  fi
  printf '%b' "$section"
}

latest_ios_runtime_from_text() {
  local text="$1"
  local best_major=-1
  local best_minor=-1
  local best_label=""
  while IFS= read -r line; do
    if [[ "$line" =~ (^|[[:space:]])iOS[[:space:]]+([0-9]+)(\.([0-9]+))? ]]; then
      local major="${BASH_REMATCH[2]}"
      local minor="${BASH_REMATCH[4]:-0}"
      if (( major > best_major || (major == best_major && minor > best_minor) )); then
        best_major="$major"
        best_minor="$minor"
        best_label="iOS ${major}.${minor}"
      fi
    fi
  done <<< "$text"

  if [[ "$best_major" -lt 0 ]]; then
    return 1
  fi

  printf '%s.0|%s\n' "$best_major" "$best_label"
}

macos_major_floor() {
  local version="$1"
  if [[ "$version" =~ ^([0-9]+)(\.([0-9]+))? ]]; then
    printf '%s.0\n' "${BASH_REMATCH[1]}"
    return 0
  fi
  return 1
}

resolve_default_deployment_target() {
  local platform="$1"
  local resolved=""

  if [[ "$platform" == "ios" ]]; then
    if [[ -n "${APPLE_APP_BOOTSTRAP_IOS_DEFAULT_TARGET:-}" ]]; then
      DEPLOYMENT_TARGET="$APPLE_APP_BOOTSTRAP_IOS_DEFAULT_TARGET"
      DEPLOYMENT_TARGET_SOURCE="env-ios-default-approved"
      DEPLOYMENT_TARGET_OBSERVED="${APPLE_APP_BOOTSTRAP_IOS_DEFAULT_OBSERVED:-env override}"
      return 0
    fi

    local runtimes_text="${APPLE_APP_BOOTSTRAP_SIMCTL_RUNTIMES:-}"
    if [[ -z "$runtimes_text" ]]; then
      if ! command -v xcrun >/dev/null 2>&1; then
        echo "Could not resolve the default iOS deployment target because xcrun is unavailable. Pass --deployment-target explicitly." >&2
        exit 1
      fi
      runtimes_text="$(xcrun simctl list runtimes 2>/dev/null || true)"
    fi

    local runtime_result
    if ! runtime_result="$(latest_ios_runtime_from_text "$runtimes_text")"; then
      echo "Could not resolve the default iOS deployment target from installed simulator runtimes. Pass --deployment-target explicitly." >&2
      exit 1
    fi

    resolved="${runtime_result%%|*}"
    DEPLOYMENT_TARGET="$resolved"
    DEPLOYMENT_TARGET_SOURCE="host-simulator-runtime-approved-default"
    DEPLOYMENT_TARGET_OBSERVED="${runtime_result#*|}"
    return 0
  fi

  if [[ -n "${APPLE_APP_BOOTSTRAP_MACOS_DEFAULT_TARGET:-}" ]]; then
    DEPLOYMENT_TARGET="$APPLE_APP_BOOTSTRAP_MACOS_DEFAULT_TARGET"
    DEPLOYMENT_TARGET_SOURCE="env-macos-default-approved"
    DEPLOYMENT_TARGET_OBSERVED="${APPLE_APP_BOOTSTRAP_MACOS_DEFAULT_OBSERVED:-env override}"
    return 0
  fi

  local host_version="${APPLE_APP_BOOTSTRAP_HOST_MACOS_VERSION:-}"
  if [[ -z "$host_version" ]]; then
    if ! command -v sw_vers >/dev/null 2>&1; then
      echo "Could not resolve the default macOS deployment target because sw_vers is unavailable. Pass --deployment-target explicitly." >&2
      exit 1
    fi
    host_version="$(sw_vers -productVersion 2>/dev/null || true)"
  fi

  if ! resolved="$(macos_major_floor "$host_version")"; then
    echo "Could not parse host macOS version '$host_version'. Pass --deployment-target explicitly." >&2
    exit 1
  fi

  DEPLOYMENT_TARGET="$resolved"
  DEPLOYMENT_TARGET_SOURCE="host-macos-approved-default"
  DEPLOYMENT_TARGET_OBSERVED="macOS $host_version"
}

spm_platform_line() {
  local platform="$1"
  local deployment_target="$2"
  if [[ "$platform" == "ios" ]]; then
    printf '        .iOS("%s"),' "$deployment_target"
  else
    printf '        .macOS("%s")' "$deployment_target"
  fi
}

join_target_dependencies() {
  local raw="$1"
  local target_type="$2"
  [[ -z "$raw" ]] && { printf '      []\n'; return 0; }
  local deps=""
  local matched=0
  local -a items=()
  IFS=',' read -ra items <<< "$raw"
  for item in "${items[@]}"; do
    local pkg
    pkg="$(trim "$item")"
    [[ -z "$pkg" ]] && continue
    if [[ "$target_type" == "app" && "$pkg" == "AppTestSupport" ]]; then
      continue
    fi
    if [[ "$target_type" == "tests" && "$pkg" != "AppTestSupport" ]]; then
      continue
    fi
    deps+="      - package: ${pkg}\n        product: ${pkg}\n"
    matched=1
  done
  if [[ $matched -eq 0 ]]; then
    deps="      []\n"
  fi
  printf '%b' "$deps"
}

tuist_package_entries() {
  local raw="$1"
  [[ -z "$raw" ]] && { printf '[]'; return 0; }

  local packages=""
  local matched=0
  local -a items=()
  IFS=',' read -ra items <<< "$raw"
  for item in "${items[@]}"; do
    local pkg
    pkg="$(trim "$item")"
    [[ -z "$pkg" ]] && continue
    packages+="        .local(path: \"Packages/${pkg}\"),\n"
    matched=1
  done

  if [[ $matched -eq 0 ]]; then
    printf '[]'
    return 0
  fi

  printf '[\n%b    ]' "$packages"
}

tuist_app_dependencies() {
  local raw="$1"
  [[ -z "$raw" ]] && { printf '[]'; return 0; }

  local deps=""
  local matched=0
  local -a items=()
  IFS=',' read -ra items <<< "$raw"
  for item in "${items[@]}"; do
    local pkg
    pkg="$(trim "$item")"
    [[ -z "$pkg" ]] && continue
    [[ "$pkg" == "AppTestSupport" ]] && continue
    deps+="                .package(product: \"${pkg}\"),\n"
    matched=1
  done

  if [[ $matched -eq 0 ]]; then
    printf '[]'
    return 0
  fi

  printf '[\n%b            ]' "$deps"
}

tuist_test_dependencies() {
  local raw="$1"
  local product_name="$2"
  local deps="                .target(name: \"${product_name}\"),\n"
  if [[ -z "$raw" ]]; then
    printf '[\n%b            ]' "$deps"
    return 0
  fi

  local -a items=()
  IFS=',' read -ra items <<< "$raw"
  for item in "${items[@]}"; do
    local pkg
    pkg="$(trim "$item")"
    [[ "$pkg" == "AppTestSupport" ]] || continue
    deps+="                .package(product: \"${pkg}\"),\n"
  done

  printf '[\n%b            ]' "$deps"
}

create_spm_package() {
  local project_dir="$1"
  local pkg="$2"
  local platforms="$3"
  local package_test_policy="$4"
  local package_dir="$project_dir/Packages/$pkg"
  mkdir -p "$package_dir/Sources/$pkg"

  local test_target_block=""
  if [[ "$package_test_policy" == "include" ]]; then
    mkdir -p "$package_dir/Tests/${pkg}Tests"
    test_target_block=",
        .testTarget(
            name: \"${pkg}Tests\",
            dependencies: [\"$pkg\"]
        )"
  fi

  cat > "$package_dir/Package.swift" <<PKG
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "$pkg",
    platforms: [
$platforms
    ],
    products: [
        .library(
            name: "$pkg",
            targets: ["$pkg"]
        )
    ],
    targets: [
        .target(
            name: "$pkg"
        )$test_target_block
    ]
)
PKG

  cat > "$package_dir/Sources/$pkg/$pkg.swift" <<SRC
public enum $pkg {
    public static let name = "$pkg"
}
SRC

  if [[ "$package_test_policy" == "include" ]]; then
    cat > "$package_dir/Tests/${pkg}Tests/${pkg}Tests.swift" <<TEST
import Testing
@testable import $pkg

struct ${pkg}Tests {
    @Test
    func moduleNameIsStable() {
        #expect($pkg.name == "$pkg")
    }
}
TEST
  fi
}

package_guidance_block() {
  local raw="$1"
  local block=""
  local normalized
  normalized="$(join_csv "$raw")"
  if [[ -z "$normalized" ]]; then
    cat <<'TEXT'
## Layout Guidance

This scaffold uses the single-target baseline.

Keep boundaries lightweight until the first real feature or dependency pressure justifies extraction.
TEXT
    return
  fi

  block+="## Layout Guidance\n\n"
  block+="This scaffold includes optional local packages: ${normalized}.\n\n"
  block+="Use package boundaries only for real ownership seams, not as a default abstraction exercise.\n\n"
  local -a items=()
  IFS=',' read -ra items <<< "$raw"
  for item in "${items[@]}"; do
    local pkg
    pkg="$(trim "$item")"
    case "$pkg" in
      AppCore)
        block+="- AppCore: shared domain types, pure business rules, and app-wide policies that should stay UI-agnostic.\n"
        ;;
      AppServices)
        block+="- AppServices: live service clients, protocol-backed integrations, persistence adapters, and boundary-facing infrastructure.\n"
        ;;
      AppDesignSystem)
        block+="- AppDesignSystem: reusable tokens, styling primitives, and shared presentation components.\n"
        ;;
      AppTestSupport)
        block+="- AppTestSupport: shared fixtures, fakes, and test helpers that should not leak into production targets.\n"
        ;;
    esac
  done
  printf '%b' "$block"
}

generated_docs_block() {
  local branch_policy="$1"
  local release_intent="$2"
  local backend="$3"
  local tuist_version="${4:-}"
  local mise_status="${5:-not checked}"
  local mise_version="${6:-}"
  local forge_provider="${7:-github}"
  local branch_handoff
  local forge_handoff
  local release_intent_label="none"
  local release_intent_guidance="Release intent: none declared during bootstrap. Treat release work as a later explicit follow-up."
  local backend_label="XcodeGen"
  local backend_evidence="Selected backend: xcodegen."
  local backend_commands
  backend_commands="$(cat <<'TEXT'
- Executed: `xcodegen generate --spec project.yml`.
- Not executed: Tuist commands, CI generation, Fastlane setup, signing mutation, App Store Connect mutation, screenshot generation, metadata generation, or upload.
TEXT
)"
  local doc=""
  branch_handoff="$(branch_handoff_text "$branch_policy")"
  forge_handoff="$(forge_handoff_text "$forge_provider")"

  if [[ "$backend" == "tuist" ]]; then
    backend_label="Tuist"
    backend_evidence="Selected backend: tuist. Tuist version evidence: ${tuist_version:-unknown}."
    if [[ "$mise_status" == "available" ]]; then
      backend_evidence+=" Mise provider evidence: available${mise_version:+ ($mise_version)}."
    elif [[ "$mise_status" == "missing" ]]; then
      backend_evidence+=" Mise provider evidence: missing; global Tuist or another PATH-provided Tuist was used."
    fi
    backend_commands="$(cat <<'TEXT'
- Executed: `tuist generate --no-open`.
- Not executed: `tuist init`, `tuist edit`, `tuist graph`, `tuist install`, Tuist Cloud, registry/cache/previews/test-insights setup, CI generation, Fastlane setup, signing mutation, App Store Connect mutation, screenshot generation, metadata generation, or upload.
TEXT
)"
  fi

  if [[ "$release_intent" == *"testflight-aware"* && "$release_intent" == *"app-store-aware"* ]]; then
      release_intent_label="TestFlight-aware and App Store-aware"
      release_intent_guidance="Release intent: TestFlight-aware and App Store-aware handoff requested. Run release-readiness, build-release-ops, ASO, release-notes, manual-validation, and quality-gates follow-up before archive, signing, TestFlight upload, metadata, screenshot, or App Store submission work."
  elif [[ "$release_intent" == *"testflight-aware"* ]]; then
      release_intent_label="TestFlight-aware"
      release_intent_guidance="Release intent: TestFlight-aware handoff requested. Run release-readiness and build-release-ops follow-up before archive, signing, or upload work."
  elif [[ "$release_intent" == *"app-store-aware"* ]]; then
      release_intent_label="App Store-aware"
      release_intent_guidance="Release intent: App Store-aware handoff requested. Run release-readiness, build-release-ops, ASO, and release-notes follow-up before archive, metadata, screenshot, signing, or upload work."
  fi

  doc="$(cat <<'TEXT'
## Bootstrap Handoff

Use this scaffold as a handoff point, not as a finished app baseline.

### Next Steps

1. Confirm product context, acceptance criteria, and non-goals.
2. Complete repository handoff: __BRANCH_HANDOFF__
3. Follow the forge handoff: __FORGE_HANDOFF__
4. Run validation handoff with XcodeBuildMCP before feature work.
5. Scope the first product slice with `$apple-appdev-workflow:apple-app-orchestrator`.
6. Route release, signing, CI/CD, TestFlight, or App Store work through the
   release owner lanes only after product context is real.

## Backend Handoff

Backend: __BACKEND_LABEL__.
__BACKEND_EVIDENCE__

__BACKEND_COMMANDS__

## Release Handoff

Bootstrap is release-aware, not release-executing. Release intent: __RELEASE_INTENT_LABEL__.

This scaffold does not configure signing, upload builds, create App Store
Connect records, install Fastlane, or generate CI release automation by
default.

- __RELEASE_INTENT_GUIDANCE__
- Signing and provisioning: unknown until a release follow-up confirms the
  Apple Developer Team, entitlements, bundle identifier ownership, and archive
  signing settings.
- App Store Connect app record: unknown until release follow-up verifies or
  creates the record outside bootstrap.
- TestFlight readiness: hand off to
  `$apple-appdev-workflow:apple-release-orchestrator` and
  `$apple-appdev-workflow:apple-build-release-ops` before archive or upload
  work.
- CI/CD and Fastlane/GitHub Actions setup: hand off through
  `$apple-appdev-workflow:apple-release-orchestrator` first, then narrow to
  `$apple-appdev-workflow:apple-build-release-ops`.
- App Store metadata and screenshots: hand off to
  `$apple-appdev-workflow:apple-app-store-aso` and
  `$apple-appdev-workflow:apple-app-store-release-notes`.
- Privacy, support, marketing, and review-contact URLs: placeholders remain
  unresolved until release readiness work supplies real product values.

### Follow-On Owner Matrix

| Follow-on work | Owner lane | When to use |
| --- | --- | --- |
| Architecture boundaries | `$apple-appdev-workflow:apple-architecture-design` | Before extracting modules, adding service seams, or changing dependency direction. |
| Product surface and design system | `$apple-appdev-workflow:apple-design-system-ux` | Before growing starter UI into reusable app components. |
| First product feature | `$apple-appdev-workflow:apple-feature-implementation` | After branch handoff and acceptance criteria are clear. |
| Unit and integration tests | `$apple-appdev-workflow:apple-swift-testing-foundations` plus `$apple-appdev-workflow:apple-testing-quality-gates` | Before claiming feature completion or release readiness. |
| Release readiness | `$apple-appdev-workflow:apple-release-orchestrator` | Before archive, signing, TestFlight, App Store, or go/no-go decisions. |
| Archive, signing, CI/CD, Fastlane, GitHub Actions | `$apple-appdev-workflow:apple-build-release-ops` | After release orchestration scopes release-ops work. |
| App Store Connect, metadata, screenshots, privacy, ASO | `$apple-appdev-workflow:apple-app-store-aso` | After product positioning and release intent are real. |
| User-facing changelog | `$apple-appdev-workflow:apple-app-store-release-notes` | Before App Store submission or public release notes. |
| Manual/device validation | `$apple-appdev-workflow:apple-manual-validation` | When simulator evidence is insufficient or device-only behavior matters. |
TEXT
)"
  doc="${doc/__BRANCH_HANDOFF__/$branch_handoff}"
  doc="${doc/__FORGE_HANDOFF__/$forge_handoff}"
  doc="${doc/__BACKEND_LABEL__/$backend_label}"
  doc="${doc/__BACKEND_EVIDENCE__/$backend_evidence}"
  doc="${doc/__BACKEND_COMMANDS__/$backend_commands}"
  doc="${doc/__RELEASE_INTENT_LABEL__/$release_intent_label}"
  doc="${doc/__RELEASE_INTENT_GUIDANCE__/$release_intent_guidance}"
  printf '%s\n' "$doc"
}

adopt_owner_handoff_block() {
  cat <<'TEXT'
## Adoption Handoff

Adopt mode is an assessment and handoff boundary. It does not authorize source
mutation, branch creation, release automation, signing changes, or starter
template regeneration.

### Follow-On Owner Matrix

| Follow-on work | Owner lane | When to use |
| --- | --- | --- |
| Repository reality discovery | `$apple-appdev-workflow:apple-discovery-first` | Before changing existing sources, tests, project files, package manifests, or build settings. |
| Architecture boundaries | `$apple-appdev-workflow:apple-architecture-design` | Before restructuring modules, adding service seams, or changing dependency direction. |
| Product surface and design system | `$apple-appdev-workflow:apple-product-surface-orchestrator` | Before growing or redesigning existing UI surfaces. |
| First product feature | `$apple-appdev-workflow:apple-feature-implementation` | After discovery, branch handoff, and acceptance criteria are clear. |
| Unit and integration tests | `$apple-appdev-workflow:apple-swift-testing-foundations` plus `$apple-appdev-workflow:apple-testing-quality-gates` | Before claiming adopted-project changes are complete. |
| Release readiness | `$apple-appdev-workflow:apple-release-orchestrator` | Before archive, signing, TestFlight, App Store, or go/no-go decisions. |
| Archive, signing, CI/CD, Fastlane, GitHub Actions | `$apple-appdev-workflow:apple-build-release-ops` | After release orchestration scopes release-ops work. |
| App Store Connect, metadata, screenshots, privacy, ASO | `$apple-appdev-workflow:apple-app-store-aso` | After product positioning and release intent are real. |
| Manual/device validation | `$apple-appdev-workflow:apple-manual-validation` | When simulator or package evidence is insufficient. |
TEXT
}

adopt_validation_handoff_block() {
  local artifact_shape="$1"

  if [[ "$artifact_shape" == "package-native" ]]; then
    cat <<'TEXT'
## Validation Handoff

- Baseline shape command: `swift package describe`.
- Preferred MCP path: use `swift_package_build` and `swift_package_test` from XcodeBuildMCP.
- CLI fallback: `swift build` and `swift test` from the package root when MCP package tools are unavailable or misconfigured.
- Do not infer app, simulator, signing, archive, or App Store readiness from package-only validation.
TEXT
    return
  fi

  cat <<'TEXT'
## Validation Handoff

- Preferred MCP path: use XcodeBuildMCP project discovery, scheme selection, simulator or macOS build, and test tools.
- CLI fallback: use raw `xcodebuild` only when XcodeBuildMCP is unavailable, misconfigured, or lacks the required timeout/surface for the current target.
- If the project has packages, validate package boundaries separately with SwiftPM before adding or moving package ownership seams.
- Do not infer signing, archive, TestFlight, or App Store readiness from a clean debug build.
TEXT
}

adopt_release_handoff_block() {
  if release_intent_has "testflight-aware" || release_intent_has "app-store-aware"; then
    cat <<'TEXT'
## Release Handoff

- Adopt mode recorded release intent, but did not mutate signing, provisioning, CI/CD, Fastlane, App Store Connect, metadata, screenshots, privacy URLs, or upload state.
- Run `$apple-appdev-workflow:apple-release-orchestrator` before any release-readiness or go/no-go claim.
- Route archive, signing, CI/CD, Fastlane, and GitHub Actions setup through `$apple-appdev-workflow:apple-build-release-ops` after release orchestration scopes the work.
- Route App Store Connect, metadata, screenshots, privacy, and ASO through `$apple-appdev-workflow:apple-app-store-aso` after product positioning is real.
TEXT
    return
  fi

  cat <<'TEXT'
## Release Handoff

- No release intent was declared during adoption. Treat release, signing, CI/CD, TestFlight, and App Store work as later explicit follow-up.
- Adopt mode did not mutate signing, provisioning, CI/CD, Fastlane, App Store Connect, metadata, screenshots, privacy URLs, or upload state.
TEXT
}

branch_handoff_text() {
  local branch_policy="$1"
  case "$branch_policy" in
    harness-topic-ready)
      printf 'Repository policy `harness-topic-ready`: git provenance is required; create the first topic branch from the intended integration branch before implementation.'
      ;;
    legacy-codex-dev)
      printf 'Repository policy `legacy-codex-dev`: git provenance is required; create the first topic branch from `codex/dev` before implementation.'
      ;;
    *)
      printf 'Repository policy `init-main-only`: default scaffold policy initializes `main` only. Create a topic branch from the intended integration branch before implementation.'
      ;;
  esac
}

forge_handoff_text() {
  local forge_provider="$1"
  case "$forge_provider" in
    gitlab)
      printf 'Forge provider `gitlab`: use a short-lived topic branch and merge request into the intended integration branch. Bootstrap does not create GitLab remotes, protected branches, CI, or release automation.'
      ;;
    generic)
      printf "Forge provider \`generic\`: use the target forge's reviewed branch-merge flow into the intended integration branch. Bootstrap does not create remotes, protected branches, CI, or release automation."
      ;;
    *)
      printf 'Forge provider `github`: use a short-lived topic branch and pull request into the intended integration branch. Bootstrap does not create GitHub remotes, branch protection, Actions, or release automation.'
      ;;
  esac
}

adopt_branch_step_text() {
  local branch_policy="$1"
  case "$branch_policy" in
    harness-topic-ready)
      printf 'Create or switch to a scoped topic branch from the existing intended integration branch before implementation.'
      ;;
    legacy-codex-dev)
      printf 'Confirm `codex/dev` exists and create the first topic branch from `codex/dev` before implementation; adopt mode does not create missing legacy branches.'
      ;;
    *)
      printf "Create a scoped topic branch from the repository's intended integration branch before implementation; if no git repo exists, initialize or attach git provenance first."
      ;;
  esac
}

adopt_git_state_block() {
  local path="$1"
  local root=""
  local branch=""
  local clean="unknown"
  if root="$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)"; then
    branch="$(git -C "$path" branch --show-current 2>/dev/null || true)"
    if [[ -z "$branch" ]]; then
      branch="$(git -C "$path" rev-parse --short HEAD 2>/dev/null || true)"
      [[ -z "$branch" ]] && branch="detached-or-unborn"
    fi
    if [[ -z "$(git -C "$path" status --porcelain 2>/dev/null)" ]]; then
      clean="yes"
    else
      clean="no"
    fi
    printf -- '- Git root: %s\n' "$root"
    printf -- '- Current branch: %s\n' "$branch"
    printf -- '- Working tree clean: %s\n' "$clean"
  else
    printf -- '- Git root: not detected\n'
    printf -- '- Current branch: not available\n'
    printf -- '- Working tree clean: unknown\n'
  fi
}

tuist_destinations() {
  if [[ "$PLATFORM" == "ios" ]]; then
    printf '.iOS'
  else
    printf '.macOS'
  fi
}

tuist_deployment_targets() {
  if [[ "$PLATFORM" == "ios" ]]; then
    printf '.iOS("%s")' "$DEPLOYMENT_TARGET"
  else
    printf '.macOS("%s")' "$DEPLOYMENT_TARGET"
  fi
}

write_tuist_project() {
  local project_dir="$1"
  local destinations
  local deployment_targets
  local package_entries
  local app_dependencies
  local test_dependencies
  destinations="$(tuist_destinations)"
  deployment_targets="$(tuist_deployment_targets)"
  package_entries="$(tuist_package_entries "$PACKAGES")"
  app_dependencies="$(tuist_app_dependencies "$PACKAGES")"
  test_dependencies="$(tuist_test_dependencies "$PACKAGES" "$PRODUCT_NAME")"

  # Tuist resolves the project root from a Tuist/ or .git directory. Create a
  # stable marker before generation because git is initialized after generation.
  mkdir -p "$project_dir/Tuist"
  touch "$project_dir/Tuist/.gitkeep"

  cat > "$project_dir/Project.swift" <<TUIST_PROJECT
import ProjectDescription

let project = Project(
    name: "$PRODUCT_NAME",
    packages: $package_entries,
    settings: .settings(base: [
        "SWIFT_TREAT_WARNINGS_AS_ERRORS": "YES",
        "GCC_TREAT_WARNINGS_AS_ERRORS": "YES",
        "SWIFT_STRICT_CONCURRENCY": "complete",
        "SWIFT_VERSION": "6.0",
        "ENABLE_TESTABILITY": "YES",
    ]),
    targets: [
        .target(
            name: "$PRODUCT_NAME",
            destinations: $destinations,
            product: .app,
            bundleId: "$BUNDLE_ID",
            deploymentTargets: $deployment_targets,
            infoPlist: .file(path: "App/Support/Info.plist"),
            sources: ["App/**"],
            resources: ["Resources/**"],
            dependencies: $app_dependencies,
            settings: .settings(base: [
                "PRODUCT_BUNDLE_IDENTIFIER": "$BUNDLE_ID",
                "PRODUCT_NAME": "$PRODUCT_NAME",
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                "CURRENT_PROJECT_VERSION": "1",
                "MARKETING_VERSION": "1.0",
            ])
        ),
        .target(
            name: "${PRODUCT_NAME}Tests",
            destinations: $destinations,
            product: .unitTests,
            bundleId: "$BUNDLE_ID.Tests",
            deploymentTargets: $deployment_targets,
            infoPlist: .file(path: "Tests/Info.plist"),
            sources: ["Tests/**"],
            dependencies: $test_dependencies
        ),
    ]
)
TUIST_PROJECT
}

write_report_if_requested() {
  local content="$1"
  if [[ -n "$REPORT_FILE" ]]; then
    mkdir -p "$(dirname "$REPORT_FILE")"
    printf '%s\n' "$content" > "$REPORT_FILE"
    echo "Wrote report: $REPORT_FILE"
  fi
}

initialize_repo_if_needed() {
  local project_dir="$1"
  local branch_policy="$2"

  if git -C "$project_dir" rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "Git repository already present for scaffold path; skipping repo initialization."
    return 0
  fi
  (
    cd "$project_dir"
    git init -b main >/dev/null
    git add -A
    git commit -m "Initial scaffold" >/dev/null
    if [[ "$branch_policy" == "legacy-codex-dev" ]]; then
      git branch dev main >/dev/null
      git branch codex/dev dev >/dev/null
    fi
  )
  if [[ "$branch_policy" == "legacy-codex-dev" ]]; then
    echo "Initialized new git repository at $project_dir with an initial scaffold commit on main plus dev and codex/dev branches"
  elif [[ "$branch_policy" == "harness-topic-ready" ]]; then
    echo "Initialized new git repository at $project_dir with an initial scaffold commit on main; create the first topic branch from the intended integration branch before feature work"
  else
    echo "Initialized new git repository at $project_dir with an initial scaffold commit on main"
  fi
}

count_matches() {
  local pattern="$1"
  local path="$2"
  local matches
  matches="$(rg --glob '*.swift' --glob 'Package.swift' -c "$pattern" "$path" 2>/dev/null || true)"
  if [[ -z "$matches" ]]; then
    echo 0
    return 0
  fi
  printf '%s\n' "$matches" | awk -F: '{sum += $2} END {print sum + 0}'
}

if [[ "$BRANCH_POLICY" == "none" ]]; then
  echo "Unsupported repository policy: none. Bootstrap always initializes or reuses git provenance; use init-main-only, harness-topic-ready, or legacy-codex-dev." >&2
  exit 1
fi

if [[ "$BRANCH_POLICY" != "init-main-only" && "$BRANCH_POLICY" != "harness-topic-ready" && "$BRANCH_POLICY" != "legacy-codex-dev" ]]; then
  echo "Unsupported repository policy: $BRANCH_POLICY" >&2
  exit 1
fi

if [[ "$FORGE_PROVIDER" != "github" && "$FORGE_PROVIDER" != "gitlab" && "$FORGE_PROVIDER" != "generic" ]]; then
  echo "Unsupported forge provider: $FORGE_PROVIDER" >&2
  exit 1
fi

if ! RELEASE_INTENT="$(normalize_release_intents "${RELEASE_INTENT_VALUES[@]}")"; then
  exit 1
fi

if [[ "$BACKEND" != "xcodegen" && "$BACKEND" != "tuist" ]]; then
  echo "Unsupported backend: $BACKEND" >&2
  exit 1
fi

if [[ "$MODE" == "adopt" ]]; then
  if [[ ! -d "$OUTPUT" ]]; then
    echo "Existing project directory not found: $OUTPUT" >&2
    exit 1
  fi

  workspaces=()
  while IFS= read -r path; do
    workspaces+=("$path")
  done < <(find "$OUTPUT" -maxdepth 3 -name '*.xcworkspace' | sort)

  projects=()
  while IFS= read -r path; do
    projects+=("$path")
  done < <(find "$OUTPUT" -maxdepth 3 -name '*.xcodeproj' | sort)

  swiftui_count="$(count_matches '^[[:space:]]*import[[:space:]]+SwiftUI' "$OUTPUT")"
  uikit_count="$(count_matches '^[[:space:]]*import[[:space:]]+UIKit' "$OUTPUT")"
  appkit_count="$(count_matches '^[[:space:]]*import[[:space:]]+AppKit' "$OUTPUT")"
  package_manifest_count="$(find "$OUTPUT" -name 'Package.swift' | wc -l | tr -d ' ')"

  if [[ ${#workspaces[@]} -eq 0 && ${#projects[@]} -eq 0 && "$package_manifest_count" -eq 0 ]]; then
    echo "No Xcode project, workspace, or Swift package found under $OUTPUT" >&2
    exit 1
  fi

  test_dir_count="$(find "$OUTPUT" \( -name '*Tests' -o -name '*.xctestplan' \) | wc -l | tr -d ' ')"
  has_tests="no"
  [[ "$test_dir_count" -gt 0 ]] && has_tests="yes"
  has_packages="no"
  [[ "$package_manifest_count" -gt 0 ]] && has_packages="yes"

  surface_summary=""
  if [[ "$swiftui_count" -gt 0 ]]; then
    surface_summary+="SwiftUI"
  fi
  if [[ "$uikit_count" -gt 0 ]]; then
    [[ -n "$surface_summary" ]] && surface_summary+=", "
    surface_summary+="UIKit"
  fi
  if [[ "$appkit_count" -gt 0 ]]; then
    [[ -n "$surface_summary" ]] && surface_summary+=", "
    surface_summary+="AppKit"
  fi
  [[ -z "$surface_summary" ]] && surface_summary="No clear UI framework signals detected"

  artifact_shape="project-backed"
  if [[ ${#workspaces[@]} -eq 0 && ${#projects[@]} -eq 0 && "$package_manifest_count" -gt 0 ]]; then
    artifact_shape="package-native"
  elif [[ ${#workspaces[@]} -gt 0 || ${#projects[@]} -gt 0 ]] && [[ "$package_manifest_count" -gt 0 ]]; then
    artifact_shape="project-backed-with-packages"
  fi

  support_status="supported"
  support_note="Existing iOS/macOS Xcode project is in scope for adopt mode."
  if [[ "$artifact_shape" == "package-native" ]]; then
    support_note="Pure Swift package is in scope for package-native adoption and validation."
  fi
  if [[ "$uikit_count" -gt 0 || "$appkit_count" -gt 0 ]]; then
    support_status="partially-supported"
    support_note="UIKit/AppKit existing projects are supported for adopt guidance only, not greenfield template regeneration."
  fi

  repo_name="$(basename "$OUTPUT")"
  report="# Apple App Bootstrap Adopt Report\n\n"
  report+="## Assessment\n\n"
  report+="- Mode: adopt\n"
  report+="- Project root: $OUTPUT\n"
  report+="- Support status: $support_status\n"
  report+="- Summary: $support_note\n"
  report+="- Release intent: $(release_intent_label)\n\n"
  report+="## Project Shape\n\n"
  report+="- Artifact shape: $artifact_shape\n"
  report+="- Workspaces found: ${#workspaces[@]}\n"
  report+="- Projects found: ${#projects[@]}\n"
  report+="- UI surface signals: $surface_summary\n"
  report+="- Swift package manifests: $package_manifest_count\n"
  report+="- Test artifacts detected: $has_tests\n"
  report+="- Swift package usage detected: $has_packages\n\n"
  report+="## Follow-Up Priorities\n\n"
  report+="1. Fill the core development context for $repo_name.\n"
  report+="2. Run \$apple-appdev-workflow:apple-discovery-first against the existing project or package.\n"
  if [[ "$artifact_shape" == "package-native" ]]; then
    report+="3. Use swift package describe plus MCP swift_package_* workflows to verify the package baseline.\n"
  else
    report+="3. Use XcodeBuildMCP to discover projects, schemes, and a clean baseline build.\n"
  fi
  report+="4. Run \$apple-appdev-workflow:apple-architecture-design before structural changes.\n"
  report+="5. Run \$apple-appdev-workflow:apple-swift-testing-foundations and \$apple-appdev-workflow:apple-testing-quality-gates if test coverage is weak or missing.\n"
  if [[ "$uikit_count" -gt 0 || "$appkit_count" -gt 0 ]]; then
    report+="6. Treat UI adoption as framework-specific follow-up work; do not assume SwiftUI starter conventions map directly.\n"
  else
    report+="6. Review design-system and accessibility baselines before expanding UI work.\n"
  fi
  if [[ "$has_packages" == "yes" ]]; then
    report+="7. Review existing package boundaries before adding new ones.\n"
  else
    report+="7. Keep packaging decisions conservative until real ownership seams appear.\n"
  fi
  report+="\n## Notes\n\n"
  report+="- Adopt mode does not regenerate sources or rewrite project files.\n"
  report+="- Reduced or missing MCP workflow exposure should be treated as configuration drift, not a reason to normalize shell-first project workflows.\n"
  report+="\n$(adopt_owner_handoff_block)\n"
  report+="\n$(adopt_validation_handoff_block "$artifact_shape")\n"
  report+="\n$(adopt_release_handoff_block)\n"
  report+="\n## Git And Branch Handoff\n\n"
  report+="- Repository policy: $BRANCH_POLICY\n"
  report+="- Forge provider: $FORGE_PROVIDER\n"
  report+="$(adopt_git_state_block "$OUTPUT")\n"
  report+="- Next branch step: $(adopt_branch_step_text "$BRANCH_POLICY")\n"
  report+="- $(branch_handoff_text "$BRANCH_POLICY")\n"
  report+="- $(forge_handoff_text "$FORGE_PROVIDER")\n"
  report+="- Adopt mode does not create branches, remotes, protected branches, CI, or release automation.\n"

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] adopt mode would inspect project at $OUTPUT"
    if [[ -n "$REPORT_FILE" ]]; then
      echo "[dry-run] would write report to $REPORT_FILE"
    fi
    printf '%b' "$report"
    exit 0
  fi

  printf '%b' "$report"
  write_report_if_requested "$(printf '%b' "$report")"
  exit 0
fi

if [[ "$MODE" != "new" ]]; then
  echo "Unsupported mode: $MODE" >&2
  exit 1
fi

if [[ -z "$APP_NAME" || -z "$BUNDLE_ID" || -z "$PLATFORM" ]]; then
  echo "Missing required arguments for new mode: --name, --bundle-id, --platform" >&2
  exit 1
fi

if [[ "$UI" != "swiftui" ]]; then
  echo "Phase 2 still supports --ui swiftui only for greenfield generation" >&2
  echo "Use adopt mode for existing UIKit/AppKit projects; greenfield UIKit/AppKit starter support requires a separate planned profile." >&2
  exit 1
fi

if [[ "$PLATFORM" != "ios" && "$PLATFORM" != "macos" ]]; then
  echo "Unsupported platform: $PLATFORM" >&2
  exit 1
fi

if [[ "$LAYOUT_MODE" != "single-target" && "$LAYOUT_MODE" != "app-plus-packages" ]]; then
  echo "Unsupported layout mode: $LAYOUT_MODE" >&2
  exit 1
fi

if [[ "$PACKAGE_TEST_POLICY" != "defer" && "$PACKAGE_TEST_POLICY" != "include" ]]; then
  echo "Unsupported package test policy: $PACKAGE_TEST_POLICY" >&2
  exit 1
fi

if [[ -z "$DEPLOYMENT_TARGET" ]]; then
  if [[ $ALLOW_DEFAULT_DEPLOYMENT_TARGET -ne 1 ]]; then
    echo "Missing --deployment-target. Pass an explicit target or --allow-default-deployment-target after explicit user approval." >&2
    exit 1
  fi
  resolve_default_deployment_target "$PLATFORM"
fi

if [[ -n "$PACKAGES" ]]; then
  LAYOUT_MODE="app-plus-packages"
fi

if [[ "$BACKEND" == "tuist" ]]; then
  preflight_tuist
fi

PRODUCT_NAME="$(sanitize_product_name "$APP_NAME")"
if [[ -z "$PRODUCT_NAME" ]]; then
  echo "App name must contain letters or digits after sanitization." >&2
  exit 1
fi

if [[ "$PLATFORM" == "ios" ]]; then
  PLATFORM_LABEL="iOS"
else
  PLATFORM_LABEL="macOS"
fi

TEMPLATE_DIR="$TEMPLATE_ROOT/${PLATFORM}-swiftui"
if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Template not found: $TEMPLATE_DIR" >&2
  exit 1
fi

EFFECTIVE_CONTENT=""
if [[ -e "$OUTPUT" ]]; then
  EFFECTIVE_CONTENT="$(find "$OUTPUT" -mindepth 1 -maxdepth 1 \
    ! -name '.DS_Store' \
    ! -name '.localized' \
    ! -name '.gitkeep' \
    2>/dev/null | head -n 1)"
fi

if [[ -e "$OUTPUT" && -n "$EFFECTIVE_CONTENT" ]]; then
  if [[ $REGENERATE -ne 1 ]]; then
    echo "Output directory exists and is not empty: $OUTPUT" >&2
    echo "Use --regenerate to overwrite scaffold outputs intentionally." >&2
    exit 1
  fi
fi

PACKAGES_SECTION=""
APP_TARGET_DEPENDENCIES="      []"
TEST_TARGET_DEPENDENCIES="      - target: $PRODUCT_NAME"
PLATFORMS_BLOCK=""
PACKAGE_SUMMARY="single-target"
LOCAL_PACKAGES_SUMMARY="none"
PACKAGE_GUIDANCE="$(package_guidance_block "")"
GENERATED_DOCS_BLOCK="$(generated_docs_block "$BRANCH_POLICY" "$RELEASE_INTENT" "$BACKEND" "$TUIST_VERSION" "$MISE_STATUS" "$MISE_VERSION" "$FORGE_PROVIDER")"
BACKEND_VERSION_EVIDENCE="not captured"
BACKEND_PROVIDER_EVIDENCE="not applicable for xcodegen"
BACKEND_COMMANDS_EXECUTED="xcodegen generate --spec project.yml"
BACKEND_COMMANDS_NOT_EXECUTED="Tuist commands; CI generation; Fastlane setup; signing mutation; App Store Connect mutation; screenshot generation; metadata generation; upload"
if [[ "$BACKEND" == "tuist" ]]; then
  BACKEND_VERSION_EVIDENCE="$TUIST_VERSION"
  if [[ "$MISE_STATUS" == "available" ]]; then
    BACKEND_PROVIDER_EVIDENCE="mise available${MISE_VERSION:+ ($MISE_VERSION)}"
  else
    BACKEND_PROVIDER_EVIDENCE="mise missing; tuist was provided by PATH/global/another tool"
  fi
  BACKEND_COMMANDS_EXECUTED="tuist generate --no-open"
  BACKEND_COMMANDS_NOT_EXECUTED="tuist init; tuist edit; tuist graph; tuist install; Tuist Cloud; registry/cache/previews/test-insights setup; CI generation; Fastlane setup; signing mutation; App Store Connect mutation; screenshot generation; metadata generation; upload"
fi

if [[ "$LAYOUT_MODE" == "app-plus-packages" ]]; then
  PACKAGES_SECTION="$(join_packages_section "$PACKAGES")"
  APP_TARGET_DEPENDENCIES="$(join_target_dependencies "$PACKAGES" app)"
  TEST_TARGET_DEPENDENCIES="      - target: $PRODUCT_NAME"
  EXTRA_TEST_DEPS="$(join_target_dependencies "$PACKAGES" tests)"
  if [[ "$EXTRA_TEST_DEPS" != "      []" ]]; then
    TEST_TARGET_DEPENDENCIES="${TEST_TARGET_DEPENDENCIES}"$'\n'"${EXTRA_TEST_DEPS}"
  fi
  PLATFORMS_BLOCK="$(spm_platform_line "$PLATFORM" "$DEPLOYMENT_TARGET")"
  PACKAGE_SUMMARY="$(join_csv "$PACKAGES")"
  LOCAL_PACKAGES_SUMMARY="$PACKAGE_SUMMARY"
  PACKAGE_GUIDANCE="$(package_guidance_block "$PACKAGES")"
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo "[dry-run] mode=new"
  echo "[dry-run] platform=$PLATFORM ui=$UI layout_mode=$LAYOUT_MODE backend=$BACKEND"
  if [[ "$BACKEND" == "tuist" ]]; then
    echo "[dry-run] tuist_version=$TUIST_VERSION"
    echo "[dry-run] mise_provider=$MISE_STATUS${MISE_VERSION:+ ($MISE_VERSION)}"
  fi
  echo "[dry-run] output=$OUTPUT"
  echo "[dry-run] product_name=$PRODUCT_NAME deployment_target=$DEPLOYMENT_TARGET deployment_target_source=$DEPLOYMENT_TARGET_SOURCE"
  if [[ -n "$DEPLOYMENT_TARGET_OBSERVED" ]]; then
    echo "[dry-run] deployment_target_observed_runtime=$DEPLOYMENT_TARGET_OBSERVED"
  fi
  echo "[dry-run] packages=${PACKAGES:-<none>}"
  echo "[dry-run] repo_policy=$BRANCH_POLICY forge_provider=$FORGE_PROVIDER package_test_policy=$PACKAGE_TEST_POLICY release_intent=$RELEASE_INTENT"
  exit 0
fi

rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"
python3 "$RENDER" \
  --src "$TEMPLATE_DIR" \
  --dst "$OUTPUT" \
  --var "APP_NAME=$APP_NAME" \
  --var "APP_PRODUCT_NAME=$PRODUCT_NAME" \
  --var "BUNDLE_ID=$BUNDLE_ID" \
  --var "DEPLOYMENT_TARGET=$DEPLOYMENT_TARGET" \
  --var "PLATFORM_LABEL=$PLATFORM_LABEL" \
  --var "PACKAGES_SECTION=$PACKAGES_SECTION" \
  --var "APP_TARGET_DEPENDENCIES=$APP_TARGET_DEPENDENCIES" \
  --var "TEST_TARGET_DEPENDENCIES=$TEST_TARGET_DEPENDENCIES" \
  --var "LAYOUT_MODE=$LAYOUT_MODE" \
  --var "LOCAL_PACKAGES_SUMMARY=$LOCAL_PACKAGES_SUMMARY" \
  --var "PACKAGE_SUMMARY=$PACKAGE_SUMMARY" \
  --var "BRANCH_POLICY=$BRANCH_POLICY" \
  --var "FORGE_PROVIDER=$FORGE_PROVIDER" \
  --var "RELEASE_INTENT=$RELEASE_INTENT" \
  --var "BACKEND=$BACKEND" \
  --var "BACKEND_VERSION_EVIDENCE=$BACKEND_VERSION_EVIDENCE" \
  --var "BACKEND_PROVIDER_EVIDENCE=$BACKEND_PROVIDER_EVIDENCE" \
  --var "BACKEND_COMMANDS_EXECUTED=$BACKEND_COMMANDS_EXECUTED" \
  --var "BACKEND_COMMANDS_NOT_EXECUTED=$BACKEND_COMMANDS_NOT_EXECUTED" \
  --var "PACKAGE_GUIDANCE=$PACKAGE_GUIDANCE" \
  --var "GENERATED_DOCS_BLOCK=$GENERATED_DOCS_BLOCK"

if [[ "$LAYOUT_MODE" == "app-plus-packages" && -n "$PACKAGES" ]]; then
  IFS=',' read -ra items <<< "$PACKAGES"
  for item in "${items[@]}"; do
    pkg="$(trim "$item")"
    [[ -z "$pkg" ]] && continue
    create_spm_package "$OUTPUT" "$pkg" "$PLATFORMS_BLOCK" "$PACKAGE_TEST_POLICY"
  done
fi

if [[ "$BACKEND" == "tuist" ]]; then
  rm -f "$OUTPUT/project.yml"
  write_tuist_project "$OUTPUT"
  (
    cd "$OUTPUT"
    tuist generate --no-open >/dev/null
  )
else
  (
    cd "$OUTPUT"
    xcodegen generate --spec project.yml >/dev/null
  )
  rm -f "$OUTPUT/project.yml"
fi

initialize_repo_if_needed "$OUTPUT" "$BRANCH_POLICY"

echo "Scaffolded $APP_NAME at $OUTPUT"
echo "Layout mode: $LAYOUT_MODE"
echo "Deployment target: $DEPLOYMENT_TARGET ($DEPLOYMENT_TARGET_SOURCE)"
if [[ -n "$DEPLOYMENT_TARGET_OBSERVED" ]]; then
  echo "Deployment target observed runtime: $DEPLOYMENT_TARGET_OBSERVED"
fi
echo "Repository policy: $BRANCH_POLICY"
echo "Forge provider: $FORGE_PROVIDER"
echo "Release intent: $RELEASE_INTENT"
if [[ "$BACKEND" == "tuist" ]]; then
  echo "Tuist version: $TUIST_VERSION"
  echo "Mise provider: $MISE_STATUS${MISE_VERSION:+ ($MISE_VERSION)}"
fi
if [[ "$LAYOUT_MODE" == "app-plus-packages" ]]; then
  echo "Local packages: ${PACKAGES:-<none>}"
  echo "Package test policy: $PACKAGE_TEST_POLICY"
fi

echo "Next steps:"
echo "- Open the generated project and confirm the baseline and layout guidance in README.md"
echo '- If this is a standalone scaffold, create the first topic branch from the intended integration branch before feature work'
echo "- Use \$apple-appdev-workflow:apple-architecture-design to refine boundaries before feature growth"
echo "- Use XcodeBuildMCP to discover schemes and validate a clean build"
echo "- Continue through \$apple-appdev-workflow:apple-design-system-ux and \$apple-appdev-workflow:apple-feature-implementation"
echo "- Add or update tests with \$apple-appdev-workflow:apple-swift-testing-foundations, then hold completion until \$apple-appdev-workflow:apple-testing-quality-gates are green"
