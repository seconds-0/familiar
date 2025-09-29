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
REPO_ROOT = _detect_repo_root(Path(__file__).resolve())
BUNDLED_CLI = REPO_ROOT / "assets" / "claude-cli" / "cli.js"


AUTH_MODE_API_KEY = "api_key"
AUTH_MODE_CLAUDE = "claude_ai"

# Default to user's home directory for system-wide access
DEFAULT_WORKSPACE_PATH = Path.home()


@dataclass
class Settings:
    """User-configurable settings persisted between launches."""

    anthropic_api_key: str | None = None
    workspace: str | None = None
    always_allow: dict[str, list[str]] = field(default_factory=dict)
    auth_mode: str = AUTH_MODE_CLAUDE
    claude_session_active: bool = False
    claude_account: str | None = None


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
    """Validate and resolve a workspace path.

    Args:
        path_str: Path string to validate (may contain ~ for home directory)

    Returns:
        Resolved absolute Path object

    Raises:
        ValueError: If path is invalid or inaccessible
        PermissionError: If path exists but isn't readable
    """
    path = Path(path_str).expanduser().resolve()

    # If path doesn't exist, verify we can create it
    if not path.exists():
        try:
            path.mkdir(parents=True, exist_ok=True)
        except (OSError, PermissionError) as e:
            raise ValueError(f"Cannot create workspace directory: {e}") from e

    # Verify path is a directory and readable
    if not path.is_dir():
        raise ValueError(f"Workspace path exists but is not a directory: {path}")

    if not os.access(path, os.R_OK):
        raise PermissionError(f"Workspace directory is not readable: {path}")

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

    response = SettingsResponse(
        has_api_key=settings.anthropic_api_key is not None,
        has_claude_session=settings.claude_session_active,
        claude_account_email=settings.claude_account,
        workspace=settings.workspace,
        always_allow=settings.always_allow,
        default_workspace=str(DEFAULT_WORKSPACE_PATH),
        auth_mode=settings.auth_mode,
    )

    return response.model_dump(by_alias=True)


def register_always_allow(settings: Settings, *, tool: str, path: Path) -> None:
    canonical = str(path)
    rules = settings.always_allow.setdefault(tool, [])
    if canonical not in rules:
        rules.append(canonical)



ensure_cli_environment()
