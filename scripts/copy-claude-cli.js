const fs = require("fs");
const path = require("path");

const CLAUDE_PACKAGE = "@anthropic-ai/claude-code";
const DEFAULT_SOURCE_DIR = path.join(process.cwd(), "node_modules", CLAUDE_PACKAGE);
const DEFAULT_DEST_DIR = path.join(process.cwd(), "assets", "claude-cli");

function readPackageVersion(dir) {
  try {
    const pkgPath = path.join(dir, "package.json");
    const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf-8"));
    return pkg.version ?? null;
  } catch {
    return null;
  }
}

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

function copyClaudeCli({
  sourceDir = DEFAULT_SOURCE_DIR,
  destDir = DEFAULT_DEST_DIR,
  log = console.log,
} = {}) {
  if (!fs.existsSync(sourceDir)) {
    throw new Error("Claude Code package not installed. Run npm install before building.");
  }

  const sourceVersion = readPackageVersion(sourceDir);
  const destVersion = readPackageVersion(destDir);

  if (sourceVersion && destVersion && sourceVersion === destVersion) {
    log(`Claude CLI assets already up to date (v${sourceVersion}). Skipping copy.`);
    return { skipped: true, version: sourceVersion };
  }

  if (fs.existsSync(destDir)) {
    fs.rmSync(destDir, { recursive: true, force: true });
  }

  copyRecursive(sourceDir, destDir);
  log(`Copied Claude CLI (v${sourceVersion ?? "unknown"}) to ${destDir}`);
  return { skipped: false, version: sourceVersion ?? undefined };
}

if (require.main === module) {
  copyClaudeCli();
}

module.exports = {
  copyClaudeCli,
  readPackageVersion,
};
