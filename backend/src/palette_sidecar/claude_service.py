"""Claude Code SDK session management for the native palette sidecar."""

from __future__ import annotations

from collections.abc import AsyncIterator
from typing import Any

from claude_code_sdk import (
    AssistantMessage,
    ClaudeCodeOptions,
    ClaudeSDKClient,
    TextBlock,
)


class ClaudeSession:
    """Wraps a persistent ClaudeSDKClient instance with streaming helpers."""

    def __init__(self, cwd: str | None = None) -> None:
        self._options = ClaudeCodeOptions(
            cwd=cwd,
            allowed_tools=[],
            permission_mode="ask",
        )
        self._client: ClaudeSDKClient | None = None

    async def start(self) -> None:
        """Establish the SDK client connection."""
        if self._client is not None:
            return
        self._client = ClaudeSDKClient(options=self._options)
        await self._client.connect()

    async def stream(self, prompt: str) -> AsyncIterator[str]:
        """Stream assistant text blocks for a prompt."""
        if self._client is None:
            raise RuntimeError("Claude session not started")
        await self._client.query(prompt)
        async for message in self._client.receive_response():
            if isinstance(message, AssistantMessage):
                yield from self._text_blocks(message)

    @staticmethod
    def _text_blocks(message: AssistantMessage) -> AsyncIterator[str]:
        for block in message.content:
            if isinstance(block, TextBlock):
                yield block.text

    async def shutdown(self) -> None:
        if self._client is not None:
            await self._client.close()
            self._client = None


session = ClaudeSession()
