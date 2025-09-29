"""Tool permission management and context tracking for Claude SDK interactions."""

from __future__ import annotations

import difflib
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from uuid import uuid4


@dataclass
class ToolContext:
    """Context information for a tool execution request.

    Attributes:
        path: Canonical absolute path to the file (if applicable)
        relative_path: Path relative to workspace root
        input: Tool input parameters
        tool: Name of the tool being executed
        diff: Unified diff preview for Write operations (if available)
    """
    path: str | None
    relative_path: str | None
    input: dict[str, Any]
    tool: str
    diff: str | None


class ToolManager:
    """Manages tool permissions, path validation, and context tracking.

    Handles:
    - Path canonicalization and workspace boundary enforcement
    - Diff generation for file write operations
    - Auto-allow rules for previously approved paths
    - Permission decision formatting for Claude SDK hooks
    """

    def __init__(self, workspace_root: Path | None = None):
        """Initialize tool manager.

        Args:
            workspace_root: Root directory for workspace boundary enforcement
        """
        self._workspace_root = workspace_root
        self._allow_rules: dict[str, set[str]] = {}

    def set_workspace(self, workspace_root: Path | None) -> None:
        """Update the workspace root directory."""
        self._workspace_root = workspace_root

    def configure_allow_rules(self, always_allow: dict[str, list[str]]) -> None:
        """Configure auto-allow rules from settings.

        Args:
            always_allow: Dict mapping tool names to lists of auto-approved paths
        """
        self._allow_rules = {
            tool: {str(path) for path in paths}
            for tool, paths in always_allow.items()
        }

    def canonicalise_tool_path(
        self, raw_path: str | None
    ) -> tuple[Path | None, str | None]:
        """Resolve a tool path to absolute and relative forms within the workspace.

        Args:
            raw_path: Path provided by tool (may be relative or absolute)

        Returns:
            Tuple of (canonical_path, relative_path)
            Returns (None, None) if the path is outside the workspace boundary.
        """
        if not raw_path or not self._workspace_root:
            return None, None

        # Convert to absolute path, relative to workspace if needed
        path = Path(raw_path)
        if not path.is_absolute():
            path = self._workspace_root / path

        # Resolve symlinks and ensure it's within workspace
        try:
            resolved = path.resolve()
            relative = resolved.relative_to(self._workspace_root)
            return resolved, str(relative)
        except (ValueError, OSError):
            # Path is outside workspace or doesn't exist
            return None, None

    def render_diff(
        self,
        canonical_path: Path | None,
        relative_path: str | None,
        tool_input: dict[str, Any],
    ) -> str | None:
        """Generate a unified diff preview for Write operations.

        Args:
            canonical_path: Absolute path to the file
            relative_path: Workspace-relative path for display
            tool_input: Tool parameters containing 'content' field

        Returns:
            Unified diff string, or None if diff cannot be generated
        """
        if canonical_path is None:
            return None
        content = tool_input.get("content")
        if not isinstance(content, str):
            return None

        try:
            before_text = canonical_path.read_text(encoding="utf-8")
        except FileNotFoundError:
            before_text = ""
        except OSError:
            return None

        before_lines = before_text.splitlines()
        after_lines = content.splitlines()
        from_label = f"a/{relative_path or canonical_path.name}"
        to_label = f"b/{relative_path or canonical_path.name}"
        diff_lines = list(
            difflib.unified_diff(
                before_lines,
                after_lines,
                fromfile=from_label,
                tofile=to_label,
                lineterm="",
                n=3,  # Limit context lines to prevent large diffs
            )
        )
        if not diff_lines:
            return None

        max_lines = 200
        if len(diff_lines) > max_lines:
            diff_lines = diff_lines[:max_lines]
            diff_lines.append("... diff truncated ...")

        return "\n".join(diff_lines)

    def should_auto_allow(self, tool_name: str, canonical_path: Path | None) -> bool:
        """Check if a tool + path combination should be auto-approved.

        Args:
            tool_name: Name of the tool being executed
            canonical_path: Absolute path to the target file

        Returns:
            True if this combination was previously approved with 'remember' flag
        """
        if canonical_path is None:
            return False
        allowed = self._allow_rules.get(tool_name)
        if not allowed:
            return False
        return str(canonical_path) in allowed

    def record_auto_allow(self, tool_name: str, canonical_path: Path) -> None:
        """Record a tool + path combination for future auto-approval.

        Args:
            tool_name: Name of the tool being executed
            canonical_path: Absolute path to the target file
        """
        rules = self._allow_rules.setdefault(tool_name, set())
        rules.add(str(canonical_path))

    @staticmethod
    def create_allow_decision() -> dict[str, Any]:
        """Create a permission decision to allow tool execution.

        Returns:
            Decision dict formatted for Claude SDK hook response
        """
        return {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
                "permissionDecisionReason": "User approved",
            }
        }

    @staticmethod
    def create_deny_decision(*, reason: str) -> dict[str, Any]:
        """Create a permission decision to deny tool execution.

        Args:
            reason: Human-readable explanation for denial

        Returns:
            Decision dict formatted for Claude SDK hook response
        """
        return {
            "decision": "block",
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            },
        }

    @staticmethod
    def context_snapshot(context: ToolContext | None) -> dict[str, Any]:
        """Serialize tool context for event emission.

        Args:
            context: Tool context to serialize, or None

        Returns:
            Dict representation suitable for JSON serialization
        """
        if context is None:
            return {}
        return {
            "path": context.path,
            "relativePath": context.relative_path,
            "tool": context.tool,
            "diff": context.diff,
            "input": context.input,
        }

    @staticmethod
    def generate_request_id(tool_use_id: str | None) -> str:
        """Generate a unique request ID for permission tracking.

        Args:
            tool_use_id: SDK-provided tool use ID, or None

        Returns:
            Request ID (uses tool_use_id if provided, otherwise generates UUID)
        """
        return tool_use_id or str(uuid4())