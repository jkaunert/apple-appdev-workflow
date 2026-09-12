#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import process from "node:process";
import { fileURLToPath, pathToFileURL } from "node:url";

const MODULE_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SKILL_ID = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const QUALIFIED_SKILL_ID = /^([a-z0-9]+(?:-[a-z0-9]+)*):([a-z0-9]+(?:-[a-z0-9]+)*)$/;
const STATE_COMPONENT = /^[A-Za-z0-9._-]{1,128}$/;
const STATE_MAX_AGE_MS = 7 * 24 * 60 * 60 * 1000;

export class RouterContractError extends Error {}

function unique(values) {
  return [...new Set(values)];
}

function routeStateRoot() {
  if (process.env.APPLE_APPDEV_ROUTE_STATE_ROOT) {
    return path.resolve(process.env.APPLE_APPDEV_ROUTE_STATE_ROOT);
  }
  const codexHome = process.env.CODEX_HOME
    ? path.resolve(process.env.CODEX_HOME)
    : path.join(os.homedir(), ".codex");
  return path.join(codexHome, "tmp", "apple-appdev-workflow", "route-state");
}

function safeStateComponent(value) {
  return (
    typeof value === "string"
    && value !== "."
    && value !== ".."
    && STATE_COMPONENT.test(value)
  )
    ? value
    : null;
}

export function routeStatePathForInput(input) {
  const sessionId = safeStateComponent(input?.session_id);
  const turnId = safeStateComponent(input?.turn_id);
  if (!sessionId || !turnId) return null;
  return path.join(routeStateRoot(), sessionId, `${turnId}.json`);
}

export function readRouteState(input) {
  const statePath = routeStatePathForInput(input);
  if (!statePath) return null;
  try {
    const state = JSON.parse(fs.readFileSync(statePath, "utf8"));
    return state && typeof state === "object" && !Array.isArray(state) ? state : null;
  } catch {
    return null;
  }
}

export function deleteRouteState(input) {
  const statePath = routeStatePathForInput(input);
  if (!statePath) return;
  try {
    fs.unlinkSync(statePath);
  } catch (error) {
    if (error?.code !== "ENOENT") throw error;
  }
}

function pruneRouteState(root) {
  let sessionEntries = [];
  try {
    sessionEntries = fs.readdirSync(root, { withFileTypes: true });
  } catch {
    return;
  }
  const cutoff = Date.now() - STATE_MAX_AGE_MS;
  for (const sessionEntry of sessionEntries) {
    if (!sessionEntry.isDirectory() || !STATE_COMPONENT.test(sessionEntry.name)) continue;
    const sessionRoot = path.join(root, sessionEntry.name);
    let stateEntries = [];
    try {
      stateEntries = fs.readdirSync(sessionRoot, { withFileTypes: true });
    } catch {
      continue;
    }
    for (const stateEntry of stateEntries) {
      if (!stateEntry.isFile() || !stateEntry.name.endsWith(".json")) continue;
      const statePath = path.join(sessionRoot, stateEntry.name);
      try {
        if (fs.statSync(statePath).mtimeMs < cutoff) fs.unlinkSync(statePath);
      } catch {
        // Pruning is opportunistic and must not affect routing.
      }
    }
    try {
      if (fs.readdirSync(sessionRoot).length === 0) fs.rmdirSync(sessionRoot);
    } catch {
      // Another hook may be using the directory.
    }
  }
}

