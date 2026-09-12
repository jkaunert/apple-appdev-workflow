#!/usr/bin/env python3
from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import re
import selectors
import subprocess
import sys
import tarfile
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path, PurePosixPath
from typing import Any, Callable


REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_LOCK = REPO_ROOT / "runtime" / "xcodebuildmcp" / "runtime-lock.json"
DEFAULT_ENV = REPO_ROOT / "runtime" / "xcodebuildmcp" / "runtime.env"
EXPECTED_PACKAGE = "xcodebuildmcp"
EXPECTED_REPOSITORY = "https://github.com/getsentry/XcodeBuildMCP"
EXPECTED_WORKFLOW = ".github/workflows/release.yml"
EXPECTED_PLATFORMS = {"darwin-arm64", "darwin-x64", "darwin-universal"}
REQUIRED_ENV_KEYS = {
    "XCODEBUILDMCP_RUNTIME_VERSION",
    "XCODEBUILDMCP_DARWIN_ARM64_SHA256",
    "XCODEBUILDMCP_DARWIN_ARM64_SIZE",
    "XCODEBUILDMCP_DARWIN_X64_SHA256",
    "XCODEBUILDMCP_DARWIN_X64_SIZE",
    "XCODEBUILDMCP_ENABLED_WORKFLOWS",
}
HEX_40 = re.compile(r"^[0-9a-f]{40}$")
HEX_64 = re.compile(r"^[0-9a-f]{64}$")
SEMVER = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+(?:[-+][0-9A-Za-z.-]+)?$")


class LockError(RuntimeError):
    pass


