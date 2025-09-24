"""Persistent settings management for the palette sidecar."""

from __future__ import annotations

import json
import os
from dataclasses import asdict, dataclass
from pathlib import Path
from shutil import which
from typing import Any

CONFIG_DIR = Path.home() / ".palette-app"
CONFIG_FILE = CONFIG_DIR / "config.json"
WORKSPACE_MARKER = ".steel-thread-workspace"
DEMO_FILE_NAME = "steel-thread-demo.txt"
REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_CLI = REPO_ROOT / "assets" / "claude-cli" / "cli.js"


@dataclass
class Settings:
    """User-configurable settings persisted between launches."""

    anthropic_api_key: str | None = None
    workspace: str | None = None


def _serialise(settings: Settings) -> dict[str, Any]:
    data = asdict(settings)
    return {key: value for key, value in data.items() if value is not None}


def load_settings() -> Settings:
    if CONFIG_FILE.exists():
        try:
            payload = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
            return Settings(**payload)
        except Exception:
            return Settings()
    return Settings()


def save_settings(settings: Settings) -> None:
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    CONFIG_FILE.write_text(json.dumps(_serialise(settings), indent=2), encoding="utf-8")


def ensure_workspace(path_str: str) -> Path:
    path = Path(path_str).expanduser().resolve()
    path.mkdir(parents=True, exist_ok=True)

    marker = path / WORKSPACE_MARKER
    if not marker.exists():
        marker.write_text("Palette Steel Thread workspace\n", encoding="utf-8")

    demo_file = path / DEMO_FILE_NAME
    if not demo_file.exists():
        demo_file.write_text(
            "# Steel Thread Notes\n\nThis file is modified by the Palette Steel Thread demo.\n",
            encoding="utf-8",
        )

    return path


def apply_environment(api_key: str | None) -> None:
    if api_key:
        os.environ["ANTHROPIC_API_KEY"] = api_key
    else:
        os.environ.pop("ANTHROPIC_API_KEY", None)

    ensure_cli_environment()


def ensure_cli_environment() -> None:
    if BUNDLED_CLI.exists():
        os.environ.setdefault("CLAUDE_CODE_CLI_PATH", str(BUNDLED_CLI))
        os.environ.setdefault("NODE_PATH", str(BUNDLED_CLI.parent))


def detect_prerequisites() -> dict[str, bool]:
    return {
        "node": which("node") is not None,
        "claude_cli": BUNDLED_CLI.exists(),
    }


def settings_response_payload(settings: Settings) -> dict[str, Any]:
    return {
        "hasApiKey": settings.anthropic_api_key is not None,
        "workspace": settings.workspace,
    }


ensure_cli_environment()
