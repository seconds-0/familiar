const path = require("path");
const fs = require("fs");
const os = require("os");
const assert = require("assert");

const { copyClaudeCli } = require("../../scripts/copy-claude-cli.js");

async function runQuery(cliPath) {
  const { query } = await import("@anthropic-ai/claude-code");
  const events = [];
  const iterator = query({
    prompt: "hello",
    options: {
      includePartialMessages: false,
      pathToClaudeCodeExecutable: cliPath,
      env: process.env,
    },
  });

  for await (const event of iterator) {
    events.push(event);
    if (event.type === "assistant") {
      break;
    }
  }

  return events;
}

async function testSdkLaunchesCli() {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "claude-e2e-"));
  const sourceDir = path.join(process.cwd(), "node_modules", "@anthropic-ai", "claude-code");
  const destDir = path.join(tmpDir, "assets", "claude-cli");

  copyClaudeCli({ sourceDir, destDir, log: () => {} });
  const cliPath = path.join(destDir, "cli.js");
  const events = await runQuery(cliPath);

  assert.ok(events.length > 0, "Should receive events from SDK");
}

(async () => {
  await testSdkLaunchesCli();
  console.log("E2E tests passed (SDK CLI launch)");
})();
