"""Session configuration management for Claude SDK client."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

from .config import AUTH_MODE_API_KEY, AUTH_MODE_CLAUDE


@dataclass
class SessionConfig:
    """Configuration for a Claude SDK session.

    Attributes:
        api_key: Anthropic API key (for api_key auth mode)
        workspace: Working directory for file operations
        always_allow: Dict mapping tool names to auto-approved file paths
        auth_mode: Authentication mode ('claude_ai' or 'api_key')
        claude_session_active: Whether Claude.ai session is authenticated
        claude_account: Email address of connected Claude.ai account
    """
    api_key: str | None = None
    workspace: Path | None = None
    always_allow: dict[str, list[str]] = field(default_factory=dict)
    auth_mode: str = AUTH_MODE_CLAUDE
    claude_session_active: bool = False
    claude_account: str | None = None


class SessionConfigValidator:
    """Validates session configuration and provides readiness checks.

    Handles authentication mode-specific validation logic and provides
    detailed error messages for misconfigured sessions.
    """

    def __init__(self, config: SessionConfig):
        """Initialize validator with a configuration.

        Args:
            config: Session configuration to validate
        """
        self._config = config

    @property
    def is_ready(self) -> bool:
        """Check if the session is properly configured and ready to use.

        Returns:
            True if all required configuration is present for the current auth mode
        """
        if self._config.workspace is None:
            return False

        if self._config.auth_mode == AUTH_MODE_API_KEY:
            return self._config.api_key is not None

        if self._config.auth_mode == AUTH_MODE_CLAUDE:
            return self._config.claude_session_active

        # Fallback to require API key for unknown modes
        return self._config.api_key is not None

    @property
    def configuration_error(self) -> str:
        """Get a human-readable error message explaining configuration issues.

        Returns:
            Error message describing what's missing or misconfigured
        """
        if self._config.workspace is None:
            return "Workspace not configured."

        if self._config.auth_mode == AUTH_MODE_API_KEY:
            return "API key missing."

        if self._config.auth_mode == AUTH_MODE_CLAUDE:
            return "Claude.ai login required."

        return "Authentication configuration incomplete."