export function writeRouteState(input, decision, harness) {
  const statePath = routeStatePathForInput(input);
  if (!statePath) {
    throw new RouterContractError("routed hook input requires safe session_id and turn_id values");
  }
  let transcriptOffset = null;
  if (typeof input.transcript_path === "string" && input.transcript_path.length > 0) {
    try {
      transcriptOffset = fs.statSync(input.transcript_path).size;
    } catch {
      transcriptOffset = null;
    }
  }
  const state = {
    schemaVersion: 1,
    sessionId: input.session_id,
    turnId: input.turn_id,
    transcriptPath: typeof input.transcript_path === "string" ? input.transcript_path : null,
    transcriptOffset,
    routing: decision.routing,
    owner: decision.owner,
    topLevelOwner: harness.owner.qualified,
    activatedSkills: decision.activatedSkills,
    enforceFinalContract: decision.owner === harness.owner.qualified,
    createdAt: new Date().toISOString(),
  };
  const root = routeStateRoot();
  fs.mkdirSync(path.dirname(statePath), { recursive: true, mode: 0o700 });
  const temporaryPath = `${statePath}.${process.pid}.${Date.now()}.tmp`;
  fs.writeFileSync(temporaryPath, `${JSON.stringify(state)}\n`, { encoding: "utf8", mode: 0o600 });
  fs.renameSync(temporaryPath, statePath);
  pruneRouteState(root);
  return state;
}

function isContained(root, candidate) {
  const relative = path.relative(root, candidate);
  return relative === "" || (!relative.startsWith(`..${path.sep}`) && relative !== ".." && !path.isAbsolute(relative));
}

function resolveExistingInside(root, relativePath, label) {
  if (typeof relativePath !== "string" || relativePath.length === 0 || path.isAbsolute(relativePath)) {
    throw new RouterContractError(`${label} must be a non-empty plugin-relative path`);
  }
  const lexical = path.resolve(root, relativePath);
  if (!isContained(root, lexical)) {
    throw new RouterContractError(`${label} escapes the plugin root`);
  }
  let resolved;
  try {
    resolved = fs.realpathSync(lexical);
  } catch {
    throw new RouterContractError(`${label} is missing`);
  }
  if (!isContained(root, resolved)) {
    throw new RouterContractError(`${label} resolves outside the plugin root`);
  }
  return resolved;
}

function requireString(value, label) {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new RouterContractError(`${label} must be a non-empty string`);
  }
  return value;
}

function requireStringArray(value, label, { allowEmpty = false } = {}) {
  if (
    !Array.isArray(value)
    || (!allowEmpty && value.length === 0)
    || value.some((entry) => typeof entry !== "string" || entry.trim().length === 0)
  ) {
    throw new RouterContractError(`${label} must be ${allowEmpty ? "an" : "a non-empty"} array of strings`);
  }
  return value;
}

function parseQualifiedSkill(value, label) {
  const match = QUALIFIED_SKILL_ID.exec(requireString(value, label));
  if (!match) {
    throw new RouterContractError(`${label} must be a fully qualified skill id`);
  }
  return { plugin: match[1], skill: match[2], qualified: value };
}

function parseSkillFrontmatter(text, label) {
  const lines = text.split(/\r?\n/);
  if (lines[0]?.trim() !== "---") {
    throw new RouterContractError(`${label} has no YAML frontmatter`);
  }
  const end = lines.slice(1).findIndex((line) => line.trim() === "---");
  if (end < 0) {
    throw new RouterContractError(`${label} has unterminated YAML frontmatter`);
  }
  const frontmatter = lines.slice(1, end + 1);
  const nameLine = frontmatter.find((line) => /^name:\s*/.test(line));
  const name = nameLine?.replace(/^name:\s*/, "").trim();
  const metadataIndex = frontmatter.findIndex((line) => /^metadata:\s*$/.test(line));
  const metadata = {};
  if (metadataIndex >= 0) {
    for (const line of frontmatter.slice(metadataIndex + 1)) {
      if (line.length > 0 && !/^\s/.test(line)) break;
      const match = /^\s+([a-z_]+):\s*(\S.*?)\s*$/.exec(line);
      if (match) metadata[match[1]] = match[2];
    }
  }
  if (!name || !metadata.role || !metadata.routing_scope) {
    throw new RouterContractError(`${label} is missing name, metadata.role, or metadata.routing_scope`);
  }
  return { name, role: metadata.role, routingScope: metadata.routing_scope };
}

