const path = require("path");
const assert = require("assert");
const fs = require("fs");
const os = require("os");

require("ts-node").register({ transpileOnly: true, project: path.join(process.cwd(), "tsconfig.json") });

// Minimal stub for @raycast/api used by the resolver
const Module = require("module");
const originalResolveFilename = Module._resolveFilename;
Module._resolveFilename = function (request, parent, isMain, options) {
  if (request === "@raycast/api") {
    return path.join(__dirname, "raycast-api-stub.js");
  }
  return originalResolveFilename.call(this, request, parent, isMain, options);
};

const { copyClaudeCli, readPackageVersion } = require("../../scripts/copy-claude-cli.js");
const { resolveClaudeCliPathSync } = require("../../src/utils/claude");

function shouldSkipCopyWhenVersionsMatch() {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "claude-unit-copy-"));
  const sourceDir = path.join(tmpDir, "node_modules", "@anthropic-ai", "claude-code");
  fs.mkdirSync(sourceDir, { recursive: true });
  fs.writeFileSync(path.join(sourceDir, "package.json"), JSON.stringify({ version: "1.0.0" }));

  const destDir = path.join(tmpDir, "assets", "claude-cli");
  fs.mkdirSync(destDir, { recursive: true });
  fs.writeFileSync(path.join(destDir, "package.json"), JSON.stringify({ version: "1.0.0" }));

  const result = copyClaudeCli({ sourceDir, destDir, log: () => {} });
  assert.strictEqual(result.skipped, true, "Copy should skip when versions match");
  assert.strictEqual(readPackageVersion(destDir), "1.0.0", "Destination version remains the same");
}

function shouldThrowWhenPackageMissing() {
  assert.throws(() => copyClaudeCli({ sourceDir: "/invalid/path" }), /Claude Code package not installed/);
}

function shouldBuildCandidates() {
  const candidate = resolveClaudeCliPathSync({ debug: () => {} });
  assert.ok(typeof candidate === "string" || candidate === undefined, "Resolver should produce string or undefined");
}

function runUnitTests() {
  shouldSkipCopyWhenVersionsMatch();
  shouldThrowWhenPackageMissing();
  shouldBuildCandidates();
  console.log("Unit tests passed");
}

runUnitTests();
