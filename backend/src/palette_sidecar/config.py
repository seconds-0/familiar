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


AUTH_MODE_API_KEY = "api_key"
AUTH_MODE_CLAUDE = "claude_ai"

DEFAULT_WORKSPACE_PATH = Path("/")

# Context Engineering Limits
# Reference: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
# Documentation: docs/reference/claude-agent-sdk.md:Context-Engineering-Best-Practices

MAX_FILE_PREVIEW_SIZE = 1000      # characters - truncate file previews
MAX_SEARCH_RESULTS = 20           # files - limit search result count
MAX_DIRECTORY_LISTING = 50        # entries - prevent directory explosion
MAX_TOOL_OUTPUT_LENGTH = 5000     # characters - hard limit on tool responses
MAX_ERROR_MESSAGE_LENGTH = 500    # characters - truncate stack traces

# Token budgets (passed to Claude Agent SDK)
DEFAULT_MAX_TOKENS = 4096         # per response
DEFAULT_MAX_TURNS = 10            # conversation depth limit

# Zero State Configuration
MAX_SUGGESTION_HISTORY = 12       # Keep last 12 suggestions for deduplication (~3 sessions)


@dataclass
class Settings:
    """User-configurable settings persisted between launches."""

    anthropic_api_key: str | None = None
    workspace: str | None = None
    always_allow: dict[str, list[str]] = field(default_factory=dict)
    bypass_permissions: bool = True
    auth_mode: str = AUTH_MODE_CLAUDE
    claude_session_active: bool = False
    claude_account: str | None = None
    suggestion_history: list[str] = field(default_factory=list)


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


def apply_auth_environment(settings: Settings) -> None:
    """Apply environment variables based on the selected auth mode."""

    if settings.auth_mode == AUTH_MODE_API_KEY:
        apply_environment(settings.anthropic_api_key)
    else:
        apply_environment(None)


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
    """Build settings response payload for API endpoints.

    This function is retained for backwards compatibility but now uses
    the Pydantic SettingsResponse model for serialization.
    """
    from .models import SettingsResponse

    workspace_path = settings.workspace
    demo_file = None
    if workspace_path:
        candidate = Path(workspace_path) / DEMO_FILE_NAME
        if candidate.exists():
            demo_file = str(candidate)

    response = SettingsResponse(
        has_api_key=settings.anthropic_api_key is not None,
        has_claude_session=settings.claude_session_active,
        claude_account_email=settings.claude_account,
        workspace=workspace_path,
        workspace_demo_file=demo_file,
        always_allow=settings.always_allow,
        default_workspace=str(DEFAULT_WORKSPACE_PATH),
        auth_mode=settings.auth_mode,
        bypass_permissions=settings.bypass_permissions,
    )

    return response.model_dump(by_alias=True)


def register_always_allow(settings: Settings, *, tool: str, path: Path) -> None:
    canonical = str(path)
    rules = settings.always_allow.setdefault(tool, [])
    if canonical not in rules:
        rules.append(canonical)



ensure_cli_environment()
