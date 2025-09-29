"""Unit tests for session_config.py module."""

import pytest
from pathlib import Path
from palette_sidecar.session_config import SessionConfig, SessionConfigValidator
from palette_sidecar.config import AUTH_MODE_API_KEY, AUTH_MODE_CLAUDE


class TestSessionConfig:
    """Tests for SessionConfig dataclass."""

    def test_default_values(self):
        """SessionConfig should have sensible defaults."""
        config = SessionConfig()
        assert config.api_key is None
        assert config.workspace is None
        assert config.always_allow == {}
        assert config.auth_mode == AUTH_MODE_CLAUDE
        assert config.claude_session_active is False
        assert config.claude_account is None

    def test_with_custom_values(self, tmp_path):
        """SessionConfig should accept custom values."""
        workspace = tmp_path / "workspace"
        config = SessionConfig(
            api_key="test-key-123",
            workspace=workspace,
            always_allow={"Write": ["/path/to/file"]},
            auth_mode=AUTH_MODE_API_KEY,
            claude_session_active=True,
            claude_account="user@example.com"
        )
        assert config.api_key == "test-key-123"
        assert config.workspace == workspace
        assert config.always_allow == {"Write": ["/path/to/file"]}
        assert config.auth_mode == AUTH_MODE_API_KEY
        assert config.claude_session_active is True
        assert config.claude_account == "user@example.com"


class TestSessionConfigValidatorApiKeyMode:
    """Tests for SessionConfigValidator with API key authentication."""

    def test_ready_with_api_key_and_workspace(self, tmp_path):
        """Should be ready when both API key and workspace are set."""
        config = SessionConfig(
            api_key="test-key",
            workspace=tmp_path,
            auth_mode=AUTH_MODE_API_KEY
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is True

    def test_not_ready_missing_api_key(self, tmp_path):
        """Should not be ready when API key is missing."""
        config = SessionConfig(
            workspace=tmp_path,
            auth_mode=AUTH_MODE_API_KEY
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is False
        assert validator.configuration_error == "API key missing."

    def test_not_ready_missing_workspace_api_key_mode(self):
        """Should not be ready when workspace is missing."""
        config = SessionConfig(
            api_key="test-key",
            auth_mode=AUTH_MODE_API_KEY
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is False
        assert validator.configuration_error == "Workspace not configured."


class TestSessionConfigValidatorClaudeMode:
    """Tests for SessionConfigValidator with Claude.ai authentication."""

    def test_ready_with_active_session_and_workspace(self, tmp_path):
        """Should be ready when Claude session is active and workspace is set."""
        config = SessionConfig(
            workspace=tmp_path,
            auth_mode=AUTH_MODE_CLAUDE,
            claude_session_active=True
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is True

    def test_not_ready_inactive_session(self, tmp_path):
        """Should not be ready when Claude session is inactive."""
        config = SessionConfig(
            workspace=tmp_path,
            auth_mode=AUTH_MODE_CLAUDE,
            claude_session_active=False
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is False
        assert validator.configuration_error == "Claude.ai login required."

    def test_not_ready_missing_workspace_claude_mode(self):
        """Should not be ready when workspace is missing."""
        config = SessionConfig(
            auth_mode=AUTH_MODE_CLAUDE,
            claude_session_active=True
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is False
        assert validator.configuration_error == "Workspace not configured."


class TestSessionConfigValidatorUnknownMode:
    """Tests for SessionConfigValidator with unknown authentication mode."""

    def test_fallback_to_api_key_for_unknown_mode(self, tmp_path):
        """Unknown auth mode should fall back to requiring API key."""
        config = SessionConfig(
            api_key="test-key",
            workspace=tmp_path,
            auth_mode="unknown_mode"
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is True

    def test_not_ready_unknown_mode_without_api_key(self, tmp_path):
        """Unknown auth mode without API key should not be ready."""
        config = SessionConfig(
            workspace=tmp_path,
            auth_mode="unknown_mode"
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is False
        assert validator.configuration_error == "Authentication configuration incomplete."


class TestSessionConfigValidatorEdgeCases:
    """Edge case tests for SessionConfigValidator."""

    def test_workspace_takes_priority_in_error_message(self):
        """Workspace error should be shown before auth errors."""
        config = SessionConfig(
            api_key="test-key",
            auth_mode=AUTH_MODE_API_KEY
        )
        validator = SessionConfigValidator(config)
        assert validator.configuration_error == "Workspace not configured."

    def test_api_key_with_claude_mode_not_sufficient(self, tmp_path):
        """Having API key shouldn't satisfy Claude mode requirements."""
        config = SessionConfig(
            api_key="test-key",
            workspace=tmp_path,
            auth_mode=AUTH_MODE_CLAUDE,
            claude_session_active=False
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is False

    def test_active_claude_session_with_api_key_mode_not_sufficient(self, tmp_path):
        """Having active Claude session shouldn't satisfy API key mode."""
        config = SessionConfig(
            workspace=tmp_path,
            auth_mode=AUTH_MODE_API_KEY,
            claude_session_active=True
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is False
        assert validator.configuration_error == "API key missing."

    def test_both_auth_methods_with_api_key_mode(self, tmp_path):
        """Having both auth methods with API key mode should be ready."""
        config = SessionConfig(
            api_key="test-key",
            workspace=tmp_path,
            auth_mode=AUTH_MODE_API_KEY,
            claude_session_active=True
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is True

    def test_both_auth_methods_with_claude_mode(self, tmp_path):
        """Having both auth methods with Claude mode should be ready."""
        config = SessionConfig(
            api_key="test-key",
            workspace=tmp_path,
            auth_mode=AUTH_MODE_CLAUDE,
            claude_session_active=True
        )
        validator = SessionConfigValidator(config)
        assert validator.is_ready is True