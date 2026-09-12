#!/usr/bin/python3
"""Dependency-free hook runtime for Apple AppDev Workflow.

The Marketplace hook contract runs before MCP servers are available, so it
cannot depend on Node, npm, Malt, Homebrew, or Codex's optional Node REPL.  This
module mirrors the qualified JavaScript router and Stop guard using only the
Python 3 runtime supplied with the supported Xcode/macOS developer host.
"""

from __future__ import annotations

import datetime
import json
import os
import re
import sys
import time
import unicodedata
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple


MODULE_ROOT = Path(__file__).resolve().parent.parent
PLUGIN_PREFIX = "apple-appdev-workflow:"
TOP_LEVEL_OWNER = f"{PLUGIN_PREFIX}apple-app-orchestrator"
SKILL_ID = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
QUALIFIED_SKILL_ID = re.compile(
    r"^([a-z0-9]+(?:-[a-z0-9]+)*):([a-z0-9]+(?:-[a-z0-9]+)*)$"
)
STATE_COMPONENT = re.compile(r"^[A-Za-z0-9._-]{1,128}$")
STATE_MAX_AGE_SECONDS = 7 * 24 * 60 * 60
QUALIFIED_SKILL_RE = re.compile(
    r"\$?apple-appdev-workflow:[a-z0-9]+(?:-[a-z0-9]+)*"
)
APPLE_SKILL_RE = re.compile(r"\$?apple-[a-z0-9]+(?:-[a-z0-9]+)*")
APPLE_SKILL_PATH_RE = re.compile(
    r"apple-appdev-workflow(?:-integration)?"
    r"(?:[/\\][^/\\\s\"'`]+)*[/\\]skills[/\\]"
    r"([a-z0-9]+(?:-[a-z0-9]+)*)[/\\]SKILL\.md\b"
)

LANE_CONTRACTS: Sequence[Tuple[str, Sequence[str]]] = (
    (
        f"{PLUGIN_PREFIX}apple-architecture-orchestrator",
        (
            "Routing",
            "Activated skills",
            "Assessment scope",
            "Discovery findings",
            "What Should Change First",
            "Recommended follow-on structure",
            "Risks",
            "Next implementation entry points",
        ),
    ),
    (
        f"{PLUGIN_PREFIX}apple-bootstrap-orchestrator",
        (
            "Routing",
            "Activated skills",
            "Bootstrap scope",
            "Discovery findings",
            "Mode",
            "Inputs confirmed",
            "Preflight status",
            "Actions taken",
            "Files created or assessed",
            "Git and branch handoff",
            "Validation handoff",
            "Recommendation",
        ),
    ),
    (
        f"{PLUGIN_PREFIX}apple-review-orchestrator",
        (
            "Routing",
            "Activated skills",
            "Review scope",
            "Discovery findings",
            "Overall assessment",
            "Findings",
            "Test coverage assessment",
            "Residual risks",
            "Recommendation",
        ),
    ),
    (
        f"{PLUGIN_PREFIX}apple-debug-orchestrator",
        (
            "Routing",
            "Activated skills",
            "Debug scope",
            "Reproduction status",
            "Discovery findings",
            "Evidence reviewed",
            "Likely root cause",
            "Validation gaps",
            "Next diagnostic step",
            "Recommended fix path",
            "Residual risks",
        ),
    ),
    (
        f"{PLUGIN_PREFIX}apple-product-surface-orchestrator",
        (
            "Routing",
            "Activated skills",
            "Surface scope",
            "Discovery findings",
            "Surface assessment",
            "Coordinated recommendations",
            "Validation and rollout notes",
            "Direct follow-on lanes",
        ),
    ),
    (
        f"{PLUGIN_PREFIX}apple-persistence-orchestrator",
        (
            "Routing",
            "Activated skills",
            "Persistence scope",
            "Discovery findings",
            "Persistence assessment",
            "Coordinated recommendations",
            "Migration and rollout notes",
            "Direct follow-on lanes",
        ),
    ),
    (
        f"{PLUGIN_PREFIX}apple-release-orchestrator",
        (
            "Routing",
            "Activated skills",
            "Release scope",
            "Overall status",
            "Evidence reviewed",
            "Manual-validation status",
            "Release-ops status",
            "Blockers",
            "Residual risks",
            "Recommendation",
        ),
    ),
    (
        f"{PLUGIN_PREFIX}apple-accessibility-orchestrator",
        (
            "Routing",
            "Activated skills",
            "Accessibility scope",
            "Framework targets",
            "Overall assessment",
            "Required implementation constraints",
            "Validation checklist",
            "Manual checks",
        ),
    ),
)


class RouterContractError(RuntimeError):
    pass


def unique(values: Iterable[str]) -> List[str]:
    return list(dict.fromkeys(values))


