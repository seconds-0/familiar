"""Unit tests for tool_manager.py module."""

import pytest
from pathlib import Path
from palette_sidecar.tool_manager import ToolManager, ToolContext


@pytest.fixture
def temp_workspace(tmp_path):
    """Create a temporary workspace directory."""
    workspace = tmp_path / "workspace"
    workspace.mkdir()
    return workspace


@pytest.fixture
def tool_manager(temp_workspace):
    """Create a ToolManager with a temporary workspace."""
    return ToolManager(workspace_root=temp_workspace)


class TestCanonicaliseToolPath:
    """Tests for canonicalise_tool_path method."""

    def test_relative_path_resolved_to_workspace(self, tool_manager, temp_workspace):
        """Relative paths should be resolved relative to workspace root."""
        canonical, relative = tool_manager.canonicalise_tool_path("foo/bar.txt")
        assert canonical == temp_workspace / "foo/bar.txt"
        assert relative == "foo/bar.txt"

    def test_absolute_path_within_workspace(self, tool_manager, temp_workspace):
        """Absolute paths within workspace should be accepted."""
        test_file = temp_workspace / "test.txt"
        test_file.write_text("content")

        canonical, relative = tool_manager.canonicalise_tool_path(str(test_file))
        assert canonical == test_file
        assert relative == "test.txt"

    def test_absolute_path_outside_workspace(self, tool_manager, tmp_path):
        """Absolute paths outside workspace should be rejected."""
        outside_file = tmp_path / "outside.txt"
        canonical, relative = tool_manager.canonicalise_tool_path(str(outside_file))
        assert canonical is None
        assert relative is None

    def test_none_path_returns_none(self, tool_manager):
        """None path should return (None, None)."""
        canonical, relative = tool_manager.canonicalise_tool_path(None)
        assert canonical is None
        assert relative is None

    def test_empty_string_returns_none(self, tool_manager):
        """Empty string path should return (None, None)."""
        canonical, relative = tool_manager.canonicalise_tool_path("")
        assert canonical is None
        assert relative is None

    def test_no_workspace_root_returns_none(self):
        """Without workspace root, should return (None, None)."""
        manager = ToolManager(workspace_root=None)
        canonical, relative = manager.canonicalise_tool_path("foo/bar.txt")
        assert canonical is None
        assert relative is None

    def test_nested_path(self, tool_manager, temp_workspace):
        """Nested relative paths should be resolved correctly."""
        canonical, relative = tool_manager.canonicalise_tool_path("a/b/c/d.txt")
        assert canonical == temp_workspace / "a/b/c/d.txt"
        assert relative == "a/b/c/d.txt"

    def test_parent_directory_escape_attempt(self, tool_manager, temp_workspace):
        """Attempting to escape workspace via ../ should be caught."""
        # Try to escape workspace
        canonical, relative = tool_manager.canonicalise_tool_path("../outside.txt")
        assert canonical is None
        assert relative is None


