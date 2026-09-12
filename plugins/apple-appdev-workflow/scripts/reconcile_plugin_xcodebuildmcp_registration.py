#!/usr/bin/env python3
from __future__ import annotations

import argparse
import copy
import os
import re
import shutil
import stat
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - stock macOS Python is 3.9.
    tomllib = None  # type: ignore[assignment]


LEGACY_SERVER_NAMES = {"XcodeBuildMCP", "apple-appdev-xcodebuildmcp"}
TABLE_HEADER = re.compile(r"^\s*\[(?P<table>[^\]]+)]\s*(?:#.*)?$")


class ReconcileError(RuntimeError):
    pass


def split_dotted_table(value: str) -> list[str]:
    components: list[str] = []
    current: list[str] = []
    quote: str | None = None
    escaped = False
    for character in value.strip():
        if quote is not None:
            if escaped:
                current.append(character)
                escaped = False
            elif character == "\\" and quote == '"':
                current.append(character)
                escaped = True
            elif character == quote:
                quote = None
                current.append(character)
            else:
                current.append(character)
            continue
        if character in {'"', "'"}:
            quote = character
            current.append(character)
        elif character == ".":
            components.append("".join(current).strip())
            current = []
        else:
            current.append(character)
    if quote is not None:
        raise ReconcileError(f"unterminated quoted TOML table: [{value}]")
    components.append("".join(current).strip())
    return components


def unquote_component(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] == '"':
        import json

        try:
            decoded = json.loads(value)
        except ValueError as exc:
            raise ReconcileError(f"invalid quoted TOML key: {value}") from exc
        if not isinstance(decoded, str):
            raise ReconcileError(f"invalid quoted TOML key: {value}")
        return decoded
    if len(value) >= 2 and value[0] == value[-1] == "'":
        return value[1:-1]
    return value


def target_table(header_value: str) -> bool:
    components = [unquote_component(item) for item in split_dotted_table(header_value)]
    return (
        len(components) >= 2
        and components[0] == "mcp_servers"
        and components[1] in LEGACY_SERVER_NAMES
    )


def reconcile_text(text: str) -> tuple[str, set[str]]:
    lines = text.splitlines(keepends=True)
    output: list[str] = []
    removed_names: set[str] = set()
    skip = False
    for line in lines:
        match = TABLE_HEADER.match(line.rstrip("\r\n"))
        if match:
            components = [
                unquote_component(item)
                for item in split_dotted_table(match.group("table"))
            ]
            skip = target_table(match.group("table"))
            if skip:
                removed_names.add(components[1])
                while output and not output[-1].strip():
                    output.pop()
                continue
        if not skip:
            output.append(line)

    while output and not output[-1].strip():
        output.pop()
    if output and not output[-1].endswith(("\n", "\r")):
        output[-1] += "\n"
    return "".join(output), removed_names


def parse_toml(text: str, *, label: str) -> dict[str, object]:
    if tomllib is None:
        raise ReconcileError("tomllib is unavailable")
    try:
        value = tomllib.loads(text)
    except tomllib.TOMLDecodeError as exc:
        raise ReconcileError(f"invalid TOML in {label}: {exc}") from exc
    if not isinstance(value, dict):
        raise ReconcileError(f"expected a TOML document in {label}")
    return value


def without_targets(config: dict[str, object]) -> dict[str, object]:
    normalized = copy.deepcopy(config)
    servers = normalized.get("mcp_servers")
    if isinstance(servers, dict):
        for name in LEGACY_SERVER_NAMES:
            servers.pop(name, None)
        if not servers:
            normalized.pop("mcp_servers", None)
    return normalized


def verify_reconciliation(before: str, after: str, *, label: str) -> None:
    expected, _ = reconcile_text(before)
    if after != expected:
        raise ReconcileError(
            "reconciliation output differs from the canonical target-table removal"
        )
    if any(
        match and target_table(match.group("table"))
        for line in after.splitlines()
        for match in [TABLE_HEADER.match(line)]
    ):
        raise ReconcileError("reconciliation left a shadowing XcodeBuildMCP table")
    if tomllib is None:
        return
    before_config = parse_toml(before, label=label)
    after_config = parse_toml(after, label=f"reconciled {label}")
    if without_targets(before_config) != after_config:
        raise ReconcileError(
            "reconciliation changed configuration outside the legacy XcodeBuildMCP tables"
        )
    servers = after_config.get("mcp_servers")
    if isinstance(servers, dict) and LEGACY_SERVER_NAMES & servers.keys():
        raise ReconcileError("reconciliation left a shadowing XcodeBuildMCP table")


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def atomic_write(path: Path, contents: str, mode: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    temp_path = Path(temp_name)
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(contents)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temp_path, stat.S_IMODE(mode))
        os.replace(temp_path, path)
    finally:
        if temp_path.exists():
            temp_path.unlink()


def reconcile_file(
    config_path: Path,
    *,
    apply: bool,
    backup_root: Path | None = None,
) -> tuple[set[str], Path | None]:
    if not config_path.exists():
        return set(), None
    before = config_path.read_text()
    after, removed = reconcile_text(before)
    verify_reconciliation(before, after, label=str(config_path))
    if not removed or not apply:
        return removed, None

    resolved_backup_root = backup_root or (
        config_path.parent / ".tmp" / "plugin-runtime-backups"
    )
    resolved_backup_root.mkdir(parents=True, exist_ok=True)
    backup = resolved_backup_root / (
        f"{config_path.name}.before-plugin-xcodebuildmcp-{timestamp()}"
    )
    suffix = 1
    while backup.exists():
        backup = resolved_backup_root / (
            f"{config_path.name}.before-plugin-xcodebuildmcp-{timestamp()}-{suffix}"
        )
        suffix += 1
    shutil.copy2(config_path, backup)
    atomic_write(config_path, after, config_path.stat().st_mode)
    verify_reconciliation(before, config_path.read_text(), label=str(config_path))
    return removed, backup


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Detect or transactionally remove only global XcodeBuildMCP registrations "
            "that can shadow the plugin-owned MCP server."
        )
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex")))
        / "config.toml",
    )
    parser.add_argument("--backup-root", type=Path)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--apply", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()

    try:
        removed, backup = reconcile_file(
            args.config.expanduser(),
            apply=args.apply,
            backup_root=args.backup_root.expanduser() if args.backup_root else None,
        )
    except (OSError, ReconcileError) as exc:
        print(f"XcodeBuildMCP registration reconciliation failed: {exc}", file=sys.stderr)
        return 1

    if not removed:
        print(f"No shadowing global XcodeBuildMCP registration found in {args.config}.")
        return 0
    names = ", ".join(sorted(removed))
    if args.apply:
        print(f"Removed shadowing global XcodeBuildMCP registration(s): {names}")
        print(f"Configuration backup: {backup}")
        return 0
    print(f"Shadowing global XcodeBuildMCP registration(s) found: {names}", file=sys.stderr)
    print("Run again with --apply after reviewing the target config.", file=sys.stderr)
    return 1 if args.check else 0


if __name__ == "__main__":
    raise SystemExit(main())
