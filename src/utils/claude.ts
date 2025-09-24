import { environment } from "@raycast/api";
import { existsSync } from "fs";
import path from "path";

type Logger = (message: string, detail?: unknown) => void;

const CLAUDE_PACKAGE = "@anthropic-ai/claude-code";
const CLI_RELATIVE_PATH = ["cli.js"];
const ASSET_SUBDIR = ["claude-cli"];
const RESOLUTION_RETRIES = 3;
const RESOLUTION_DELAY_MS = 300;

type ResolveOptions = {
  retries?: number;
  delayMs?: number;
  debug?: Logger;
  assetsPathOverride?: string;
  supportPathOverride?: string;
};

function joinSegments(base: string | undefined, segments: string[]): string | null {
  if (!base) {
    return null;
  }
  return path.join(base, ...segments);
}

function buildCandidatePaths(options: ResolveOptions): string[] {
  const { assetsPathOverride, supportPathOverride, debug } = options;
  const candidates = new Set<string>();

  const assetCandidate = joinSegments(assetsPathOverride ?? environment.assetsPath, [...ASSET_SUBDIR, ...CLI_RELATIVE_PATH]);
  if (assetCandidate) {
    candidates.add(assetCandidate);
  }

  const supportCandidate = joinSegments(supportPathOverride ?? environment.supportPath, [...ASSET_SUBDIR, ...CLI_RELATIVE_PATH]);
  if (supportCandidate) {
    candidates.add(supportCandidate);
  }

  const devCandidate = joinSegments(process.cwd(), ["node_modules", CLAUDE_PACKAGE, ...CLI_RELATIVE_PATH]);
  if (devCandidate) {
    candidates.add(devCandidate);
  }

  debug?.("CLI candidate paths", Array.from(candidates));
  return Array.from(candidates);
}

async function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function checkCandidates(candidates: string[], attempt: number, debug?: Logger): Promise<string | undefined> {
  for (const candidate of candidates) {
    if (existsSync(candidate)) {
      debug?.(`Claude CLI located at ${candidate} (attempt ${attempt})`);
      return candidate;
    }
  }
  return undefined;
}

export async function resolveClaudeCliPath(options: ResolveOptions = {}): Promise<string> {
  const { retries = RESOLUTION_RETRIES, delayMs = RESOLUTION_DELAY_MS, debug } = options;

  try {
    const resolved = require.resolve(`${CLAUDE_PACKAGE}/cli.js`);
    if (resolved) {
      debug?.(`require.resolve located Claude CLI at ${resolved}`);
      return resolved;
    }
  } catch (error) {
    debug?.("require.resolve failed", error);
  }

  const candidates = buildCandidatePaths(options);

  for (let attempt = 1; attempt <= retries + 1; attempt += 1) {
    const found = await checkCandidates(candidates, attempt, debug);
    if (found) {
      return found;
    }

    if (attempt <= retries) {
      debug?.(`Retrying Claude CLI resolution in ${delayMs}ms (attempt ${attempt})`);
      await delay(delayMs);
    }
  }

  throw new Error("Claude Code CLI executable could not be located. Ensure the extension assets are copied before starting Raycast.");
}

export function resolveClaudeCliPathSync(options: Omit<ResolveOptions, "retries" | "delayMs"> = {}): string | undefined {
  const { debug } = options;

  try {
    const resolved = require.resolve(`${CLAUDE_PACKAGE}/cli.js`);
    if (resolved) {
      debug?.(`require.resolve located Claude CLI at ${resolved}`);
      return resolved;
    }
  } catch (error) {
    debug?.("require.resolve failed", error);
  }

  const candidates = buildCandidatePaths(options);
  for (const candidate of candidates) {
    if (existsSync(candidate)) {
      debug?.(`Claude CLI located at ${candidate}`);
      return candidate;
    }
  }

  return undefined;
}