function loadSkillProfile(pluginRoot, skillName) {
  if (!SKILL_ID.test(skillName)) {
    throw new RouterContractError(`invalid skill id ${JSON.stringify(skillName)}`);
  }
  const relative = path.join("skills", skillName, "SKILL.md");
  const skillPath = resolveExistingInside(pluginRoot, relative, `skill ${skillName}`);
  const profile = parseSkillFrontmatter(fs.readFileSync(skillPath, "utf8"), `skill ${skillName}`);
  if (profile.name !== skillName) {
    throw new RouterContractError(`skill ${skillName} frontmatter name does not match its directory`);
  }
  return profile;
}

function validatePolicy(policy, pluginRoot) {
  if (!policy || typeof policy !== "object" || Array.isArray(policy)) {
    throw new RouterContractError("router policy must be a JSON object");
  }
  if (policy.schemaVersion !== 1) {
    throw new RouterContractError("router policy schemaVersion must be 1");
  }
  const pluginName = requireString(policy.pluginName, "pluginName");
  if (!SKILL_ID.test(pluginName)) {
    throw new RouterContractError("pluginName is not a canonical plugin id");
  }
  const owner = parseQualifiedSkill(policy.topLevelOwner, "topLevelOwner");
  if (owner.plugin !== pluginName) {
    throw new RouterContractError("topLevelOwner must belong to pluginName");
  }
  const ownerProfile = loadSkillProfile(pluginRoot, owner.skill);
  if (ownerProfile.role !== "top-level-orchestrator" || ownerProfile.routingScope !== "broad") {
    throw new RouterContractError("topLevelOwner must resolve to the broad top-level orchestrator");
  }
  requireStringArray(policy.hostScopes, "hostScopes");
  if (!Array.isArray(policy.domains) || policy.domains.length === 0) {
    throw new RouterContractError("domains must be a non-empty array");
  }
  for (const [index, domain] of policy.domains.entries()) {
    if (!domain || typeof domain !== "object" || Array.isArray(domain)) {
      throw new RouterContractError(`domains[${index}] must be an object`);
    }
    requireString(domain.id, `domains[${index}].id`);
    requireStringArray(domain.promptSignals, `domains[${index}].promptSignals`);
    requireStringArray(domain.workspaceFiles, `domains[${index}].workspaceFiles`, { allowEmpty: true });
    requireStringArray(domain.workspaceExtensions, `domains[${index}].workspaceExtensions`, { allowEmpty: true });
    if (domain.workspaceFiles.some((entry) => path.basename(entry) !== entry || entry === "." || entry === "..")) {
      throw new RouterContractError(`domains[${index}].workspaceFiles must contain file names, not paths`);
    }
    if (domain.workspaceExtensions.some((entry) => !/^[a-z0-9]+(?:-[a-z0-9]+)*$/i.test(entry))) {
      throw new RouterContractError(`domains[${index}].workspaceExtensions contains an invalid extension`);
    }
    if (domain.select !== policy.topLevelOwner) {
      throw new RouterContractError(`domains[${index}].select must equal topLevelOwner`);
    }
  }
  if (policy.suppression?.whenExplicitSkillSelected !== true) {
    throw new RouterContractError("suppression.whenExplicitSkillSelected must be true");
  }
  if (policy.suppression?.whenOtherPluginSelected !== true) {
    throw new RouterContractError("suppression.whenOtherPluginSelected must be true");
  }
  const preserveScopes = requireStringArray(
    policy.explicitSelection?.preserveTopLevelForRoutingScopes,
    "explicitSelection.preserveTopLevelForRoutingScopes",
  );
  const suppressScopes = requireStringArray(
    policy.explicitSelection?.suppressTopLevelForRoutingScopes,
    "explicitSelection.suppressTopLevelForRoutingScopes",
  );
  if (preserveScopes.some((scope) => suppressScopes.includes(scope))) {
    throw new RouterContractError("explicit selection routing scopes overlap");
  }
  if (!preserveScopes.includes("domain") || !suppressScopes.includes("focused")) {
    throw new RouterContractError("explicit selection must preserve domain and suppress focused skills");
  }
  if (policy.evidence?.emitRouteSelection !== true) {
    throw new RouterContractError("evidence.emitRouteSelection must be true");
  }
  const kernelPath = resolveExistingInside(
    pluginRoot,
    policy.kernel?.path,
    "top-level owner kernel",
  );
  const maxBytes = policy.kernel?.maxBytes;
  if (!Number.isInteger(maxBytes) || maxBytes <= 0 || maxBytes > 8000) {
    throw new RouterContractError("kernel.maxBytes must be an integer between 1 and 8000");
  }
  const kernel = fs.readFileSync(kernelPath, "utf8").trim();
  if (kernel.length === 0) {
    throw new RouterContractError("top-level owner kernel is empty");
  }
  if (Buffer.byteLength(kernel, "utf8") > maxBytes) {
    throw new RouterContractError("top-level owner kernel exceeds kernel.maxBytes");
  }
  const maxAncestorDepth = policy.workspace?.maxAncestorDepth;
  if (!Number.isInteger(maxAncestorDepth) || maxAncestorDepth < 0 || maxAncestorDepth > 16) {
    throw new RouterContractError("workspace.maxAncestorDepth must be an integer from 0 through 16");
  }
  return { policy, pluginName, owner, kernel, preserveScopes, suppressScopes, maxAncestorDepth };
}

