const path = require("path");
const fs = require("fs");
const assert = require("assert");
const os = require("os");

require("ts-node").register({ transpileOnly: true, project: path.join(process.cwd(), "tsconfig.json") });

// Stub @raycast/api for resolver
const Module = require("module");
const originalResolveFilename = Module._resolveFilename;
Module._resolveFilename = function (request, parent, isMain, options) {
  if (request === "@raycast/api") {
    return path.join(__dirname, "../unit/raycast-api-stub.js");
  }
  return originalResolveFilename.call(this, request, parent, isMain, options);
};

const { copyClaudeCli } = require("../../scripts/copy-claude-cli.js");
const { resolveClaudeCliPathSync } = require("../../src/utils/claude");

function createFakeCliStructure(tmpDir) {
  const sourceDir = path.join(tmpDir, "node_modules", "@anthropic-ai", "claude-code");
  fs.mkdirSync(sourceDir, { recursive: true });
  fs.writeFileSync(path.join(sourceDir, "package.json"), JSON.stringify({ version: "9.9.9" }));
  const cliPath = path.join(sourceDir, "cli.js");
  fs.writeFileSync(cliPath, "#!/usr/bin/env node\nconsole.log('fake cli');");
  fs.chmodSync(cliPath, 0o755);
  return sourceDir;
}

function testCopyAndResolve() {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "claude-integration-"));
  const sourceDir = createFakeCliStructure(tmpDir);
  const destDir = path.join(tmpDir, "assets", "claude-cli");

  copyClaudeCli({ sourceDir, destDir, log: () => {} });

  process.env.RAYCAST_ASSETS_PATH = path.join(destDir, "..");
  process.env.RAYCAST_SUPPORT_PATH = path.join(destDir, "..");

  const resolved = resolveClaudeCliPathSync({ debug: () => {} });

  assert.ok(resolved, "Resolver should find CLI after copy");
  assert.ok(fs.existsSync(resolved), "Resolved path should exist");
}

function runIntegrationTests() {
  testCopyAndResolve();
  console.log("Integration tests passed");
}

runIntegrationTests();
