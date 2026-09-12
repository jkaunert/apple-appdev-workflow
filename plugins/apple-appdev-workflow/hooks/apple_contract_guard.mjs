#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { StringDecoder } from "node:string_decoder";
import { fileURLToPath, pathToFileURL } from "node:url";

import {
  deleteRouteState,
  readRouteState,
} from "./apple_router.mjs";

const MODULE_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const PLUGIN_PREFIX = "apple-appdev-workflow:";
const TOP_LEVEL_OWNER = `${PLUGIN_PREFIX}apple-app-orchestrator`;
const TRANSCRIPT_READ_CHUNK_BYTES = 64 * 1024;
const APPLE_SKILL_PATH_RE = /apple-appdev-workflow(?:-integration)?(?:[/\\][^/\\\s"'`]+)*[/\\]skills[/\\]([a-z0-9]+(?:-[a-z0-9]+)*)[/\\]SKILL\.md\b/g;
const QUALIFIED_SKILL_RE = /\$?apple-appdev-workflow:[a-z0-9]+(?:-[a-z0-9]+)*/g;
const APPLE_SKILL_RE = /\$?apple-[a-z0-9]+(?:-[a-z0-9]+)*/g;

const LANE_CONTRACTS = new Map([
  [
    `${PLUGIN_PREFIX}apple-architecture-orchestrator`,
    [
      "Routing",
      "Activated skills",
      "Assessment scope",
      "Discovery findings",
      "What Should Change First",
      "Recommended follow-on structure",
      "Risks",
      "Next implementation entry points",
    ],
  ],
  [
    `${PLUGIN_PREFIX}apple-bootstrap-orchestrator`,
    [
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
    ],
  ],
  [
    `${PLUGIN_PREFIX}apple-review-orchestrator`,
    [
      "Routing",
      "Activated skills",
      "Review scope",
      "Discovery findings",
      "Overall assessment",
      "Findings",
      "Test coverage assessment",
      "Residual risks",
      "Recommendation",
    ],
  ],
  [
    `${PLUGIN_PREFIX}apple-debug-orchestrator`,
    [
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
    ],
  ],
  [
    `${PLUGIN_PREFIX}apple-product-surface-orchestrator`,
    [
      "Routing",
      "Activated skills",
      "Surface scope",
      "Discovery findings",
      "Surface assessment",
      "Coordinated recommendations",
      "Validation and rollout notes",
      "Direct follow-on lanes",
    ],
  ],
  [
    `${PLUGIN_PREFIX}apple-persistence-orchestrator`,
    [
      "Routing",
      "Activated skills",
      "Persistence scope",
      "Discovery findings",
      "Persistence assessment",
      "Coordinated recommendations",
      "Migration and rollout notes",
      "Direct follow-on lanes",
    ],
  ],
  [
    `${PLUGIN_PREFIX}apple-release-orchestrator`,
    [
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
    ],
  ],
  [
    `${PLUGIN_PREFIX}apple-accessibility-orchestrator`,
    [
      "Routing",
      "Activated skills",
      "Accessibility scope",
      "Framework targets",
      "Overall assessment",
      "Required implementation constraints",
      "Validation checklist",
      "Manual checks",
    ],
  ],
]);

function unique(values) {
  return [...new Set(values)];
}

function stripMarkdown(line) {
  return line
    .trim()
    .replace(/^#{1,6}\s+/, "")
    .replaceAll("**", "")
    .replace(/^`|`$/g, "")
    .trim();
}

function firstNonemptyLine(text) {
  for (const line of text.split(/\r?\n/)) {
    const stripped = stripMarkdown(line);
    if (stripped) return stripped;
  }
  return null;
}

function activatedBlock(text) {
  const lines = text.split(/\r?\n/);
  const collected = [];
  let collecting = false;
  let sawEntry = false;
  for (const rawLine of lines) {
    const stripped = stripMarkdown(rawLine);
    const match = /^Activated skills\s*:?\s*(.*)$/i.exec(stripped);
    if (match) {
      collecting = true;
      if (match[1]) {
        collected.push(match[1]);
        sawEntry = true;
      }
      continue;
    }
    if (!collecting) continue;
    if (/^#{1,6}\s+/.test(rawLine.trim())) break;
    if (!stripped) {
      if (sawEntry) break;
      continue;
    }
    if (!/^\s*[-*]\s+/.test(rawLine) && sawEntry) break;
    collected.push(stripped.replace(/^[-*]\s+/, ""));
    sawEntry = true;
  }
  return collecting ? collected.join("\n") : null;
}

function parseActivatedSkills(text) {
  const block = activatedBlock(text);
  if (block === null) {
    return {
      present: false,
      qualified: [],
      bare: [],
      dollarPrefixed: [],
      duplicateQualified: [],
      unknownQualified: [],
      malformed: [],
    };
  }
  const qualifiedMatches = [...block.matchAll(QUALIFIED_SKILL_RE)].map((match) => match[0]);
  const unqualifiedText = block.replace(QUALIFIED_SKILL_RE, " ");
  const bareMatches = [...unqualifiedText.matchAll(APPLE_SKILL_RE)].map((match) => match[0]);
  const normalizedQualified = qualifiedMatches.map((skill) => skill.replace(/^\$/, ""));
  const qualified = unique(normalizedQualified);
  const knownSkills = new Set();
  try {
    for (const entry of fs.readdirSync(path.join(process.env.PLUGIN_ROOT || MODULE_ROOT, "skills"), {
      withFileTypes: true,
    })) {
      if (entry.isDirectory()) knownSkills.add(entry.name);
    }
  } catch {
    // Required-skill checks still work when the plugin skill directory is unavailable.
  }
  const bare = unique(
    bareMatches
      .map((skill) => skill.replace(/^\$/, ""))
      .filter((skill) => knownSkills.has(skill)),
  );
  const dollarPrefixed = unique(
    [...qualifiedMatches, ...bareMatches].filter((skill) => skill.startsWith("$")),
  );
  const duplicateQualified = qualified.filter(
    (skill) => normalizedQualified.filter((candidate) => candidate === skill).length > 1,
  );
  const unknownQualified = knownSkills.size === 0
    ? []
    : qualified.filter((skill) => !knownSkills.has(skill.slice(PLUGIN_PREFIX.length)));
  const malformed = [];
  if (block.includes(`${PLUGIN_PREFIX}${PLUGIN_PREFIX}`)) {
    malformed.push("duplicate plugin qualification");
  }
  return {
    present: true,
    qualified,
    bare,
    dollarPrefixed,
    duplicateQualified,
    unknownQualified,
    malformed,
  };
}

function sectionIndex(text, label) {
  const expected = label.toLowerCase();
  const lines = text.split(/\r?\n/);
  for (const [index, rawLine] of lines.entries()) {
    const stripped = stripMarkdown(rawLine);
    const normalized = stripped.replace(/:\s*.*$/, "").trim().toLowerCase();
    if (normalized === expected) return index;
  }
  return -1;
}

function validateSectionOrder(text, requiredSections) {
  const missing = [];
  let priorIndex = -1;
  for (const section of requiredSections) {
    const index = sectionIndex(text, section);
    if (index < 0) {
      missing.push(section);
      continue;
    }
    if (index <= priorIndex) {
      return { missing, outOfOrder: section };
    }
    priorIndex = index;
  }
  return { missing, outOfOrder: null };
}

function* transcriptLines(state) {
  if (typeof state.transcriptPath !== "string" || state.transcriptPath.length === 0) return;
  const stat = fs.statSync(state.transcriptPath);
  const recordedOffset = Number.isInteger(state.transcriptOffset) ? state.transcriptOffset : 0;
  let position = Math.min(Math.max(recordedOffset, 0), stat.size);
  const descriptor = fs.openSync(state.transcriptPath, "r");
  const buffer = Buffer.alloc(TRANSCRIPT_READ_CHUNK_BYTES);
  const decoder = new StringDecoder("utf8");
  let pending = "";
  try {
    while (position < stat.size) {
      const bytesRead = fs.readSync(
        descriptor,
        buffer,
        0,
        Math.min(buffer.length, stat.size - position),
        position,
      );
      if (bytesRead === 0) break;
      position += bytesRead;
      const physicalLines = `${pending}${decoder.write(buffer.subarray(0, bytesRead))}`.split("\n");
      pending = physicalLines.pop() || "";
      yield* physicalLines;
    }
    pending += decoder.end();
    if (pending) yield pending;
  } finally {
    fs.closeSync(descriptor);
  }
}

function skillIdsFromText(text) {
  const ids = [];
  for (const match of text.matchAll(APPLE_SKILL_PATH_RE)) {
    ids.push(`${PLUGIN_PREFIX}${match[1]}`);
  }
  return ids;
}

export function inspectTranscriptState(state) {
  const observedSkills = [];
  let compactionCount = 0;
  for (const rawLine of transcriptLines(state)) {
    if (!rawLine.trim()) continue;
    if (
      !rawLine.includes("compacted")
      && !(rawLine.includes("SKILL.md") && rawLine.includes("apple-appdev-workflow"))
    ) {
      continue;
    }
    let row;
    try {
      row = JSON.parse(rawLine);
    } catch {
      continue;
    }
    if (row?.type === "compacted") {
      compactionCount += 1;
      continue;
    }
    if (row?.type !== "response_item" || !row.payload || typeof row.payload !== "object") continue;
    const payload = row.payload;
    if (payload.type === "function_call" && typeof payload.arguments === "string") {
      observedSkills.push(...skillIdsFromText(payload.arguments));
    }
    if (payload.type === "message" && payload.role === "user") {
      const content = Array.isArray(payload.content) ? payload.content : [];
      for (const item of content) {
        if (typeof item?.text === "string" && item.text.includes("<skill>")) {
          observedSkills.push(...skillIdsFromText(item.text));
        }
      }
    }
  }
  return { observedSkills: unique(observedSkills).sort(), compactionCount };
}

function correctionReason(violations, requiredSkills, requiredSections, compactionCount) {
  const instructions = [
    `The Apple workflow final-output contract failed: ${violations.join("; ")}.`,
    "Rewrite only the final answer.",
    "Start with `Routing: orchestrator-led` as the first visible nonempty line.",
    `Use an \`Activated skills:\` block with these fully qualified ids and no \`$\`: ${requiredSkills.join(", ")}.`,
  ];
  if (requiredSections.length > 0) {
    instructions.push(`Preserve this section order: ${requiredSections.join(" -> ")}.`);
  }
  if (compactionCount > 0) {
    instructions.push(`The turn compacted ${compactionCount} time(s); reconstruct the contract from this instruction.`);
  }
  instructions.push("Do not discuss this correction.");
  return instructions.join(" ");
}

export function outputForStop(input) {
  try {
    if (
      input?.hook_event_name !== "Stop"
      || input?.agent_id
      || input?.agent_type
    ) {
      return null;
    }
    const state = readRouteState(input);
    if (!state) return null;
    if (
      state.schemaVersion !== 1
      || state.sessionId !== input.session_id
      || state.turnId !== input.turn_id
    ) {
      deleteRouteState(input);
      return null;
    }
    if (input.stop_hook_active === true || state.enforceFinalContract !== true) {
      deleteRouteState(input);
      return null;
    }

    const message = typeof input.last_assistant_message === "string"
      ? input.last_assistant_message
      : "";
    const activated = parseActivatedSkills(message);
    const trace = inspectTranscriptState(state);
    const requiredSkills = unique([
      TOP_LEVEL_OWNER,
      ...(Array.isArray(state.activatedSkills) ? state.activatedSkills : []),
      ...trace.observedSkills,
    ]).sort();
    const violations = [];

    if (firstNonemptyLine(message) !== "Routing: orchestrator-led") {
      violations.push("the first visible line is not exactly `Routing: orchestrator-led`");
    }
    if (!activated.present) {
      violations.push("`Activated skills` is missing");
    }
    if (!activated.qualified.includes(TOP_LEVEL_OWNER)) {
      violations.push(`top-level owner ${TOP_LEVEL_OWNER} is missing`);
    }
    const missingSkills = requiredSkills.filter((skill) => !activated.qualified.includes(skill));
    if (missingSkills.length > 0) {
      violations.push(`materially activated skills are missing: ${missingSkills.join(", ")}`);
    }
    if (activated.bare.length > 0) {
      violations.push(`bare Apple skill ids are not allowed: ${activated.bare.join(", ")}`);
    }
    if (activated.dollarPrefixed.length > 0) {
      violations.push(`output skill ids must not use $: ${activated.dollarPrefixed.join(", ")}`);
    }
    if (activated.duplicateQualified.length > 0) {
      violations.push(
        `qualified skill ids must appear exactly once: ${activated.duplicateQualified.join(", ")}`,
      );
    }
    if (activated.unknownQualified.length > 0) {
      violations.push(`unknown qualified skill ids: ${activated.unknownQualified.join(", ")}`);
    }
    violations.push(...activated.malformed);

    let requiredSections = [];
    for (const [owner, sections] of LANE_CONTRACTS) {
      if (requiredSkills.includes(owner) || activated.qualified.includes(owner)) {
        requiredSections = sections;
        break;
      }
    }
    if (
      requiredSections.length === 0
      && (requiredSkills.includes(`${PLUGIN_PREFIX}apple-feature-implementation`)
        || activated.qualified.includes(`${PLUGIN_PREFIX}apple-feature-implementation`))
    ) {
      requiredSections = [
        "Routing",
        "Activated skills",
        "Tests added or updated",
        "Validation executed",
        "Branch-diff review status",
      ];
    }
    if (requiredSections.length > 0) {
      const order = validateSectionOrder(message, requiredSections);
      if (order.missing.length > 0) {
        violations.push(`required sections are missing: ${order.missing.join(", ")}`);
      }
      if (order.outOfOrder) {
        violations.push(`section is out of order: ${order.outOfOrder}`);
      }
    }

    if (violations.length === 0) {
      deleteRouteState(input);
      return null;
    }
    return {
      decision: "block",
      reason: correctionReason(
        violations,
        requiredSkills,
        requiredSections,
        trace.compactionCount,
      ),
    };
  } catch {
    // Final-answer enforcement must fail open on internal errors.
    return null;
  }
}

async function readInput() {
  let raw = "";
  for await (const chunk of process.stdin) raw += chunk;
  return JSON.parse(raw);
}

export async function runCli() {
  try {
    const output = outputForStop(await readInput());
    if (output) process.stdout.write(`${JSON.stringify(output)}\n`);
  } catch {
    // Emit nothing so an unavailable validator cannot wedge the host.
  }
}

const invokedPath = process.argv[1] ? pathToFileURL(path.resolve(process.argv[1])).href : null;
if (invokedPath === import.meta.url) await runCli();