export function loadHarness(pluginRoot = process.env.PLUGIN_ROOT || MODULE_ROOT) {
  let resolvedRoot;
  try {
    resolvedRoot = fs.realpathSync(pluginRoot);
  } catch {
    throw new RouterContractError("PLUGIN_ROOT is missing");
  }
  const policyPath = resolveExistingInside(resolvedRoot, "routing/router-policy.json", "router policy");
  let policy;
  try {
    policy = JSON.parse(fs.readFileSync(policyPath, "utf8"));
  } catch {
    throw new RouterContractError("router policy is not valid JSON");
  }
  return { pluginRoot: resolvedRoot, ...validatePolicy(policy, resolvedRoot) };
}

export function parseExplicitSelections(prompt) {
  const skills = [];
  const skillPattern = /\$([a-z0-9]+(?:-[a-z0-9]+)*)(?::([a-z0-9]+(?:-[a-z0-9]+)*))?/g;
  for (const match of prompt.matchAll(skillPattern)) {
    skills.push(
      match[2]
        ? { plugin: match[1], skill: match[2], qualified: true }
        : { plugin: null, skill: match[1], qualified: false },
    );
  }
  const plugins = [];
  const pluginPattern = /plugin:\/\/([a-z0-9]+(?:-[a-z0-9]+)*)(?:@[^)\s]+)?/g;
  for (const match of prompt.matchAll(pluginPattern)) plugins.push(match[1]);
  return {
    skills: skills.filter((item, index) => skills.findIndex((candidate) => candidate.plugin === item.plugin && candidate.skill === item.skill) === index),
    plugins: unique(plugins),
  };
}

