"""Context engineering utilities for managing LLM token budgets.

This module provides helper functions for implementing metadata-first response
patterns and enforcing context budgets throughout the Claude Agent SDK integration.

Reference: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
Documentation: docs/reference/claude-agent-sdk.md:Context-Engineering-Best-Practices
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

from ..config import (
    MAX_DIRECTORY_LISTING,
    MAX_ERROR_MESSAGE_LENGTH,
    MAX_FILE_PREVIEW_SIZE,
    MAX_SEARCH_RESULTS,
    MAX_TOOL_OUTPUT_LENGTH,
)


def truncate_with_note(
    content: str,
    limit: int = MAX_FILE_PREVIEW_SIZE,
    note_template: str = "\n\n... [{remaining:,} more characters]\nUse read_file() for full content",
) -> str:
    """Truncate content with an expansion affordance note.

    Args:
        content: The content to potentially truncate
        limit: Maximum characters to include (default: MAX_FILE_PREVIEW_SIZE)
        note_template: Template for the truncation note. Supports {remaining} placeholder.

    Returns:
        Truncated content with note, or original if under limit

    Example:
        >>> truncate_with_note("x" * 2000, limit=1000)
        'xxx...xxx\n\n... [1,000 more characters]\nUse read_file() for full content'
    """
    if len(content) <= limit:
        return content

    remaining = len(content) - limit
    note = note_template.format(remaining=remaining)
    return content[:limit] + note


def create_metadata_response(
    items: list[dict[str, Any]],
    summary: str,
    note: str = "Use specific tools to load detailed content for individual items",
) -> dict[str, Any]:
    """Create a metadata-first response structure.

    Args:
        items: List of item metadata dictionaries
        summary: Human-readable summary (e.g., "47 files in Desktop/")
        note: Expansion affordance message

    Returns:
        Structured response with summary, metadata, and expansion note

    Example:
        >>> create_metadata_response(
        ...     items=[{"path": "file.txt", "size": 1024}],
        ...     summary="1 file in workspace/",
        ... )
        {
            "summary": "1 file in workspace/",
            "items": [{"path": "file.txt", "size": 1024}],
            "note": "Use specific tools to load detailed content for individual items"
        }
    """
    return {
        "summary": summary,
        "items": items,
        "note": note,
    }


def format_file_metadata(path: Path) -> dict[str, Any]:
    """Extract metadata from a file without loading content.

    Args:
        path: Path to the file

    Returns:
        Dictionary with file metadata (path, size, modified time)

    Example:
        >>> format_file_metadata(Path("example.txt"))
        {
            "path": "/path/to/example.txt",
            "size": 1024,
            "size_human": "1.0 KB",
            "modified": "2025-01-15T10:30:00",
            "name": "example.txt"
        }
    """
    stats = path.stat()

    # Human-readable size
    size_bytes = stats.st_size
    for unit in ["B", "KB", "MB", "GB"]:
        if size_bytes < 1024.0:
            size_human = f"{size_bytes:.1f} {unit}"
            break
        size_bytes /= 1024.0
    else:
        size_human = f"{size_bytes:.1f} TB"

    return {
        "path": str(path),
        "size": stats.st_size,
        "size_human": size_human,
        "modified": stats.st_mtime,
        "name": path.name,
    }


def format_large_output(
    data: str,
    max_length: int = MAX_TOOL_OUTPUT_LENGTH,
    context: str = "",
) -> str:
    """Format potentially large tool output with truncation.

    Args:
        data: The output data to format
        max_length: Maximum length before truncation
        context: Context description (e.g., "error message", "file content")

    Returns:
        Formatted output, truncated if necessary

    Example:
        >>> format_large_output("x" * 10000, max_length=1000, context="search results")
        'xxx...xxx\n\n[Truncated: 9,000 more characters in search results]'
    """
    if len(data) <= max_length:
        return data

    remaining = len(data) - max_length
    context_note = f" in {context}" if context else ""
    return f"{data[:max_length]}\n\n[Truncated: {remaining:,} more characters{context_note}]"


def truncate_error_message(error: Exception) -> dict[str, str]:
    """Format an exception for context-aware error responses.

    Args:
        error: The exception to format

    Returns:
        Dictionary with error message, type, and truncation note

    Example:
        >>> truncate_error_message(ValueError("Something went wrong"))
        {
            "error": "Something went wrong",
            "type": "ValueError",
            "note": "Full trace available via diagnostic tools"
        }
    """
    error_msg = str(error)

    if len(error_msg) > MAX_ERROR_MESSAGE_LENGTH:
        error_msg = error_msg[:MAX_ERROR_MESSAGE_LENGTH] + "..."

    return {
        "error": error_msg,
        "type": type(error).__name__,
        "note": "Full trace available via diagnostic tools",
    }


def limit_search_results(
    results: list[Any],
    max_results: int = MAX_SEARCH_RESULTS,
) -> dict[str, Any]:
    """Limit search results and provide expansion affordance.

    Args:
        results: List of search results
        max_results: Maximum number of results to return

    Returns:
        Dictionary with limited results and expansion note if truncated

    Example:
        >>> limit_search_results([1, 2, 3], max_results=2)
        {
            "results": [1, 2],
            "total": 3,
            "truncated": True,
            "note": "Showing first 2 of 3 results. Refine search for more specific results."
        }
    """
    total = len(results)
    truncated = total > max_results
    limited = results[:max_results]

    response = {
        "results": limited,
        "total": total,
        "truncated": truncated,
    }

    if truncated:
        response["note"] = (
            f"Showing first {max_results} of {total} results. "
            f"Refine search for more specific results."
        )

    return response


def limit_directory_listing(
    entries: list[Path],
    max_entries: int = MAX_DIRECTORY_LISTING,
) -> dict[str, Any]:
    """Limit directory listing and provide metadata-first response.

    Args:
        entries: List of directory entries
        max_entries: Maximum number of entries to return

    Returns:
        Dictionary with limited metadata and expansion note

    Example:
        >>> limit_directory_listing([Path("file1.txt"), Path("file2.txt")])
        {
            "summary": "2 entries",
            "entries": [...metadata...],
            "total": 2,
            "truncated": False
        }
    """
    total = len(entries)
    truncated = total > max_entries
    limited = entries[:max_entries]

    response = {
        "summary": f"{total} entries",
        "entries": [format_file_metadata(p) for p in limited],
        "total": total,
        "truncated": truncated,
    }

    if truncated:
        response["note"] = (
            f"Showing first {max_entries} of {total} entries. "
            f"Use specific path queries for detailed exploration."
        )

    return response