def route_state_root() -> Path:
    override = os.environ.get("APPLE_APPDEV_ROUTE_STATE_ROOT")
    if override:
        return Path(override).expanduser().resolve()
    codex_home = os.environ.get("CODEX_HOME")
    root = Path(codex_home).expanduser().resolve() if codex_home else Path.home() / ".codex"
    return root / "tmp" / "apple-appdev-workflow" / "route-state"


def safe_state_component(value: Any) -> Optional[str]:
    if (
        isinstance(value, str)
        and value not in {".", ".."}
        and STATE_COMPONENT.fullmatch(value)
    ):
        return value
    return None


def route_state_path(input_payload: Dict[str, Any]) -> Optional[Path]:
    session_id = safe_state_component(input_payload.get("session_id"))
    turn_id = safe_state_component(input_payload.get("turn_id"))
    if not session_id or not turn_id:
        return None
    return route_state_root() / session_id / f"{turn_id}.json"


def read_route_state(input_payload: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    state_path = route_state_path(input_payload)
    if state_path is None:
        return None
    try:
        state = json.loads(state_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    return state if isinstance(state, dict) else None


def delete_route_state(input_payload: Dict[str, Any]) -> None:
    state_path = route_state_path(input_payload)
    if state_path is None:
        return
    try:
        state_path.unlink()
    except FileNotFoundError:
        pass


def prune_route_state(root: Path) -> None:
    cutoff = time.time() - STATE_MAX_AGE_SECONDS
    try:
        session_entries = list(root.iterdir())
    except OSError:
        return
    for session_root in session_entries:
        if not session_root.is_dir() or not STATE_COMPONENT.fullmatch(session_root.name):
            continue
        try:
            state_entries = list(session_root.iterdir())
        except OSError:
            continue
        for state_path in state_entries:
            if not state_path.is_file() or state_path.suffix != ".json":
                continue
            try:
                if state_path.stat().st_mtime < cutoff:
                    state_path.unlink()
            except OSError:
                pass
        try:
            session_root.rmdir()
        except OSError:
            pass


def write_route_state(
    input_payload: Dict[str, Any], decision: Dict[str, Any], harness: Dict[str, Any]
) -> Dict[str, Any]:
    state_path = route_state_path(input_payload)
    if state_path is None:
        raise RouterContractError(
            "routed hook input requires safe session_id and turn_id values"
        )
    transcript_offset: Optional[int] = None
    transcript_path = input_payload.get("transcript_path")
    if isinstance(transcript_path, str) and transcript_path:
        try:
            transcript_offset = Path(transcript_path).stat().st_size
        except OSError:
            transcript_offset = None
    state = {
        "schemaVersion": 1,
        "sessionId": input_payload.get("session_id"),
        "turnId": input_payload.get("turn_id"),
        "transcriptPath": transcript_path if isinstance(transcript_path, str) else None,
        "transcriptOffset": transcript_offset,
        "routing": decision["routing"],
        "owner": decision["owner"],
        "topLevelOwner": harness["owner"]["qualified"],
        "activatedSkills": decision["activatedSkills"],
        "enforceFinalContract": decision["owner"] == harness["owner"]["qualified"],
        "createdAt": datetime.datetime.now(datetime.timezone.utc).isoformat().replace(
            "+00:00", "Z"
        ),
    }
    state_path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    temporary_path = state_path.with_name(
        f"{state_path.name}.{os.getpid()}.{time.time_ns()}.tmp"
    )
    descriptor = os.open(temporary_path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(state, handle, separators=(",", ":"))
            handle.write("\n")
    except BaseException:
        try:
            temporary_path.unlink()
        except OSError:
            pass
        raise
    temporary_path.replace(state_path)
    prune_route_state(route_state_root())
    return state


def resolve_existing_inside(root: Path, relative_path: Any, label: str) -> Path:
    if not isinstance(relative_path, str) or not relative_path or Path(relative_path).is_absolute():
        raise RouterContractError(f"{label} must be a non-empty plugin-relative path")
    lexical = (root / relative_path).resolve(strict=False)
    try:
        lexical.relative_to(root)
    except ValueError as exc:
        raise RouterContractError(f"{label} escapes the plugin root") from exc
    try:
        resolved = lexical.resolve(strict=True)
    except OSError as exc:
        raise RouterContractError(f"{label} is missing") from exc
    try:
        resolved.relative_to(root)
    except ValueError as exc:
        raise RouterContractError(f"{label} resolves outside the plugin root") from exc
    return resolved


def require_string(value: Any, label: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise RouterContractError(f"{label} must be a non-empty string")
    return value


def require_string_array(value: Any, label: str, allow_empty: bool = False) -> List[str]:
    if (
        not isinstance(value, list)
        or (not allow_empty and not value)
        or any(not isinstance(item, str) or not item.strip() for item in value)
    ):
        article = "an" if allow_empty else "a non-empty"
        raise RouterContractError(f"{label} must be {article} array of strings")
    return value


def parse_qualified_skill(value: Any, label: str) -> Dict[str, str]:
    raw = require_string(value, label)
    match = QUALIFIED_SKILL_ID.fullmatch(raw)
    if match is None:
        raise RouterContractError(f"{label} must be a fully qualified skill id")
    return {"plugin": match.group(1), "skill": match.group(2), "qualified": raw}


def parse_skill_frontmatter(text: str, label: str) -> Dict[str, str]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        raise RouterContractError(f"{label} has no YAML frontmatter")
    try:
        end = next(index for index, line in enumerate(lines[1:], start=1) if line.strip() == "---")
    except StopIteration as exc:
        raise RouterContractError(f"{label} has unterminated YAML frontmatter") from exc
    frontmatter = lines[1:end]
    name: Optional[str] = None
    metadata: Dict[str, str] = {}
    metadata_index: Optional[int] = None
    for index, line in enumerate(frontmatter):
        match = re.match(r"^name:\s*(.*)$", line)
        if match:
            name = match.group(1).strip()
        if re.match(r"^metadata:\s*$", line):
            metadata_index = index
    if metadata_index is not None:
        for line in frontmatter[metadata_index + 1 :]:
            if line and not line[0].isspace():
                break
            match = re.match(r"^\s+([a-z_]+):\s*(\S.*?)\s*$", line)
            if match:
                metadata[match.group(1)] = match.group(2)
    if not name or not metadata.get("role") or not metadata.get("routing_scope"):
        raise RouterContractError(
            f"{label} is missing name, metadata.role, or metadata.routing_scope"
        )
    return {
        "name": name,
        "role": metadata["role"],
        "routingScope": metadata["routing_scope"],
    }


def load_skill_profile(plugin_root: Path, skill_name: str) -> Dict[str, str]:
    if SKILL_ID.fullmatch(skill_name) is None:
        raise RouterContractError(f"invalid skill id {json.dumps(skill_name)}")
    relative = f"skills/{skill_name}/SKILL.md"
    skill_path = resolve_existing_inside(plugin_root, relative, f"skill {skill_name}")
    profile = parse_skill_frontmatter(
        skill_path.read_text(encoding="utf-8"), f"skill {skill_name}"
    )
    if profile["name"] != skill_name:
        raise RouterContractError(
            f"skill {skill_name} frontmatter name does not match its directory"
        )
    return profile


def validate_policy(policy: Any, plugin_root: Path) -> Dict[str, Any]:
    if not isinstance(policy, dict):
        raise RouterContractError("router policy must be a JSON object")
    if policy.get("schemaVersion") != 1:
        raise RouterContractError("router policy schemaVersion must be 1")
    plugin_name = require_string(policy.get("pluginName"), "pluginName")
    if SKILL_ID.fullmatch(plugin_name) is None:
        raise RouterContractError("pluginName is not a canonical plugin id")
    owner = parse_qualified_skill(policy.get("topLevelOwner"), "topLevelOwner")
    if owner["plugin"] != plugin_name:
        raise RouterContractError("topLevelOwner must belong to pluginName")
    owner_profile = load_skill_profile(plugin_root, owner["skill"])
    if (
        owner_profile["role"] != "top-level-orchestrator"
        or owner_profile["routingScope"] != "broad"
    ):
        raise RouterContractError(
            "topLevelOwner must resolve to the broad top-level orchestrator"
        )
    require_string_array(policy.get("hostScopes"), "hostScopes")
    domains = policy.get("domains")
    if not isinstance(domains, list) or not domains:
        raise RouterContractError("domains must be a non-empty array")
    for index, domain in enumerate(domains):
        if not isinstance(domain, dict):
            raise RouterContractError(f"domains[{index}] must be an object")
        require_string(domain.get("id"), f"domains[{index}].id")
        require_string_array(domain.get("promptSignals"), f"domains[{index}].promptSignals")
        workspace_files = require_string_array(
            domain.get("workspaceFiles"),
            f"domains[{index}].workspaceFiles",
            allow_empty=True,
        )
        workspace_extensions = require_string_array(
            domain.get("workspaceExtensions"),
            f"domains[{index}].workspaceExtensions",
            allow_empty=True,
        )
        if any(Path(item).name != item or item in {".", ".."} for item in workspace_files):
            raise RouterContractError(
                f"domains[{index}].workspaceFiles must contain file names, not paths"
            )
        if any(re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", item, re.I) is None for item in workspace_extensions):
            raise RouterContractError(
                f"domains[{index}].workspaceExtensions contains an invalid extension"
            )
        if domain.get("select") != policy.get("topLevelOwner"):
            raise RouterContractError(f"domains[{index}].select must equal topLevelOwner")
    suppression = policy.get("suppression")
    if not isinstance(suppression, dict) or suppression.get("whenExplicitSkillSelected") is not True:
        raise RouterContractError("suppression.whenExplicitSkillSelected must be true")
    if suppression.get("whenOtherPluginSelected") is not True:
        raise RouterContractError("suppression.whenOtherPluginSelected must be true")
    explicit_selection = policy.get("explicitSelection")
    if not isinstance(explicit_selection, dict):
        raise RouterContractError("explicitSelection must be an object")
    preserve_scopes = require_string_array(
        explicit_selection.get("preserveTopLevelForRoutingScopes"),
        "explicitSelection.preserveTopLevelForRoutingScopes",
    )
    suppress_scopes = require_string_array(
        explicit_selection.get("suppressTopLevelForRoutingScopes"),
        "explicitSelection.suppressTopLevelForRoutingScopes",
    )
    if any(scope in suppress_scopes for scope in preserve_scopes):
        raise RouterContractError("explicit selection routing scopes overlap")
    if "domain" not in preserve_scopes or "focused" not in suppress_scopes:
        raise RouterContractError(
            "explicit selection must preserve domain and suppress focused skills"
        )
    evidence = policy.get("evidence")
    if not isinstance(evidence, dict) or evidence.get("emitRouteSelection") is not True:
        raise RouterContractError("evidence.emitRouteSelection must be true")
    kernel_config = policy.get("kernel")
    if not isinstance(kernel_config, dict):
        raise RouterContractError("kernel must be an object")
    kernel_path = resolve_existing_inside(
        plugin_root, kernel_config.get("path"), "top-level owner kernel"
    )
    max_bytes = kernel_config.get("maxBytes")
    if isinstance(max_bytes, bool) or not isinstance(max_bytes, int) or not 0 < max_bytes <= 8000:
        raise RouterContractError("kernel.maxBytes must be an integer between 1 and 8000")
    kernel = kernel_path.read_text(encoding="utf-8").strip()
    if not kernel:
        raise RouterContractError("top-level owner kernel is empty")
    if len(kernel.encode("utf-8")) > max_bytes:
        raise RouterContractError("top-level owner kernel exceeds kernel.maxBytes")
    workspace = policy.get("workspace")
    if not isinstance(workspace, dict):
        raise RouterContractError("workspace must be an object")
    max_ancestor_depth = workspace.get("maxAncestorDepth")
    if (
        isinstance(max_ancestor_depth, bool)
        or not isinstance(max_ancestor_depth, int)
        or not 0 <= max_ancestor_depth <= 16
    ):
        raise RouterContractError(
            "workspace.maxAncestorDepth must be an integer from 0 through 16"
        )
    return {
        "policy": policy,
        "pluginName": plugin_name,
        "owner": owner,
        "kernel": kernel,
        "preserveScopes": preserve_scopes,
        "suppressScopes": suppress_scopes,
        "maxAncestorDepth": max_ancestor_depth,
    }


def load_harness(plugin_root: Optional[str] = None) -> Dict[str, Any]:
    requested_root = plugin_root or os.environ.get("PLUGIN_ROOT") or str(MODULE_ROOT)
    try:
        resolved_root = Path(requested_root).expanduser().resolve(strict=True)
    except OSError as exc:
        raise RouterContractError("PLUGIN_ROOT is missing") from exc
    policy_path = resolve_existing_inside(
        resolved_root, "routing/router-policy.json", "router policy"
    )
    try:
        policy = json.loads(policy_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RouterContractError("router policy is not valid JSON") from exc
    return {"pluginRoot": resolved_root, **validate_policy(policy, resolved_root)}


def parse_explicit_selections(prompt: str) -> Dict[str, Any]:
    skills: List[Dict[str, Any]] = []
    for match in re.finditer(
        r"\$([a-z0-9]+(?:-[a-z0-9]+)*)(?::([a-z0-9]+(?:-[a-z0-9]+)*))?",
        prompt,
    ):
        skills.append(
            {
                "plugin": match.group(1) if match.group(2) else None,
                "skill": match.group(2) or match.group(1),
                "qualified": bool(match.group(2)),
            }
        )
    deduplicated: List[Dict[str, Any]] = []
    for item in skills:
        if not any(
            candidate["plugin"] == item["plugin"] and candidate["skill"] == item["skill"]
            for candidate in deduplicated
        ):
            deduplicated.append(item)
    plugins = unique(
        match.group(1)
        for match in re.finditer(
            r"plugin://([a-z0-9]+(?:-[a-z0-9]+)*)(?:@[^)\s]+)?", prompt
        )
    )
    return {"skills": deduplicated, "plugins": plugins}


def prompt_matches_signal(prompt: str, signal: str) -> bool:
    escaped = r"\s+".join(
        re.escape(part)
        for part in unicodedata.normalize("NFKC", signal).lower().split()
    )
    expression = re.compile(rf"(^|[^a-z0-9]){escaped}($|[^a-z0-9])", re.I)
    return expression.search(unicodedata.normalize("NFKC", prompt)) is not None


def find_workspace_match(
    cwd: Any, domain: Dict[str, Any], max_ancestor_depth: int
) -> Optional[Dict[str, str]]:
    if not isinstance(cwd, str) or not cwd:
        return None
    current = Path(cwd).expanduser().resolve()
    for _depth in range(max_ancestor_depth + 1):
        for file_name in domain["workspaceFiles"]:
            try:
                if (current / file_name).is_file():
                    return {"type": "workspace-file", "detail": file_name}
            except OSError:
                pass
        try:
            entries = list(current.iterdir())
        except OSError:
            entries = []
        for extension in domain["workspaceExtensions"]:
            suffix = f".{extension.lower()}"
            if any(entry.name.lower().endswith(suffix) for entry in entries):
                return {"type": "workspace-extension", "detail": extension}
        if current.parent == current:
            break
        current = current.parent
    return None


def apple_skill_selection(
    harness: Dict[str, Any], selection: Dict[str, Any]
) -> Dict[str, Any]:
    belongs_to_plugin = selection.get("plugin") == harness["pluginName"]
    if selection.get("plugin") and not belongs_to_plugin:
        return {"kind": "foreign", "selection": selection}
    try:
        profile = load_skill_profile(harness["pluginRoot"], selection["skill"])
        return {"kind": "apple", "selection": selection, "profile": profile}
    except RouterContractError:
        if belongs_to_plugin:
            raise
        return {"kind": "foreign", "selection": selection}


def select_route(input_payload: Dict[str, Any], harness: Dict[str, Any]) -> Dict[str, Any]:
    if input_payload.get("agent_id") or input_payload.get("agent_type"):
        return {"kind": "skip", "reason": "subagent-turn"}
    if input_payload.get("hook_event_name") != "UserPromptSubmit" or not isinstance(
        input_payload.get("prompt"), str
    ):
        raise RouterContractError(
            "hook input must be a UserPromptSubmit event with a string prompt"
        )
    prompt = input_payload["prompt"]
    explicit = parse_explicit_selections(prompt)
    classified = [apple_skill_selection(harness, item) for item in explicit["skills"]]
    apple_skills = [item for item in classified if item["kind"] == "apple"]
    foreign_skills = [item for item in classified if item["kind"] == "foreign"]

    if apple_skills:
        ids = unique(
            f"{harness['pluginName']}:{item['selection']['skill']}" for item in apple_skills
        )
        if harness["owner"]["qualified"] in ids:
            return {
                "kind": "route",
                "routing": "explicit-top-level",
                "owner": harness["owner"]["qualified"],
                "activatedSkills": ids,
                "injection": "deduplicated",
                "injectKernel": False,
                "reasonType": "explicit-skill",
                "reasonDetail": harness["owner"]["qualified"],
            }
        preserve_parent = any(
            item["profile"]["routingScope"] in harness["preserveScopes"]
            for item in apple_skills
        )
        all_suppress_parent = all(
            item["profile"]["routingScope"] in harness["suppressScopes"]
            for item in apple_skills
        )
        if preserve_parent:
            return {
                "kind": "route",
                "routing": "orchestrator-led",
                "owner": harness["owner"]["qualified"],
                "activatedSkills": unique([harness["owner"]["qualified"], *ids]),
                "injection": "applied-for-explicit-domain",
                "injectKernel": True,
                "reasonType": "explicit-domain-skill",
                "reasonDetail": ",".join(ids),
            }
        if all_suppress_parent:
            return {
                "kind": "route",
                "routing": "explicit-specialist",
                "owner": ids[0],
                "activatedSkills": ids,
                "injection": "suppressed-by-explicit-focused-skill",
                "injectKernel": False,
                "reasonType": "explicit-focused-skill",
                "reasonDetail": ",".join(ids),
            }
        raise RouterContractError("explicit Apple skill has an unsupported routing scope")

    suppression = harness["policy"]["suppression"]
    if foreign_skills and suppression["whenExplicitSkillSelected"]:
        return {"kind": "skip", "reason": "foreign-explicit-skill"}
    selected_plugins = explicit["plugins"]
    if harness["pluginName"] in selected_plugins:
        return {
            "kind": "route",
            "routing": "orchestrator-led",
            "owner": harness["owner"]["qualified"],
            "activatedSkills": [harness["owner"]["qualified"]],
            "injection": "applied",
            "injectKernel": True,
            "reasonType": "explicit-plugin",
            "reasonDetail": harness["pluginName"],
        }
    if selected_plugins and suppression["whenOtherPluginSelected"]:
        return {"kind": "skip", "reason": "foreign-explicit-plugin"}

    for domain in harness["policy"]["domains"]:
        signal = next(
            (
                candidate
                for candidate in domain["promptSignals"]
                if prompt_matches_signal(prompt, candidate)
            ),
            None,
        )
        if signal is not None:
            return {
                "kind": "route",
                "routing": "orchestrator-led",
                "owner": harness["owner"]["qualified"],
                "activatedSkills": [harness["owner"]["qualified"]],
                "injection": "applied",
                "injectKernel": True,
                "reasonType": "prompt-signal",
                "reasonDetail": signal,
            }
        workspace = find_workspace_match(
            input_payload.get("cwd"), domain, harness["maxAncestorDepth"]
        )
        if workspace is not None:
            return {
                "kind": "route",
                "routing": "orchestrator-led",
                "owner": harness["owner"]["qualified"],
                "activatedSkills": [harness["owner"]["qualified"]],
                "injection": "applied",
                "injectKernel": True,
                "reasonType": workspace["type"],
                "reasonDetail": workspace["detail"],
            }
    return {"kind": "skip", "reason": "no-policy-match"}


def format_additional_context(decision: Dict[str, Any], harness: Dict[str, Any]) -> str:
    evidence = "\n".join(
        [
            '<apple-appdev-workflow-route schema-version="1">',
            f"Routing: {decision['routing']}",
            f"Selected owner: {decision['owner']}",
            f"Top-level owner injection: {decision['injection']}",
            f"Reason: {decision['reasonType']}:{decision['reasonDetail']}",
            "Activated skills:",
            *[f"- {skill}" for skill in decision["activatedSkills"]],
            "Evidence source: plugin UserPromptSubmit hook",
            "</apple-appdev-workflow-route>",
        ]
    )
    if not decision["injectKernel"]:
        return evidence
    return (
        f"{evidence}\n\n<apple-appdev-workflow-owner-kernel>\n"
        f"{harness['kernel']}\n</apple-appdev-workflow-owner-kernel>"
    )


def evaluate_input(
    input_payload: Dict[str, Any], plugin_root: Optional[str] = None
) -> Dict[str, Any]:
    try:
        if input_payload.get("agent_id") or input_payload.get("agent_type"):
            return {
                "output": None,
                "decision": {"kind": "skip", "reason": "subagent-turn"},
                "harness": None,
            }
        harness = load_harness(plugin_root)
        decision = select_route(input_payload, harness)
        if decision["kind"] == "skip":
            return {"output": None, "decision": decision, "harness": harness}
        additional_context = format_additional_context(decision, harness)
        if len(additional_context.encode("utf-8")) > 8000:
            raise RouterContractError(
                "combined route evidence and owner kernel exceed 8000 bytes"
            )
        return {
            "decision": decision,
            "harness": harness,
            "output": {
                "continue": True,
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": additional_context,
                },
            },
        }
    except Exception as error:  # Router integrity failures must block sampling.
        message = f"Apple workflow router failed closed: {error}"
        return {
            "decision": None,
            "harness": None,
            "output": {
                "continue": False,
                "stopReason": message,
                "systemMessage": message,
            },
        }


def strip_markdown(line: str) -> str:
    stripped = line.strip()
    stripped = re.sub(r"^#{1,6}\s+", "", stripped)
    stripped = stripped.replace("**", "")
    stripped = re.sub(r"^`|`$", "", stripped)
    return stripped.strip()


def first_nonempty_line(text: str) -> Optional[str]:
    for line in text.splitlines():
        stripped = strip_markdown(line)
        if stripped:
            return stripped
    return None


def activated_block(text: str) -> Optional[str]:
    collected: List[str] = []
    collecting = False
    saw_entry = False
    for raw_line in text.splitlines():
        stripped = strip_markdown(raw_line)
        match = re.match(r"^Activated skills\s*:?\s*(.*)$", stripped, re.I)
        if match:
            collecting = True
            if match.group(1):
                collected.append(match.group(1))
                saw_entry = True
            continue
        if not collecting:
            continue
        if re.match(r"^#{1,6}\s+", raw_line.strip()):
            break
        if not stripped:
            if saw_entry:
                break
            continue
        if re.match(r"^\s*[-*]\s+", raw_line) is None and saw_entry:
            break
        collected.append(re.sub(r"^[-*]\s+", "", stripped))
        saw_entry = True
    return "\n".join(collected) if collecting else None


def parse_activated_skills(text: str) -> Dict[str, Any]:
    block = activated_block(text)
    if block is None:
        return {
            "present": False,
            "qualified": [],
            "bare": [],
            "dollarPrefixed": [],
            "duplicateQualified": [],
            "unknownQualified": [],
            "malformed": [],
        }
    qualified_matches = QUALIFIED_SKILL_RE.findall(block)
    unqualified_text = QUALIFIED_SKILL_RE.sub(" ", block)
    bare_matches = APPLE_SKILL_RE.findall(unqualified_text)
    normalized_qualified = [item.lstrip("$") for item in qualified_matches]
    qualified = unique(normalized_qualified)
    known_skills = set()
    try:
        skills_root = Path(os.environ.get("PLUGIN_ROOT") or MODULE_ROOT) / "skills"
        known_skills = {entry.name for entry in skills_root.iterdir() if entry.is_dir()}
    except OSError:
        pass
    bare = unique(
        item.lstrip("$")
        for item in bare_matches
        if item.lstrip("$") in known_skills
    )
    dollar_prefixed = unique(
        item for item in [*qualified_matches, *bare_matches] if item.startswith("$")
    )
    duplicate_qualified = [
        item for item in qualified if normalized_qualified.count(item) > 1
    ]
    unknown_qualified = (
        []
        if not known_skills
        else [
            item
            for item in qualified
            if item[len(PLUGIN_PREFIX) :] not in known_skills
        ]
    )
    malformed = (
        ["duplicate plugin qualification"]
        if f"{PLUGIN_PREFIX}{PLUGIN_PREFIX}" in block
        else []
    )
    return {
        "present": True,
        "qualified": qualified,
        "bare": bare,
        "dollarPrefixed": dollar_prefixed,
        "duplicateQualified": duplicate_qualified,
        "unknownQualified": unknown_qualified,
        "malformed": malformed,
    }


def section_index(text: str, label: str) -> int:
    expected = label.lower()
    for index, raw_line in enumerate(text.splitlines()):
        stripped = strip_markdown(raw_line)
        normalized = re.sub(r":\s*.*$", "", stripped).strip().lower()
        if normalized == expected:
            return index
    return -1


def validate_section_order(text: str, required_sections: Sequence[str]) -> Dict[str, Any]:
    missing: List[str] = []
    prior_index = -1
    for section in required_sections:
        index = section_index(text, section)
        if index < 0:
            missing.append(section)
            continue
        if index <= prior_index:
            return {"missing": missing, "outOfOrder": section}
        prior_index = index
    return {"missing": missing, "outOfOrder": None}


def transcript_lines(state: Dict[str, Any]) -> Iterable[str]:
    transcript_path = state.get("transcriptPath")
    if not isinstance(transcript_path, str) or not transcript_path:
        return []
    path = Path(transcript_path)
    size = path.stat().st_size
    recorded_offset = state.get("transcriptOffset")
    offset = recorded_offset if isinstance(recorded_offset, int) else 0
    offset = min(max(offset, 0), size)
    with path.open("rb") as handle:
        handle.seek(offset)
        payload = handle.read().decode("utf-8")
    return payload.splitlines()


def skill_ids_from_text(text: str) -> List[str]:
    return [f"{PLUGIN_PREFIX}{match.group(1)}" for match in APPLE_SKILL_PATH_RE.finditer(text)]


def inspect_transcript_state(state: Dict[str, Any]) -> Dict[str, Any]:
    observed_skills: List[str] = []
    compaction_count = 0
    for raw_line in transcript_lines(state):
        if not raw_line.strip():
            continue
        if "compacted" not in raw_line and not (
            "SKILL.md" in raw_line and "apple-appdev-workflow" in raw_line
        ):
            continue
        try:
            row = json.loads(raw_line)
        except json.JSONDecodeError:
            continue
        if not isinstance(row, dict):
            continue
        if row.get("type") == "compacted":
            compaction_count += 1
            continue
        payload = row.get("payload")
        if row.get("type") != "response_item" or not isinstance(payload, dict):
            continue
        if payload.get("type") == "function_call" and isinstance(
            payload.get("arguments"), str
        ):
            observed_skills.extend(skill_ids_from_text(payload["arguments"]))
        if payload.get("type") == "message" and payload.get("role") == "user":
            content = payload.get("content")
            if not isinstance(content, list):
                continue
            for item in content:
                if (
                    isinstance(item, dict)
                    and isinstance(item.get("text"), str)
                    and "<skill>" in item["text"]
                ):
                    observed_skills.extend(skill_ids_from_text(item["text"]))
    return {
        "observedSkills": sorted(unique(observed_skills)),
        "compactionCount": compaction_count,
    }


def correction_reason(
    violations: Sequence[str],
    required_skills: Sequence[str],
    required_sections: Sequence[str],
    compaction_count: int,
) -> str:
    instructions = [
        f"The Apple workflow final-output contract failed: {'; '.join(violations)}.",
        "Rewrite only the final answer.",
        "Start with `Routing: orchestrator-led` as the first visible nonempty line.",
        "Use an `Activated skills:` block with these fully qualified ids and no `$`: "
        + ", ".join(required_skills)
        + ".",
    ]
    if required_sections:
        instructions.append(
            "Preserve this section order: " + " -> ".join(required_sections) + "."
        )
    if compaction_count > 0:
        instructions.append(
            f"The turn compacted {compaction_count} time(s); reconstruct the contract from this instruction."
        )
    instructions.append("Do not discuss this correction.")
    return " ".join(instructions)


def output_for_stop(input_payload: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    try:
        if (
            input_payload.get("hook_event_name") != "Stop"
            or input_payload.get("agent_id")
            or input_payload.get("agent_type")
        ):
            return None
        state = read_route_state(input_payload)
        if state is None:
            return None
        if (
            state.get("schemaVersion") != 1
            or state.get("sessionId") != input_payload.get("session_id")
            or state.get("turnId") != input_payload.get("turn_id")
        ):
            delete_route_state(input_payload)
            return None
        if input_payload.get("stop_hook_active") is True or state.get("enforceFinalContract") is not True:
            delete_route_state(input_payload)
            return None

        message = input_payload.get("last_assistant_message")
        message = message if isinstance(message, str) else ""
        activated = parse_activated_skills(message)
        trace = inspect_transcript_state(state)
        state_skills = state.get("activatedSkills")
        required_skills = sorted(
            unique(
                [
                    TOP_LEVEL_OWNER,
                    *(state_skills if isinstance(state_skills, list) else []),
                    *trace["observedSkills"],
                ]
            )
        )
        violations: List[str] = []
        if first_nonempty_line(message) != "Routing: orchestrator-led":
            violations.append(
                "the first visible line is not exactly `Routing: orchestrator-led`"
            )
        if not activated["present"]:
            violations.append("`Activated skills` is missing")
        if TOP_LEVEL_OWNER not in activated["qualified"]:
            violations.append(f"top-level owner {TOP_LEVEL_OWNER} is missing")
        missing_skills = [
            skill for skill in required_skills if skill not in activated["qualified"]
        ]
        if missing_skills:
            violations.append(
                "materially activated skills are missing: " + ", ".join(missing_skills)
            )
        if activated["bare"]:
            violations.append(
                "bare Apple skill ids are not allowed: " + ", ".join(activated["bare"])
            )
        if activated["dollarPrefixed"]:
            violations.append(
                "output skill ids must not use $: "
                + ", ".join(activated["dollarPrefixed"])
            )
        if activated["duplicateQualified"]:
            violations.append(
                "qualified skill ids must appear exactly once: "
                + ", ".join(activated["duplicateQualified"])
            )
        if activated["unknownQualified"]:
            violations.append(
                "unknown qualified skill ids: "
                + ", ".join(activated["unknownQualified"])
            )
        violations.extend(activated["malformed"])

        required_sections: Sequence[str] = ()
        for owner, sections in LANE_CONTRACTS:
            if owner in required_skills or owner in activated["qualified"]:
                required_sections = sections
                break
        feature = f"{PLUGIN_PREFIX}apple-feature-implementation"
        if not required_sections and (
            feature in required_skills or feature in activated["qualified"]
        ):
            required_sections = (
                "Routing",
                "Activated skills",
                "Tests added or updated",
                "Validation executed",
                "Branch-diff review status",
            )
        if required_sections:
            order = validate_section_order(message, required_sections)
            if order["missing"]:
                violations.append(
                    "required sections are missing: " + ", ".join(order["missing"])
                )
            if order["outOfOrder"]:
                violations.append(f"section is out of order: {order['outOfOrder']}")
        if not violations:
            delete_route_state(input_payload)
            return None
        return {
            "decision": "block",
            "reason": correction_reason(
                violations,
                required_skills,
                required_sections,
                trace["compactionCount"],
            ),
        }
    except Exception:
        return None


def read_input() -> Dict[str, Any]:
    payload = json.loads(sys.stdin.read())
    if not isinstance(payload, dict):
        raise RouterContractError("hook input must be a JSON object")
    return payload


def run_router() -> None:
    try:
        input_payload = read_input()
        evaluation = evaluate_input(input_payload)
        output = evaluation["output"]
        if (
            isinstance(output, dict)
            and output.get("continue") is True
            and isinstance(evaluation.get("decision"), dict)
            and evaluation["decision"].get("kind") == "route"
            and isinstance(evaluation.get("harness"), dict)
        ):
            write_route_state(
                input_payload, evaluation["decision"], evaluation["harness"]
            )
    except Exception as error:
        message = f"Apple workflow router failed closed: {error}"
        output = {
            "continue": False,
            "stopReason": message,
            "systemMessage": message,
        }
    if output is not None:
        print(json.dumps(output, separators=(",", ":")))


def run_stop() -> None:
    try:
        output = output_for_stop(read_input())
        if output is not None:
            print(json.dumps(output, separators=(",", ":")))
    except Exception:
        pass


def main() -> int:
    if len(sys.argv) != 2 or sys.argv[1] not in {"route", "stop"}:
        print("usage: apple_hook.py route|stop", file=sys.stderr)
        return 2
    if sys.argv[1] == "route":
        run_router()
    else:
        run_stop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
