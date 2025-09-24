#!/usr/bin/env node

const path = require("path");
const fs = require("fs");

async function run() {
  const { query } = await import("@anthropic-ai/claude-code");

  const cliPath = path.join(__dirname, "../assets/claude-cli/cli.js");
  if (!fs.existsSync(cliPath)) {
    console.error("Claude CLI not found at", cliPath);
    process.exit(1);
  }

  console.log("Using CLI path:", cliPath);

  const events = [];
  const iterator = query({
    prompt: "Hello from smoke test",
    options: {
      includePartialMessages: false,
      pathToClaudeCodeExecutable: cliPath,
      env: process.env,
    },
  });

  for await (const event of iterator) {
    events.push(event.type);
    if (event.type === "assistant") {
      console.log("Assistant response:", event.content);
      break;
    }
  }

  console.log("Received events:", events.join(", "));
}

run().catch((error) => {
  console.error("Smoke test failed:", error);
  process.exit(1);
});


