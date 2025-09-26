"""Persistent settings management for the palette sidecar."""

from __future__ import annotations

import json
import os
from dataclasses import asdict, dataclass, field
from pathlib import Path
from shutil import which
from typing import Any


def _detect_repo_root(start: Path) -> Path:
    for candidate in start.parents:
        if (candidate / "assets").exists():
            return candidate
    return start.parents[3]


CONFIG_DIR = Path.home() / ".palette-app"
CONFIG_FILE = CONFIG_DIR / "config.json"
WORKSPACE_MARKER = ".steel-thread-workspace"
DEMO_FILE_NAME = "steel-thread-demo.txt"
REPO_ROOT = _detect_repo_root(Path(__file__).resolve())
BUNDLED_CLI = REPO_ROOT / "assets" / "claude-cli" / "cli.js"


MODEL_CATALOG: dict[str, dict[str, Any]] = {
    "claude-sonnet-4-20250514": {
        "label": "Sonnet 4",
        "input_cost_per_million": 3.0,
        "output_cost_per_million": 15.0,
    },
    "claude-opus-4-1-20250805": {
        "label": "Opus 4.1",
        "input_cost_per_million": 15.0,
        "output_cost_per_million": 75.0,
    },
}

DEFAULT_MODEL = "claude-sonnet-4-20250514"
DEFAULT_WORKSPACE_PATH = Path("/")


@dataclass
class Settings:
    """User-configurable settings persisted between launches."""

    anthropic_api_key: str | None = None
    workspace: str | None = None
    always_allow: dict[str, list[str]] = field(default_factory=dict)
    auto_approve_tools: bool = False
    model: str | None = None


def _serialise(settings: Settings) -> dict[str, Any]:
    data = asdict(settings)
    return {key: value for key, value in data.items() if value is not None}


def load_settings() -> Settings:
    if CONFIG_FILE.exists():
        try:
            payload = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
            payload.pop("exa", None)
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
        marker.write_text("Familiar Steel Thread workspace\n", encoding="utf-8")

    demo_file = path / DEMO_FILE_NAME
    if not demo_file.exists():
        demo_file.write_text(
            "# Steel Thread Notes\n\nThis file is modified by the Familiar Steel Thread demo.\n",
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
    workspace_path = settings.workspace
    demo_file = None
    if workspace_path:
        candidate = Path(workspace_path) / DEMO_FILE_NAME
        if candidate.exists():
            demo_file = str(candidate)
    model_id = settings.model or DEFAULT_MODEL
    return {
        "hasApiKey": settings.anthropic_api_key is not None,
        "workspace": workspace_path,
        "workspaceDemoFile": demo_file,
        "alwaysAllow": settings.always_allow,
        "autoApproveTools": settings.auto_approve_tools,
        "defaultWorkspace": str(DEFAULT_WORKSPACE_PATH),
        "model": model_id,
        "models": [
            {
                "id": key,
                "label": value["label"],
                "inputCostPerMillion": value["input_cost_per_million"],
                "outputCostPerMillion": value["output_cost_per_million"],
            }
            for key, value in MODEL_CATALOG.items()
        ],
    }


def register_always_allow(settings: Settings, *, tool: str, path: Path) -> None:
    canonical = str(path)
    rules = settings.always_allow.setdefault(tool, [])
    if canonical not in rules:
        rules.append(canonical)


ensure_cli_environment()
