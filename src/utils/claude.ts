import { environment } from "@raycast/api";
import { existsSync } from "fs";
import path from "path";

const CLAUDE_PACKAGE = "@anthropic-ai/claude-code";
const CLI_RELATIVE_PATH = ["cli.js"];
const ASSET_SUBDIR = ["claude-cli"];

function joinSegments(base: string, segments: string[]): string {
  return path.join(base, ...segments);
}

function buildCandidatePaths(): string[] {
  const candidates: string[] = [];

  // Packaged assets shipped with the Raycast extension
  if (environment.assetsPath) {
    candidates.push(joinSegments(environment.assetsPath, [...ASSET_SUBDIR, ...CLI_RELATIVE_PATH]));
  }

  if (environment.supportPath) {
    candidates.push(joinSegments(environment.supportPath, [...ASSET_SUBDIR, ...CLI_RELATIVE_PATH]));
  }

  // Development: prefer node_modules next to the extension
  candidates.push(joinSegments(process.cwd(), ["node_modules", CLAUDE_PACKAGE, ...CLI_RELATIVE_PATH]));

  return candidates;
}

export function resolveClaudeCliPath(): string {
  try {
    const resolved = require.resolve(`${CLAUDE_PACKAGE}/cli.js`);
    if (resolved) {
      return resolved;
    }
  } catch {
    // Ignore resolution failure, proceed to manual lookup
  }

  for (const candidate of buildCandidatePaths()) {
    if (existsSync(candidate)) {
      return candidate;
    }
  }

  throw new Error("Claude Code CLI executable could not be located. Ensure dependencies are installed or rebuild the extension.");
}
