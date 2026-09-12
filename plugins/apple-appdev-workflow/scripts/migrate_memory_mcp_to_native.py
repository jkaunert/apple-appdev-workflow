#!/usr/bin/env python3
"""Back up a legacy Memory MCP graph and stage it for Codex native memory.

The raw JSONL graph remains the lossless rollback source. Codex does not expose
a graph-import API, so native migration is represented as one ad-hoc memory
note containing the graph's entities, observations, and relations. The script
never edits config.toml, disables an MCP server, or mutates the source graph.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import stat
import tempfile
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


STAMP_RE = re.compile(r"^[0-9]{8}T[0-9]{6}Z$")
SECRET_PATTERNS = (
    re.compile(
        r"(?i)\b(?:api|access|auth)[_-]?(?:key|token)\s*[:=]\s*[^\s,;]+"
    ),
    re.compile(r"(?i)\bpassword\s*[:=]\s*[^\s,;]+"),
    re.compile(r"sk-[A-Za-z0-9_-]{12,}"),
    re.compile(
        r"-----BEGIN [A-Z ]*PRIVATE KEY-----.*?-----END [A-Z ]*PRIVATE KEY-----",
        re.DOTALL,
    ),
)


class MigrationError(RuntimeError):
    pass


@dataclass(frozen=True)
class Graph:
    entities: list[dict[str, object]]
    relations: list[dict[str, object]]

    @property
    def observation_count(self) -> int:
        return sum(len(entity["observations"]) for entity in self.entities)  # type: ignore[arg-type]


@dataclass(frozen=True)
class MigrationResult:
    backup_dir: Path
    note_path: Path | None
    raw_sha256: str
    normalized_sha256: str
    entity_count: int
    observation_count: int
    relation_count: int
    redaction_count: int


def utc_stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def sha256_bytes(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def ensure_owned_regular_file(path: Path, *, required: bool = True) -> bool:
    try:
        metadata = path.lstat()
    except FileNotFoundError:
        if required:
            raise MigrationError(f"Missing required file: {path}")
        return False
    if stat.S_ISLNK(metadata.st_mode) or not stat.S_ISREG(metadata.st_mode):
        raise MigrationError(f"Expected a regular non-symlink file: {path}")
    if hasattr(os, "getuid") and metadata.st_uid != os.getuid():
        raise MigrationError(f"Refusing file not owned by the current user: {path}")
    return True


def load_graph(source: Path) -> tuple[Graph, bytes]:
    ensure_owned_regular_file(source)
    payload = source.read_bytes()
    entities: list[dict[str, object]] = []
    relations: list[dict[str, object]] = []
    for line_number, raw_line in enumerate(payload.splitlines(), start=1):
        if not raw_line.strip():
            continue
        try:
            record = json.loads(raw_line)
        except json.JSONDecodeError as exc:
            raise MigrationError(f"Invalid JSONL record at {source}:{line_number}: {exc}") from exc
        if not isinstance(record, dict):
            raise MigrationError(f"Graph record must be an object at {source}:{line_number}")
        record_type = record.get("type")
        if record_type == "entity":
            name = record.get("name")
            entity_type = record.get("entityType")
            observations = record.get("observations")
            if (
                not isinstance(name, str)
                or not name
                or not isinstance(entity_type, str)
                or not entity_type
                or not isinstance(observations, list)
                or not all(isinstance(value, str) for value in observations)
            ):
                raise MigrationError(f"Invalid entity record at {source}:{line_number}")
            entities.append(
                {
                    "name": name,
                    "entityType": entity_type,
                    "observations": observations,
                }
            )
        elif record_type == "relation":
            relation = {
                "from": record.get("from"),
                "relationType": record.get("relationType"),
                "to": record.get("to"),
            }
            if not all(isinstance(value, str) and value for value in relation.values()):
                raise MigrationError(f"Invalid relation record at {source}:{line_number}")
            relations.append(relation)
        else:
            raise MigrationError(
                f"Unsupported graph record type {record_type!r} at {source}:{line_number}"
            )
    if not entities:
        raise MigrationError(f"Memory graph contains no entities: {source}")
    return Graph(entities=entities, relations=relations), payload


def redact_for_native_note(value: str) -> tuple[str, int]:
    redacted = value.replace("\r\n", " ").replace("\r", " ").replace("\n", " ")
    count = 0
    for pattern in SECRET_PATTERNS:
        redacted, replacements = pattern.subn("[REDACTED]", redacted)
        count += replacements
    return redacted, count


def render_note(
    graph: Graph,
    *,
    stamp: str,
    source: Path,
    raw_sha256: str,
    raw_backup: Path,
) -> tuple[str, int]:
    lines = [
        "# MCP memory graph migration",
        "",
        f"- Snapshot: {stamp}",
        f"- Source: {source}",
        f"- Raw SHA-256: {raw_sha256}",
        f"- Exact backup: {raw_backup}",
        (
            f"- Coverage: {len(graph.entities)} entities, "
            f"{graph.observation_count} observations, {len(graph.relations)} relations."
        ),
        (
            "- Interpretation: semantic migration input from the former MCP knowledge "
            "graph. Version, path, branch, and release-state observations can be "
            "historical and should be reverified before current-state decisions."
        ),
        "",
    ]
    redaction_count = 0
    for entity in graph.entities:
        lines.extend((f"## {entity['name']}", "", f"Type: {entity['entityType']}", ""))
        for observation in entity["observations"]:  # type: ignore[union-attr]
            redacted, replacements = redact_for_native_note(observation)
            redaction_count += replacements
            lines.append(f"- {redacted}")
        lines.append("")
    lines.extend(("## Relations", ""))
    for relation in graph.relations:
        lines.append(
            f"- {relation['from']} --{relation['relationType']}--> {relation['to']}"
        )
    lines.append("")
    return "\n".join(lines), redaction_count


def write_private(path: Path, payload: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(payload)
            handle.flush()
            os.fsync(handle.fileno())
        temporary.chmod(0o600)
        if path.exists() or path.is_symlink():
            raise MigrationError(f"Refusing to overwrite existing migration artifact: {path}")
        temporary.replace(path)
    finally:
        if temporary.exists():
            temporary.unlink()


def migrate(
    *,
    codex_home: Path,
    source: Path,
    backup_root: Path,
    stamp: str,
    backup_only: bool = False,
    dry_run: bool = False,
) -> MigrationResult:
    if not STAMP_RE.fullmatch(stamp):
        raise MigrationError(f"Timestamp must use YYYYMMDDTHHMMSSZ: {stamp!r}")
    codex_home = codex_home.expanduser().resolve()
    source = Path(os.path.abspath(source.expanduser()))
    backup_root = backup_root.expanduser().resolve()
    graph, raw_payload = load_graph(source)
    raw_sha256 = sha256_bytes(raw_payload)
    normalized_payload = (
        json.dumps(
            {
                "schema": "modelcontextprotocol-server-memory-export-v1",
                "entities": graph.entities,
                "relations": graph.relations,
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n"
    ).encode()
    normalized_sha256 = sha256_bytes(normalized_payload)
    backup_dir = backup_root / stamp
    raw_backup = backup_dir / "memory.raw.jsonl"
    note_path = None
    note_payload = b""
    redaction_count = 0
    if not backup_only:
        note_path = (
            codex_home
            / "memories"
            / "extensions"
            / "ad_hoc"
            / "notes"
            / f"{stamp}-mcp-memory-graph-migration.md"
        )
        note_text, redaction_count = render_note(
            graph,
            stamp=stamp,
            source=source,
            raw_sha256=raw_sha256,
            raw_backup=raw_backup,
        )
        note_payload = note_text.encode()

    result = MigrationResult(
        backup_dir=backup_dir,
        note_path=note_path,
        raw_sha256=raw_sha256,
        normalized_sha256=normalized_sha256,
        entity_count=len(graph.entities),
        observation_count=graph.observation_count,
        relation_count=len(graph.relations),
        redaction_count=redaction_count,
    )
    if dry_run:
        return result
    if backup_dir.exists() or backup_dir.is_symlink():
        raise MigrationError(f"Refusing to overwrite existing backup: {backup_dir}")
    backup_dir.mkdir(parents=True, mode=0o700)
    backup_dir.chmod(0o700)
    write_private(raw_backup, raw_payload)
    write_private(backup_dir / "memory.normalized.json", normalized_payload)
    config_source = codex_home / "config.toml"
    copied_files = [raw_backup, backup_dir / "memory.normalized.json"]
    if ensure_owned_regular_file(config_source, required=False):
        config_backup = backup_dir / "config.toml"
        shutil.copy2(config_source, config_backup)
        config_backup.chmod(0o600)
        copied_files.append(config_backup)
    manifest = {
        "schema": 1,
        "timestamp": stamp,
        "source": str(source),
        "source_sha256": raw_sha256,
        "normalized_sha256": normalized_sha256,
        "counts": {
            "entities": len(graph.entities),
            "observations": graph.observation_count,
            "relations": len(graph.relations),
        },
        "native_note": str(note_path) if note_path is not None else None,
        "native_note_redactions": redaction_count,
        "restore": {
            "source": str(raw_backup),
            "target": str(source),
            "policy": "stop the Memory MCP first, verify the target path, then restore explicitly",
        },
    }
    manifest_path = backup_dir / "manifest.json"
    write_private(
        manifest_path,
        (json.dumps(manifest, indent=2, ensure_ascii=False) + "\n").encode(),
    )
    copied_files.append(manifest_path)
    checksum_lines = [
        f"{sha256_bytes(path.read_bytes())}  {path.name}" for path in copied_files
    ]
    write_private(
        backup_dir / "SHA256SUMS",
        ("\n".join(checksum_lines) + "\n").encode(),
    )
    if note_path is not None:
        write_private(note_path, note_payload)
    return result


def default_codex_home() -> Path:
    return Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex")))


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Back up a legacy Memory MCP JSONL graph and stage a semantic "
            "migration note for Codex native memory."
        )
    )
    parser.add_argument("--codex-home", type=Path, default=default_codex_home())
    parser.add_argument("--source", type=Path)
    parser.add_argument("--backup-root", type=Path)
    parser.add_argument("--timestamp", default=utc_stamp())
    parser.add_argument("--backup-only", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    codex_home = args.codex_home.expanduser().resolve()
    source = args.source or codex_home / "memory.json"
    backup_root = args.backup_root or (
        Path.home()
        / "Library"
        / "Application Support"
        / "Apple AppDev Workflow"
        / "backups"
        / "memory-migration"
    )
    try:
        result = migrate(
            codex_home=codex_home,
            source=source,
            backup_root=backup_root,
            stamp=args.timestamp,
            backup_only=args.backup_only,
            dry_run=args.dry_run,
        )
    except (MigrationError, OSError) as exc:
        print(f"Memory migration failed: {exc}", file=os.sys.stderr)
        return 1

    print("Memory migration plan verified." if args.dry_run else "Memory migration staged.")
    print(f"  backup: {result.backup_dir}")
    print(f"  raw SHA-256: {result.raw_sha256}")
    print(f"  normalized SHA-256: {result.normalized_sha256}")
    print(
        "  graph: "
        f"{result.entity_count} entities, {result.observation_count} observations, "
        f"{result.relation_count} relations"
    )
    if result.note_path is not None:
        print(f"  native note: {result.note_path}")
        print(f"  note redactions: {result.redaction_count}")
    print("  source graph and MCP registration were not changed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