class TestRenderDiff:
    """Tests for render_diff method."""

    def test_diff_for_new_file(self, tool_manager, temp_workspace):
        """Diff for non-existent file should show all lines as additions."""
        new_file = temp_workspace / "new.txt"
        canonical, relative = tool_manager.canonicalise_tool_path("new.txt")

        tool_input = {"content": "line1\nline2\nline3"}
        diff = tool_manager.render_diff(canonical, relative, tool_input)

        assert diff is not None
        assert "+line1" in diff
        assert "+line2" in diff
        assert "+line3" in diff
        assert "a/new.txt" in diff
        assert "b/new.txt" in diff

    def test_diff_for_modified_file(self, tool_manager, temp_workspace):
        """Diff for existing file should show changes."""
        existing_file = temp_workspace / "existing.txt"
        existing_file.write_text("old line 1\nold line 2\nold line 3")
        canonical, relative = tool_manager.canonicalise_tool_path("existing.txt")

        tool_input = {"content": "old line 1\nnew line 2\nold line 3"}
        diff = tool_manager.render_diff(canonical, relative, tool_input)

        assert diff is not None
        assert "-old line 2" in diff
        assert "+new line 2" in diff

    def test_diff_with_no_changes(self, tool_manager, temp_workspace):
        """Diff for unchanged file should return None."""
        unchanged_file = temp_workspace / "unchanged.txt"
        content = "line1\nline2\nline3"
        unchanged_file.write_text(content)
        canonical, relative = tool_manager.canonicalise_tool_path("unchanged.txt")

        tool_input = {"content": content}
        diff = tool_manager.render_diff(canonical, relative, tool_input)

        assert diff is None

    def test_diff_none_canonical_path(self, tool_manager):
        """Diff with None canonical path should return None."""
        tool_input = {"content": "some content"}
        diff = tool_manager.render_diff(None, None, tool_input)
        assert diff is None

    def test_diff_missing_content_field(self, tool_manager, temp_workspace):
        """Diff with missing content field should return None."""
        canonical, relative = tool_manager.canonicalise_tool_path("test.txt")
        tool_input = {}
        diff = tool_manager.render_diff(canonical, relative, tool_input)
        assert diff is None

    def test_diff_non_string_content(self, tool_manager, temp_workspace):
        """Diff with non-string content should return None."""
        canonical, relative = tool_manager.canonicalise_tool_path("test.txt")
        tool_input = {"content": 12345}
        diff = tool_manager.render_diff(canonical, relative, tool_input)
        assert diff is None

    def test_diff_truncation_for_large_files(self, tool_manager, temp_workspace):
        """Diffs exceeding 200 lines should be truncated."""
        large_file = temp_workspace / "large.txt"
        # Create a file with many lines
        old_content = "\n".join(f"old line {i}" for i in range(300))
        new_content = "\n".join(f"new line {i}" for i in range(300))
        large_file.write_text(old_content)
        canonical, relative = tool_manager.canonicalise_tool_path("large.txt")

        tool_input = {"content": new_content}
        diff = tool_manager.render_diff(canonical, relative, tool_input)

        assert diff is not None
        assert "... diff truncated ..." in diff
        # Count lines in diff
        diff_lines = diff.split("\n")
        assert len(diff_lines) <= 201  # 200 + truncation message


class TestAutoAllowRules:
    """Tests for auto-allow rule management."""

    def test_should_auto_allow_with_matching_rule(self, tool_manager, temp_workspace):
        """Auto-allow should return True for paths in allow rules."""
        test_file = temp_workspace / "allowed.txt"
        test_file.write_text("content")

        # Configure allow rules
        tool_manager.configure_allow_rules({
            "Write": [str(test_file)]
        })

        assert tool_manager.should_auto_allow("Write", test_file) is True

    def test_should_auto_allow_without_matching_rule(self, tool_manager, temp_workspace):
        """Auto-allow should return False for paths not in allow rules."""
        test_file = temp_workspace / "not_allowed.txt"
        assert tool_manager.should_auto_allow("Write", test_file) is False

    def test_should_auto_allow_none_path(self, tool_manager):
        """Auto-allow should return False for None path."""
        tool_manager.configure_allow_rules({"Write": ["/some/path"]})
        assert tool_manager.should_auto_allow("Write", None) is False

    def test_should_auto_allow_unknown_tool(self, tool_manager, temp_workspace):
        """Auto-allow should return False for unknown tools."""
        test_file = temp_workspace / "test.txt"
        tool_manager.configure_allow_rules({"Write": [str(test_file)]})
        assert tool_manager.should_auto_allow("Read", test_file) is False

    def test_record_auto_allow(self, tool_manager, temp_workspace):
        """Recording auto-allow should add path to rules."""
        test_file = temp_workspace / "test.txt"

        # Initially not allowed
        assert tool_manager.should_auto_allow("Write", test_file) is False

        # Record the rule
        tool_manager.record_auto_allow("Write", test_file)

        # Now should be allowed
        assert tool_manager.should_auto_allow("Write", test_file) is True

    def test_record_auto_allow_multiple_paths(self, tool_manager, temp_workspace):
        """Recording multiple paths should work correctly."""
        file1 = temp_workspace / "file1.txt"
        file2 = temp_workspace / "file2.txt"

        tool_manager.record_auto_allow("Write", file1)
        tool_manager.record_auto_allow("Write", file2)

        assert tool_manager.should_auto_allow("Write", file1) is True
        assert tool_manager.should_auto_allow("Write", file2) is True

    def test_configure_allow_rules_overwrites_existing(self, tool_manager, temp_workspace):
        """Configuring allow rules should replace existing rules."""
        file1 = temp_workspace / "file1.txt"
        file2 = temp_workspace / "file2.txt"

        # Configure initial rules
        tool_manager.configure_allow_rules({"Write": [str(file1)]})
        assert tool_manager.should_auto_allow("Write", file1) is True

        # Reconfigure with different rules
        tool_manager.configure_allow_rules({"Write": [str(file2)]})
        assert tool_manager.should_auto_allow("Write", file1) is False
        assert tool_manager.should_auto_allow("Write", file2) is True


