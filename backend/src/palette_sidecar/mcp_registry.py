"""Utility helpers for translating manifest JSON into Claude Code MCP configs."""

from __future__ import annotations

from typing import Any

from claude_code_sdk import McpSSEServerConfig, McpStdioServerConfig


def to_mcp_config(manifest: dict[str, Any]) -> McpSSEServerConfig | McpStdioServerConfig:
    transport = manifest.get("transport")
    if transport == "stdio":
        return McpStdioServerConfig(
            command=manifest["command"],
            args=manifest.get("args", []),
            env=manifest.get("env", {}),
        )
    if transport == "sse":
        return McpSSEServerConfig(
            url=manifest["url"],
            headers=manifest.get("headers", {}),
        )
    raise ValueError(f"Unsupported transport type: {transport}")