function promptMatchesSignal(prompt, signal) {
  const escaped = signal
    .normalize("NFKC")
    .toLowerCase()
    .split(/\s+/)
    .map((part) => part.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
    .join("\\s+");
  const expression = new RegExp(`(^|[^a-z0-9])${escaped}($|[^a-z0-9])`, "i");
  return expression.test(prompt.normalize("NFKC"));
}

function findWorkspaceMatch(cwd, domain, maxAncestorDepth) {
  if (typeof cwd !== "string" || cwd.length === 0) return null;
  let current = path.resolve(cwd);
  for (let depth = 0; depth <= maxAncestorDepth; depth += 1) {
    for (const fileName of domain.workspaceFiles) {
      try {
        if (fs.statSync(path.join(current, fileName)).isFile()) {
          return { type: "workspace-file", detail: fileName };
        }
      } catch {
        // Missing and unreadable workspace markers are not matches.
      }
    }
    let entries = [];
    try {
      entries = fs.readdirSync(current, { withFileTypes: true });
    } catch {
      entries = [];
    }
    for (const extension of domain.workspaceExtensions) {
      const suffix = `.${extension.toLowerCase()}`;
      if (entries.some((entry) => entry.name.toLowerCase().endsWith(suffix))) {
        return { type: "workspace-extension", detail: extension };
      }
    }
    const parent = path.dirname(current);
    if (parent === current) break;
    current = parent;
  }
  return null;
}

function appleSkillSelection(harness, selection) {
  const belongsToPlugin = selection.plugin === harness.pluginName;
  if (selection.plugin && !belongsToPlugin) return { kind: "foreign", selection };
  try {
    const profile = loadSkillProfile(harness.pluginRoot, selection.skill);
    return { kind: "apple", selection, profile };
  } catch (error) {
    if (belongsToPlugin) throw error;
    return { kind: "foreign", selection };
  }
}

export function selectRoute(input, harness) {
  if (input.agent_id || input.agent_type) return { kind: "skip", reason: "subagent-turn" };
  if (input.hook_event_name !== "UserPromptSubmit" || typeof input.prompt !== "string") {
    throw new RouterContractError("hook input must be a UserPromptSubmit event with a string prompt");
  }
  const explicit = parseExplicitSelections(input.prompt);
  const classified = explicit.skills.map((selection) => appleSkillSelection(harness, selection));
  const appleSkills = classified.filter((item) => item.kind === "apple");
  const foreignSkills = classified.filter((item) => item.kind === "foreign");

  if (appleSkills.length > 0) {
    const ids = unique(appleSkills.map((item) => `${harness.pluginName}:${item.selection.skill}`));
    if (ids.includes(harness.owner.qualified)) {
      return {
        kind: "route",
        routing: "explicit-top-level",
        owner: harness.owner.qualified,
        activatedSkills: ids,
        injection: "deduplicated",
        injectKernel: false,
        reasonType: "explicit-skill",
        reasonDetail: harness.owner.qualified,
      };
    }
    const preserveParent = appleSkills.some((item) => harness.preserveScopes.includes(item.profile.routingScope));
    const allSuppressParent = appleSkills.every((item) => harness.suppressScopes.includes(item.profile.routingScope));
    if (preserveParent) {
      return {
        kind: "route",
        routing: "orchestrator-led",
        owner: harness.owner.qualified,
        activatedSkills: unique([harness.owner.qualified, ...ids]),
        injection: "applied-for-explicit-domain",
        injectKernel: true,
        reasonType: "explicit-domain-skill",
        reasonDetail: ids.join(","),
      };
    }
    if (allSuppressParent) {
      return {
        kind: "route",
        routing: "explicit-specialist",
        owner: ids[0],
        activatedSkills: ids,
        injection: "suppressed-by-explicit-focused-skill",
        injectKernel: false,
        reasonType: "explicit-focused-skill",
        reasonDetail: ids.join(","),
      };
    }
    throw new RouterContractError("explicit Apple skill has an unsupported routing scope");
  }

  if (foreignSkills.length > 0 && harness.policy.suppression.whenExplicitSkillSelected) {
    return { kind: "skip", reason: "foreign-explicit-skill" };
  }
  const selectedPlugins = explicit.plugins;
  if (selectedPlugins.includes(harness.pluginName)) {
    return {
      kind: "route",
      routing: "orchestrator-led",
      owner: harness.owner.qualified,
      activatedSkills: [harness.owner.qualified],
      injection: "applied",
      injectKernel: true,
      reasonType: "explicit-plugin",
      reasonDetail: harness.pluginName,
    };
  }
  if (selectedPlugins.length > 0 && harness.policy.suppression.whenOtherPluginSelected) {
    return { kind: "skip", reason: "foreign-explicit-plugin" };
  }

  for (const domain of harness.policy.domains) {
    const signal = domain.promptSignals.find((candidate) => promptMatchesSignal(input.prompt, candidate));
    if (signal) {
      return {
        kind: "route",
        routing: "orchestrator-led",
        owner: harness.owner.qualified,
        activatedSkills: [harness.owner.qualified],
        injection: "applied",
        injectKernel: true,
        reasonType: "prompt-signal",
        reasonDetail: signal,
      };
    }
    const workspace = findWorkspaceMatch(input.cwd, domain, harness.maxAncestorDepth);
    if (workspace) {
      return {
        kind: "route",
        routing: "orchestrator-led",
        owner: harness.owner.qualified,
        activatedSkills: [harness.owner.qualified],
        injection: "applied",
        injectKernel: true,
        reasonType: workspace.type,
        reasonDetail: workspace.detail,
      };
    }
  }
  return { kind: "skip", reason: "no-policy-match" };
}

export function formatAdditionalContext(decision, harness) {
  const evidence = [
    '<apple-appdev-workflow-route schema-version="1">',
    `Routing: ${decision.routing}`,
    `Selected owner: ${decision.owner}`,
    `Top-level owner injection: ${decision.injection}`,
    `Reason: ${decision.reasonType}:${decision.reasonDetail}`,
    "Activated skills:",
    ...decision.activatedSkills.map((skill) => `- ${skill}`),
    "Evidence source: plugin UserPromptSubmit hook",
    "</apple-appdev-workflow-route>",
  ].join("\n");
  if (!decision.injectKernel) return evidence;
  return `${evidence}\n\n<apple-appdev-workflow-owner-kernel>\n${harness.kernel}\n</apple-appdev-workflow-owner-kernel>`;
}

export function evaluateInput(input, { pluginRoot } = {}) {
  try {
    if (input?.agent_id || input?.agent_type) {
      return { output: null, decision: { kind: "skip", reason: "subagent-turn" }, harness: null };
    }
    const harness = loadHarness(pluginRoot);
    const decision = selectRoute(input, harness);
    if (decision.kind === "skip") return { output: null, decision, harness };
    const additionalContext = formatAdditionalContext(decision, harness);
    if (Buffer.byteLength(additionalContext, "utf8") > 8000) {
      throw new RouterContractError("combined route evidence and owner kernel exceed 8000 bytes");
    }
    return {
      decision,
      harness,
      output: {
        continue: true,
        hookSpecificOutput: {
          hookEventName: "UserPromptSubmit",
          additionalContext,
        },
      },
    };
  } catch (error) {
    const detail = error instanceof Error ? error.message : "unknown router failure";
    const message = `Apple workflow router failed closed: ${detail}`;
    return {
      decision: null,
      harness: null,
      output: {
        continue: false,
        stopReason: message,
        systemMessage: message,
      },
    };
  }
}

export function outputForInput(input, options = {}) {
  return evaluateInput(input, options).output;
}

async function readInput() {
  let raw = "";
  for await (const chunk of process.stdin) raw += chunk;
  try {
    return JSON.parse(raw);
  } catch {
    throw new RouterContractError("hook input is not valid JSON");
  }
}

export async function runCli() {
  let output;
  try {
    const input = await readInput();
    const evaluation = evaluateInput(input);
    output = evaluation.output;
    if (
      output?.continue === true
      && evaluation.decision?.kind === "route"
      && evaluation.harness
    ) {
      writeRouteState(input, evaluation.decision, evaluation.harness);
    }
  } catch (error) {
    const detail = error instanceof Error ? error.message : "unknown router failure";
    const message = `Apple workflow router failed closed: ${detail}`;
    output = { continue: false, stopReason: message, systemMessage: message };
  }
  if (output) process.stdout.write(`${JSON.stringify(output)}\n`);
}

const invokedPath = process.argv[1] ? pathToFileURL(path.resolve(process.argv[1])).href : null;
if (invokedPath === import.meta.url) await runCli();