class TestWorkspaceManagement:
    """Tests for workspace management."""

    def test_set_workspace(self, tool_manager, tmp_path):
        """Setting workspace should update path resolution."""
        new_workspace = tmp_path / "new_workspace"
        new_workspace.mkdir()

        tool_manager.set_workspace(new_workspace)

        canonical, relative = tool_manager.canonicalise_tool_path("test.txt")
        assert canonical == new_workspace / "test.txt"


class TestStaticMethods:
    """Tests for static helper methods."""

    def test_create_allow_decision(self):
        """Allow decision should have correct structure."""
        decision = ToolManager.create_allow_decision()
        assert decision["hookSpecificOutput"]["hookEventName"] == "PreToolUse"
        assert decision["hookSpecificOutput"]["permissionDecision"] == "allow"
        assert decision["hookSpecificOutput"]["permissionDecisionReason"] == "User approved"

    def test_create_deny_decision(self):
        """Deny decision should include reason."""
        reason = "Path outside workspace"
        decision = ToolManager.create_deny_decision(reason=reason)
        assert decision["decision"] == "block"
        assert decision["hookSpecificOutput"]["hookEventName"] == "PreToolUse"
        assert decision["hookSpecificOutput"]["permissionDecision"] == "deny"
        assert decision["hookSpecificOutput"]["permissionDecisionReason"] == reason

    def test_context_snapshot_with_context(self):
        """Context snapshot should serialize all fields."""
        context = ToolContext(
            path="/abs/path/to/file.txt",
            relative_path="file.txt",
            input={"content": "test"},
            tool="Write",
            diff="some diff"
        )
        snapshot = ToolManager.context_snapshot(context)
        assert snapshot["path"] == "/abs/path/to/file.txt"
        assert snapshot["relativePath"] == "file.txt"
        assert snapshot["tool"] == "Write"
        assert snapshot["diff"] == "some diff"
        assert snapshot["input"] == {"content": "test"}

    def test_context_snapshot_with_none(self):
        """Context snapshot with None should return empty dict."""
        snapshot = ToolManager.context_snapshot(None)
        assert snapshot == {}

    def test_generate_request_id_with_tool_use_id(self):
        """Request ID should use tool_use_id when provided."""
        tool_use_id = "test-id-123"
        request_id = ToolManager.generate_request_id(tool_use_id)
        assert request_id == tool_use_id

    def test_generate_request_id_without_tool_use_id(self):
        """Request ID should generate UUID when tool_use_id is None."""
        request_id = ToolManager.generate_request_id(None)
        assert request_id is not None
        assert len(request_id) > 0
        # UUID format check
        assert "-" in request_id