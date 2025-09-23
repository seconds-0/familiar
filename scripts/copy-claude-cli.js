const fs = require("fs");
const path = require("path");

const CLAUDE_PACKAGE = "@anthropic-ai/claude-code";
const SOURCE_DIR = path.join(process.cwd(), "node_modules", CLAUDE_PACKAGE);
const DEST_DIR = path.join(process.cwd(), "assets", "claude-cli");

function copyRecursive(src, dest) {
  const stat = fs.statSync(src);
  if (stat.isDirectory()) {
    fs.mkdirSync(dest, { recursive: true });
    for (const entry of fs.readdirSync(src)) {
      copyRecursive(path.join(src, entry), path.join(dest, entry));
    }
    return;
  }

  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(src, dest);
}

function main() {
  if (!fs.existsSync(SOURCE_DIR)) {
    throw new Error("Claude Code package not installed. Run npm install before building.");
  }

  if (fs.existsSync(DEST_DIR)) {
    fs.rmSync(DEST_DIR, { recursive: true, force: true });
  }

  copyRecursive(SOURCE_DIR, DEST_DIR);
  console.log(`Copied Claude CLI to ${DEST_DIR}`);
}

main();