def load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text())
    except FileNotFoundError as exc:
        raise LockError(f"missing JSON file: {path}") from exc
    except json.JSONDecodeError as exc:
        raise LockError(f"invalid JSON in {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise LockError(f"expected a JSON object in {path}")
    return value


def require_object(parent: dict[str, Any], key: str) -> dict[str, Any]:
    value = parent.get(key)
    if not isinstance(value, dict):
        raise LockError(f"{key} must be an object")
    return value


def require_string(parent: dict[str, Any], key: str) -> str:
    value = parent.get(key)
    if not isinstance(value, str) or not value:
        raise LockError(f"{key} must be a non-empty string")
    return value


def require_integer(parent: dict[str, Any], key: str) -> int:
    value = parent.get(key)
    if not isinstance(value, int) or isinstance(value, bool) or value <= 0:
        raise LockError(f"{key} must be a positive integer")
    return value


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def parse_env(path: Path) -> dict[str, str]:
    try:
        lines = path.read_text().splitlines()
    except FileNotFoundError as exc:
        raise LockError(f"missing runtime environment file: {path}") from exc
    values: dict[str, str] = {}
    for number, raw_line in enumerate(lines, start=1):
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            raise LockError(f"invalid runtime.env line {number}: {raw_line!r}")
        key, value = line.split("=", 1)
        if not re.fullmatch(r"[A-Z0-9_]+", key):
            raise LockError(f"invalid runtime.env key on line {number}: {key!r}")
        if key in values:
            raise LockError(f"duplicate runtime.env key: {key}")
        values[key] = value
    missing = REQUIRED_ENV_KEYS - values.keys()
    unexpected = values.keys() - REQUIRED_ENV_KEYS
    if missing:
        raise LockError(f"runtime.env is missing: {', '.join(sorted(missing))}")
    if unexpected:
        raise LockError(
            f"runtime.env contains unexpected keys: {', '.join(sorted(unexpected))}"
        )
    return values


def validate_lock(lock: dict[str, Any], env: dict[str, str] | None = None) -> None:
    if lock.get("schemaVersion") != 1:
        raise LockError("schemaVersion must be 1")
    if lock.get("runtime") != EXPECTED_PACKAGE:
        raise LockError(f"runtime must be {EXPECTED_PACKAGE!r}")
    if lock.get("channel") != "qualified-stable":
        raise LockError("channel must be 'qualified-stable'")
    if lock.get("resolvedFrom") != "latest":
        raise LockError("resolvedFrom must be 'latest'")

    package = require_object(lock, "package")
    if require_string(package, "name") != EXPECTED_PACKAGE:
        raise LockError(f"package.name must be {EXPECTED_PACKAGE!r}")
    version = require_string(package, "version")
    if not SEMVER.fullmatch(version):
        raise LockError(f"invalid package version: {version!r}")
    if package.get("registry") != "https://registry.npmjs.org":
        raise LockError("package.registry must use the canonical npm registry")
    expected_tarball = (
        f"https://registry.npmjs.org/{EXPECTED_PACKAGE}/-/"
        f"{EXPECTED_PACKAGE}-{version}.tgz"
    )
    if package.get("tarball") != expected_tarball:
        raise LockError("package.tarball does not match the locked package version")
    integrity = require_string(package, "integrity")
    if not integrity.startswith("sha512-"):
        raise LockError("package.integrity must be an sha512 SRI value")
    try:
        integrity_digest = base64.b64decode(integrity.removeprefix("sha512-"), validate=True)
    except ValueError as exc:
        raise LockError("package.integrity contains invalid base64") from exc
    if len(integrity_digest) != 64:
        raise LockError("package.integrity must contain a 64-byte SHA-512 digest")
    if not HEX_40.fullmatch(require_string(package, "shasum")):
        raise LockError("package.shasum must be a lowercase SHA-1 digest")
    git_head = require_string(package, "gitHead")
    if not HEX_40.fullmatch(git_head):
        raise LockError("package.gitHead must be a lowercase Git commit")
    expected_attestations = (
        f"https://registry.npmjs.org/-/npm/v1/attestations/{EXPECTED_PACKAGE}@{version}"
    )
    if package.get("attestations") != expected_attestations:
        raise LockError("package.attestations does not match the locked package version")

    provenance = require_object(lock, "provenance")
    if provenance.get("repository") != EXPECTED_REPOSITORY:
        raise LockError("provenance.repository is not the approved upstream")
    expected_ref = f"refs/tags/v{version}"
    if provenance.get("ref") != expected_ref:
        raise LockError("provenance.ref does not match the locked version")
    if provenance.get("commit") != git_head:
        raise LockError("provenance.commit must equal package.gitHead")
    if provenance.get("workflow") != EXPECTED_WORKFLOW:
        raise LockError("provenance.workflow is not the approved release workflow")
    if provenance.get("predicateType") != "https://slsa.dev/provenance/v1":
        raise LockError("provenance.predicateType must be SLSA provenance v1")
    workflow_run = require_string(provenance, "workflowRun")
    if not workflow_run.startswith(f"{EXPECTED_REPOSITORY}/actions/runs/"):
        raise LockError("provenance.workflowRun is outside the approved upstream")

    portable = require_object(lock, "portable")
    expected_release = f"{EXPECTED_REPOSITORY}/releases/tag/v{version}"
    if portable.get("release") != expected_release:
        raise LockError("portable.release does not match the locked version")
    assets = require_object(portable, "assets")
    if set(assets) != EXPECTED_PLATFORMS:
        raise LockError(
            "portable.assets must contain exactly "
            + ", ".join(sorted(EXPECTED_PLATFORMS))
        )
    for platform, raw_asset in assets.items():
        if not isinstance(raw_asset, dict):
            raise LockError(f"portable asset {platform} must be an object")
        suffix = platform.removeprefix("darwin-")
        expected_name = f"{EXPECTED_PACKAGE}-{version}-darwin-{suffix}.tar.gz"
        if raw_asset.get("name") != expected_name:
            raise LockError(f"portable asset name drifted for {platform}")
        expected_url = (
            f"{EXPECTED_REPOSITORY}/releases/download/v{version}/{expected_name}"
        )
        if raw_asset.get("url") != expected_url:
            raise LockError(f"portable asset URL drifted for {platform}")
        require_integer(raw_asset, "size")
        if not HEX_64.fullmatch(require_string(raw_asset, "sha256")):
            raise LockError(f"portable asset SHA-256 is invalid for {platform}")

    raw_licenses = portable.get("licenses")
    if not isinstance(raw_licenses, list) or not raw_licenses:
        raise LockError("portable.licenses must be a non-empty array")
    seen_licenses: set[str] = set()
    for raw_license in raw_licenses:
        if not isinstance(raw_license, dict):
            raise LockError("each portable license must be an object")
        name = require_string(raw_license, "name")
        if name in seen_licenses or PurePosixPath(name).name != name:
            raise LockError(f"invalid or duplicate portable license name: {name!r}")
        seen_licenses.add(name)
        expected_url = f"https://raw.githubusercontent.com/getsentry/XcodeBuildMCP/v{version}/{name}"
        if raw_license.get("url") != expected_url:
            raise LockError(f"portable license URL drifted for {name}")
        if not HEX_64.fullmatch(require_string(raw_license, "sha256")):
            raise LockError(f"portable license SHA-256 is invalid for {name}")

    policy = require_object(lock, "runtimePolicy")
    if policy.get("installScripts") != "forbidden":
        raise LockError("runtimePolicy.installScripts must be 'forbidden'")
    if policy.get("ambientRuntimeFallback") != "forbidden":
        raise LockError("runtimePolicy.ambientRuntimeFallback must be 'forbidden'")
    telemetry = require_object(policy, "telemetryEnvironment")
    for key in ("XCODEBUILDMCP_SENTRY_DISABLED", "SENTRY_DISABLED"):
        if telemetry.get(key) != "true":
            raise LockError(f"runtimePolicy.telemetryEnvironment.{key} must be 'true'")
    workflows = policy.get("enabledWorkflows")
    if not isinstance(workflows, list) or not workflows or not all(
        isinstance(item, str) and item for item in workflows
    ):
        raise LockError("runtimePolicy.enabledWorkflows must be a non-empty string array")
    if len(set(workflows)) != len(workflows):
        raise LockError("runtimePolicy.enabledWorkflows contains duplicates")
    if "session-management" not in workflows:
        raise LockError("runtimePolicy.enabledWorkflows must include session-management")
    require_integer(policy, "minimumMcpToolCount")
    required_tools = policy.get("requiredMcpTools")
    if not isinstance(required_tools, list) or not required_tools or not all(
        isinstance(item, str) and item for item in required_tools
    ):
        raise LockError("runtimePolicy.requiredMcpTools must be a non-empty string array")

    if env is not None:
        arm64 = assets["darwin-arm64"]
        x64 = assets["darwin-x64"]
        expected_env = {
            "XCODEBUILDMCP_RUNTIME_VERSION": version,
            "XCODEBUILDMCP_DARWIN_ARM64_SHA256": str(arm64["sha256"]),
            "XCODEBUILDMCP_DARWIN_ARM64_SIZE": str(arm64["size"]),
            "XCODEBUILDMCP_DARWIN_X64_SHA256": str(x64["sha256"]),
            "XCODEBUILDMCP_DARWIN_X64_SIZE": str(x64["size"]),
            "XCODEBUILDMCP_ENABLED_WORKFLOWS": ",".join(workflows),
        }
        for key, expected in expected_env.items():
            if env.get(key) != expected:
                raise LockError(
                    f"runtime.env drifted for {key}: expected {expected!r}, "
                    f"found {env.get(key)!r}"
                )


FetchBytes = Callable[[str], bytes]


def default_fetch_bytes(url: str) -> bytes:
    request = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json, application/json",
            "User-Agent": "apple-appdev-workflow-runtime-lock/1",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.read()
    except (urllib.error.URLError, TimeoutError) as exc:
        raise LockError(f"failed to fetch {url}: {exc}") from exc


def fetch_json(fetch: FetchBytes, url: str) -> dict[str, Any]:
    try:
        value = json.loads(fetch(url))
    except json.JSONDecodeError as exc:
        raise LockError(f"invalid JSON returned by {url}: {exc}") from exc
    if not isinstance(value, dict):
        raise LockError(f"expected a JSON object from {url}")
    return value


def decode_attestation_payload(attestation: dict[str, Any]) -> dict[str, Any]:
    bundle = require_object(attestation, "bundle")
    envelope = require_object(bundle, "dsseEnvelope")
    payload = require_string(envelope, "payload")
    signatures = envelope.get("signatures")
    if not isinstance(signatures, list) or not signatures:
        raise LockError("attestation DSSE envelope has no signatures")
    try:
        decoded = base64.b64decode(payload, validate=True)
        value = json.loads(decoded)
    except (ValueError, json.JSONDecodeError) as exc:
        raise LockError("attestation DSSE payload is invalid") from exc
    if not isinstance(value, dict):
        raise LockError("attestation DSSE payload must be an object")
    return value


def validate_subject(
    payload: dict[str, Any], *, version: str, integrity_hex: str
) -> None:
    subject = payload.get("subject")
    if not isinstance(subject, list) or len(subject) != 1 or not isinstance(subject[0], dict):
        raise LockError("attestation must contain exactly one subject")
    item = subject[0]
    if item.get("name") != f"pkg:npm/{EXPECTED_PACKAGE}@{version}":
        raise LockError("attestation subject does not match the locked package")
    digest = item.get("digest")
    if not isinstance(digest, dict) or digest.get("sha512") != integrity_hex:
        raise LockError("attestation subject digest does not match package.integrity")


def validate_online(
    lock: dict[str, Any], *, fetch: FetchBytes = default_fetch_bytes, require_latest: bool
) -> str:
    package = require_object(lock, "package")
    provenance = require_object(lock, "provenance")
    portable = require_object(lock, "portable")
    version = require_string(package, "version")

    locked_metadata_url = f"https://registry.npmjs.org/{EXPECTED_PACKAGE}/{version}"
    metadata = fetch_json(fetch, locked_metadata_url)
    if metadata.get("name") != EXPECTED_PACKAGE or metadata.get("version") != version:
        raise LockError("npm metadata identity does not match the lock")
    repository = metadata.get("repository")
    repository_url = repository.get("url") if isinstance(repository, dict) else None
    if repository_url not in {
        f"git+{EXPECTED_REPOSITORY}.git",
        f"{EXPECTED_REPOSITORY}.git",
        EXPECTED_REPOSITORY,
    }:
        raise LockError("npm metadata repository is not the approved upstream")
    if metadata.get("gitHead") != package.get("gitHead"):
        raise LockError("npm gitHead does not match the lock")
    dist = metadata.get("dist")
    if not isinstance(dist, dict):
        raise LockError("npm metadata is missing dist")
    for key in ("integrity", "shasum", "tarball"):
        if dist.get(key) != package.get(key):
            raise LockError(f"npm dist.{key} does not match the lock")
    if not isinstance(dist.get("signatures"), list) or not dist["signatures"]:
        raise LockError("npm package has no registry signature")

    latest = fetch_json(fetch, f"https://registry.npmjs.org/{EXPECTED_PACKAGE}/latest")
    latest_version = latest.get("version")
    if not isinstance(latest_version, str):
        raise LockError("npm latest metadata is missing a version")
    if require_latest and latest_version != version:
        raise LockError(
            f"rolling pin is behind npm latest: locked {version}, latest {latest_version}"
        )

    attestations_doc = fetch_json(fetch, require_string(package, "attestations"))
    attestations = attestations_doc.get("attestations")
    if not isinstance(attestations, list):
        raise LockError("npm attestation response is missing attestations")
    integrity = require_string(package, "integrity")
    integrity_hex = base64.b64decode(integrity.removeprefix("sha512-")).hex()
    publish_found = False
    slsa_payload: dict[str, Any] | None = None
    for raw_attestation in attestations:
        if not isinstance(raw_attestation, dict):
            continue
        predicate_type = raw_attestation.get("predicateType")
        if predicate_type == "https://github.com/npm/attestation/tree/main/specs/publish/v0.1":
            payload = decode_attestation_payload(raw_attestation)
            validate_subject(payload, version=version, integrity_hex=integrity_hex)
            publish_found = True
        if predicate_type == provenance.get("predicateType"):
            payload = decode_attestation_payload(raw_attestation)
            validate_subject(payload, version=version, integrity_hex=integrity_hex)
            slsa_payload = payload
    if not publish_found:
        raise LockError("npm publish attestation is missing")
    if slsa_payload is None:
        raise LockError("npm SLSA provenance attestation is missing")

    predicate = require_object(slsa_payload, "predicate")
    build_definition = require_object(predicate, "buildDefinition")
    external = require_object(build_definition, "externalParameters")
    workflow = require_object(external, "workflow")
    if workflow.get("repository") != EXPECTED_REPOSITORY:
        raise LockError("SLSA workflow repository does not match the approved upstream")
    if workflow.get("path") != EXPECTED_WORKFLOW:
        raise LockError("SLSA workflow path does not match the approved release workflow")
    if workflow.get("ref") != provenance.get("ref"):
        raise LockError("SLSA workflow ref does not match the lock")
    resolved = build_definition.get("resolvedDependencies")
    expected_uri = f"git+{EXPECTED_REPOSITORY}@{provenance['ref']}"
    if not isinstance(resolved, list) or not any(
        isinstance(item, dict)
        and item.get("uri") == expected_uri
        and isinstance(item.get("digest"), dict)
        and item["digest"].get("gitCommit") == provenance.get("commit")
        for item in resolved
    ):
        raise LockError("SLSA resolved Git dependency does not match the lock")
    run_details = require_object(predicate, "runDetails")
    metadata_block = require_object(run_details, "metadata")
    if metadata_block.get("invocationId") != provenance.get("workflowRun"):
        raise LockError("SLSA workflow run does not match the lock")

    release_api = (
        "https://api.github.com/repos/getsentry/XcodeBuildMCP/releases/tags/"
        f"v{version}"
    )
    release = fetch_json(fetch, release_api)
    if release.get("tag_name") != f"v{version}" or release.get("html_url") != portable.get("release"):
        raise LockError("GitHub release identity does not match the lock")
    release_assets = release.get("assets")
    if not isinstance(release_assets, list):
        raise LockError("GitHub release response is missing assets")
    by_name = {
        item.get("name"): item
        for item in release_assets
        if isinstance(item, dict) and isinstance(item.get("name"), str)
    }
    assets = require_object(portable, "assets")
    for platform, raw_asset in assets.items():
        assert isinstance(raw_asset, dict)
        live = by_name.get(raw_asset["name"])
        if not isinstance(live, dict):
            raise LockError(f"GitHub release is missing {raw_asset['name']}")
        if live.get("browser_download_url") != raw_asset.get("url"):
            raise LockError(f"GitHub asset URL drifted for {platform}")
        if live.get("size") != raw_asset.get("size"):
            raise LockError(f"GitHub asset size drifted for {platform}")
        if live.get("digest") != f"sha256:{raw_asset.get('sha256')}":
            raise LockError(f"GitHub asset digest drifted for {platform}")

    raw_licenses = portable.get("licenses")
    assert isinstance(raw_licenses, list)
    for raw_license in raw_licenses:
        assert isinstance(raw_license, dict)
        actual = sha256_bytes(fetch(require_string(raw_license, "url")))
        if actual != raw_license.get("sha256"):
            raise LockError(f"license digest drifted for {raw_license.get('name')}")

    return latest_version


def validate_archive(lock: dict[str, Any], platform: str, archive: Path) -> None:
    portable = require_object(lock, "portable")
    assets = require_object(portable, "assets")
    raw_asset = assets.get(platform)
    if not isinstance(raw_asset, dict):
        raise LockError(f"unknown locked platform: {platform}")
    try:
        stat_result = archive.stat()
    except FileNotFoundError as exc:
        raise LockError(f"archive does not exist: {archive}") from exc
    if stat_result.st_size != raw_asset.get("size"):
        raise LockError(
            f"archive size mismatch for {platform}: expected {raw_asset.get('size')}, "
            f"found {stat_result.st_size}"
        )
    digest = hashlib.sha256()
    with archive.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    if digest.hexdigest() != raw_asset.get("sha256"):
        raise LockError(f"archive SHA-256 mismatch for {platform}")

    version = require_string(require_object(lock, "package"), "version")
    expected_root = f"{EXPECTED_PACKAGE}-{version}-{platform}"
    required_members = {
        f"{expected_root}/bin/xcodebuildmcp",
        f"{expected_root}/bin/xcodebuildmcp-doctor",
        f"{expected_root}/libexec/node-runtime",
        f"{expected_root}/libexec/_resolve-resource-root.sh",
        f"{expected_root}/libexec/package.json",
    }
    found: set[str] = set()
    try:
        with tarfile.open(archive, mode="r:gz") as tar:
            for member in tar.getmembers():
                path = PurePosixPath(member.name)
                if path.is_absolute() or ".." in path.parts:
                    raise LockError(f"archive contains unsafe member: {member.name!r}")
                if not path.parts or path.parts[0] != expected_root:
                    raise LockError(
                        f"archive member escapes expected root {expected_root!r}: {member.name!r}"
                    )
                if member.issym() or member.islnk():
                    target = PurePosixPath(member.linkname)
                    if target.is_absolute():
                        raise LockError(
                            f"archive contains unsafe link target: {member.name!r} -> "
                            f"{member.linkname!r}"
                        )
                    if member.islnk() and target.parts[:1] == (expected_root,):
                        combined = target
                    else:
                        combined = path.parent / target
                    normalized: list[str] = []
                    for part in combined.parts:
                        if part in {"", "."}:
                            continue
                        if part == "..":
                            if not normalized:
                                raise LockError(
                                    f"archive contains unsafe link target: {member.name!r} -> "
                                    f"{member.linkname!r}"
                                )
                            normalized.pop()
                        else:
                            normalized.append(part)
                    if not normalized or normalized[0] != expected_root:
                        raise LockError(
                            f"archive contains unsafe link target: {member.name!r} -> "
                            f"{member.linkname!r}"
                        )
                found.add(member.name.rstrip("/"))
    except (tarfile.TarError, OSError) as exc:
        raise LockError(f"could not inspect archive {archive}: {exc}") from exc
    missing = required_members - found
    if missing:
        raise LockError(
            "archive is missing required runtime members: " + ", ".join(sorted(missing))
        )


def audit_npm_signatures(lock: dict[str, Any], npm: str) -> None:
    package = require_object(lock, "package")
    version = require_string(package, "version")
    with tempfile.TemporaryDirectory(prefix="xcodebuildmcp-signature-audit-") as temp_dir:
        root = Path(temp_dir)
        (root / "package.json").write_text(
            json.dumps({"private": True, "dependencies": {EXPECTED_PACKAGE: version}}) + "\n"
        )
        install = subprocess.run(
            [
                npm,
                "install",
                "--ignore-scripts",
                "--no-audit",
                "--no-fund",
            ],
            cwd=root,
            text=True,
            capture_output=True,
            check=False,
        )
        if install.returncode != 0:
            raise LockError(f"npm isolated install failed:\n{install.stdout}{install.stderr}")
        lockfile = load_json(root / "package-lock.json")
        package_entry = require_object(lockfile, "packages").get(
            f"node_modules/{EXPECTED_PACKAGE}"
        )
        if not isinstance(package_entry, dict):
            raise LockError("npm lockfile omitted the XcodeBuildMCP package entry")
        if package_entry.get("version") != version:
            raise LockError("npm lockfile resolved a different XcodeBuildMCP version")
        if package_entry.get("integrity") != package.get("integrity"):
            raise LockError("npm lockfile integrity does not match runtime-lock.json")
        audit = subprocess.run(
            [npm, "audit", "signatures"],
            cwd=root,
            text=True,
            capture_output=True,
            check=False,
        )
        if audit.returncode != 0:
            raise LockError(f"npm signature audit failed:\n{audit.stdout}{audit.stderr}")


def probe_mcp_runtime(
    lock: dict[str, Any], launcher: Path, *, timeout_seconds: float = 15.0
) -> int:
    if not launcher.is_file() or not os.access(launcher, os.X_OK):
        raise LockError(f"runtime launcher is not executable: {launcher}")
    package = require_object(lock, "package")
    policy = require_object(lock, "runtimePolicy")
    expected_version = require_string(package, "version")
    minimum_tool_count = require_integer(policy, "minimumMcpToolCount")
    required_tools = policy.get("requiredMcpTools")
    assert isinstance(required_tools, list)

    env = os.environ.copy()
    env["PATH"] = "/usr/bin:/bin:/usr/sbin:/sbin"
    env["XCODEBUILDMCP_SENTRY_DISABLED"] = "true"
    env["SENTRY_DISABLED"] = "true"
    proc = subprocess.Popen(
        [str(launcher), "mcp"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env=env,
    )

    def send(message: dict[str, Any]) -> None:
        if proc.stdin is None:
            raise LockError("runtime probe stdin is unavailable")
        proc.stdin.write(json.dumps(message) + "\n")
        proc.stdin.flush()

    def receive(request_id: int) -> dict[str, Any]:
        if proc.stdout is None:
            raise LockError("runtime probe stdout is unavailable")
        selector = selectors.DefaultSelector()
        selector.register(proc.stdout, selectors.EVENT_READ)
        deadline = time.monotonic() + timeout_seconds
        try:
            while True:
                remaining = deadline - time.monotonic()
                if remaining <= 0 or not selector.select(remaining):
                    raise LockError(
                        f"timed out waiting for XcodeBuildMCP JSON-RPC response {request_id}"
                    )
                line = proc.stdout.readline()
                if not line:
                    raise LockError("XcodeBuildMCP closed stdout during runtime probe")
                try:
                    message = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if isinstance(message, dict) and message.get("id") == request_id:
                    return message
        finally:
            selector.close()

    try:
        send(
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": "2025-06-18",
                    "capabilities": {},
                    "clientInfo": {
                        "name": "apple-appdev-runtime-qualification",
                        "version": "1",
                    },
                },
            }
        )
        initialized = receive(1)
        if "error" in initialized:
            raise LockError(f"XcodeBuildMCP initialize failed: {initialized['error']!r}")
        result = initialized.get("result")
        server_info = result.get("serverInfo") if isinstance(result, dict) else None
        if not isinstance(server_info, dict) or server_info.get("name") != EXPECTED_PACKAGE:
            raise LockError("runtime probe returned the wrong MCP server identity")
        if server_info.get("version") != expected_version:
            raise LockError(
                f"runtime probe version drifted: expected {expected_version}, "
                f"found {server_info.get('version')!r}"
            )
        send({"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}})
        send({"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}})
        tools_response = receive(2)
        if "error" in tools_response:
            raise LockError(f"XcodeBuildMCP tools/list failed: {tools_response['error']!r}")
        tools_result = tools_response.get("result")
        raw_tools = tools_result.get("tools") if isinstance(tools_result, dict) else None
        if not isinstance(raw_tools, list):
            raise LockError("runtime probe tools/list omitted tools")
        names = {
            item.get("name")
            for item in raw_tools
            if isinstance(item, dict) and isinstance(item.get("name"), str)
        }
        if len(names) < minimum_tool_count:
            raise LockError(
                f"runtime probe exposed {len(names)} tools; expected at least {minimum_tool_count}"
            )
        missing = set(required_tools) - names
        if missing:
            raise LockError(
                "runtime probe omitted required tools: " + ", ".join(sorted(missing))
            )
        return len(names)
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=3)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait(timeout=3)
        for pipe in (proc.stdin, proc.stdout, proc.stderr):
            if pipe is not None:
                pipe.close()


def parse_archive_argument(value: str) -> tuple[str, Path]:
    if "=" not in value:
        raise argparse.ArgumentTypeError("archive must use PLATFORM=PATH")
    platform, raw_path = value.split("=", 1)
    if not platform or not raw_path:
        raise argparse.ArgumentTypeError("archive must use PLATFORM=PATH")
    return platform, Path(raw_path)


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Validate the promoted XcodeBuildMCP runtime lock offline and, "
            "optionally, against npm/Sigstore claims and GitHub release assets."
        )
    )
    parser.add_argument("--lock", type=Path, default=DEFAULT_LOCK)
    parser.add_argument("--runtime-env", type=Path, default=DEFAULT_ENV)
    parser.add_argument("--online", action="store_true")
    parser.add_argument(
        "--require-latest",
        action="store_true",
        help="Fail when npm latest has advanced beyond the promoted lock.",
    )
    parser.add_argument(
        "--npm-audit-signatures",
        action="store_true",
        help="Run npm's cryptographic registry-signature audit with install scripts disabled.",
    )
    parser.add_argument("--npm", default="npm", help="npm executable for signature audit.")
    parser.add_argument(
        "--probe-launcher",
        type=Path,
        help="Start the promoted launcher and require the locked MCP identity/tool surface.",
    )
    parser.add_argument(
        "--archive",
        action="append",
        default=[],
        type=parse_archive_argument,
        metavar="PLATFORM=PATH",
        help="Verify a downloaded portable archive against the lock; repeatable.",
    )
    args = parser.parse_args()

    if args.require_latest and not args.online:
        parser.error("--require-latest requires --online")
    if args.npm_audit_signatures and not args.online:
        parser.error("--npm-audit-signatures requires --online")

    try:
        lock = load_json(args.lock)
        env = parse_env(args.runtime_env)
        validate_lock(lock, env)
        latest_version = None
        if args.online:
            latest_version = validate_online(
                lock,
                require_latest=args.require_latest,
            )
        for platform, archive in args.archive:
            validate_archive(lock, platform, archive)
        if args.npm_audit_signatures:
            audit_npm_signatures(lock, args.npm)
        probed_tool_count = None
        if args.probe_launcher is not None:
            probed_tool_count = probe_mcp_runtime(lock, args.probe_launcher)
    except LockError as exc:
        print(f"XcodeBuildMCP runtime lock check failed: {exc}", file=sys.stderr)
        return 1

    package = require_object(lock, "package")
    print("XcodeBuildMCP runtime lock check passed.")
    print(f"  locked version: {package['version']}")
    if latest_version is not None:
        print(f"  npm latest: {latest_version}")
        print("  npm provenance: verified")
        print("  GitHub portable assets: verified")
    if args.npm_audit_signatures:
        print("  npm registry signatures: audited")
    if probed_tool_count is not None:
        print(f"  MCP runtime tools: {probed_tool_count}")
    for platform, archive in args.archive:
        print(f"  archive {platform}: {archive.resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
