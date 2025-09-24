"""Claude Code SDK session management for the native palette sidecar."""

from __future__ import annotations

import asyncio
import json
import os
from contextlib import suppress
from dataclasses import dataclass
from pathlib import Path
from typing import Any, AsyncIterator
from uuid import uuid4

from claude_code_sdk import (
    AssistantMessage,
    ClaudeCodeOptions,
    ClaudeSDKClient,
    HookMatcher,
    ResultMessage,
    SystemMessage,
    TextBlock,
    ToolResultBlock,
    ToolUseBlock,
)

from .config import apply_environment
from .permissions import broker

STEEL_THREAD_SYSTEM_PROMPT = """
You are the Claude Code engine behind a macOS command palette demo. Keep responses
short and stream tokens immediately. When the user requests file updates, prefer the
Write tool and operate within the provided workspace. Summarize applied changes at the
end of each response.
""".strip()


_UNSET = object()


@dataclass
class SessionConfig:
    api_key: str | None = None
    workspace: Path | None = None


class ClaudeSession:
    """Manages a persistent ClaudeSDKClient connection and event stream."""

    def __init__(self) -> None:
        self._config = SessionConfig()
        self._options = ClaudeCodeOptions(
            allowed_tools=["Write"],
            permission_mode="ask",
            model="claude-3-5-sonnet-20241022",
            system_prompt=STEEL_THREAD_SYSTEM_PROMPT,
        )
        self._client: ClaudeSDKClient | None = None
        self._receiver_task: asyncio.Task[None] | None = None
        self._event_queue: asyncio.Queue[dict[str, Any]] | None = None
        self._pending_tools: dict[str, dict[str, Any]] = {}
        self._needs_restart = True
        self._lock = asyncio.Lock()

        # Hook bindings
        self._options.hooks = {
            "PreToolUse": [HookMatcher(matcher="*", hooks=[self._handle_pre_tool_use])]
        }

    # ------------------------------------------------------------------
    # Configuration management
    # ------------------------------------------------------------------
    def configure(
        self,
        *,
        api_key: str | None | object = _UNSET,
        workspace: Path | None | object = _UNSET,
    ) -> None:
        if api_key is not _UNSET:
            self._config.api_key = api_key  # type: ignore[assignment]
            if api_key:
                apply_environment(api_key)
        if workspace is not _UNSET:
            self._config.workspace = workspace  # type: ignore[assignment]
            self._options.cwd = str(workspace) if workspace else None
        self._needs_restart = True

    @property
    def is_ready(self) -> bool:
        return self._config.api_key is not None and self._config.workspace is not None

    # ------------------------------------------------------------------
    async def start(self) -> None:
        """Ensure the Claude SDK client is connected."""

        async with self._lock:
            if not self.is_ready:
                return

            if self._client is not None and not self._needs_restart:
                return

            if self._client is not None:
                await self._client.disconnect()
                self._client = None

            self._client = ClaudeSDKClient(options=self._options)
            await self._client.connect()
            self._needs_restart = False

    async def shutdown(self) -> None:
        async with self._lock:
            if self._client is not None:
                await self._client.disconnect()
                self._client = None
            self._needs_restart = True

    # ------------------------------------------------------------------
    async def stream(self, prompt: str, session_id: str = "default") -> AsyncIterator[dict[str, Any]]:
        if not self.is_ready:
            yield {
                "type": "error",
                "message": "Sidecar not configured. Provide API key and workspace first.",
            }
            return

        await self.start()
        if self._client is None:
            yield {
                "type": "error",
                "message": "Claude SDK session unavailable.",
            }
            return

        queue: asyncio.Queue[dict[str, Any]] = asyncio.Queue()
        self._event_queue = queue

        async def pump_messages() -> None:
            try:
                async for message in self._client.receive_response():
                    if isinstance(message, AssistantMessage):
                        await self._handle_assistant_message(message)
                    elif isinstance(message, SystemMessage):
                        await self._emit_event({"type": "system", "data": message.data})
                    elif isinstance(message, ResultMessage):
                        await self._emit_event({"type": "result", "data": {}})
                        break
            finally:
                await self._emit_event({"type": "complete"})

        self._receiver_task = asyncio.create_task(pump_messages())

        try:
            await self._client.query(prompt, session_id=session_id)
            while True:
                event = await queue.get()
                if event.get("type") == "complete":
                    break
                yield event
        except Exception as exc:  # pragma: no cover - defensive logging
            await self._emit_event({"type": "error", "message": str(exc)})
        finally:
            if self._receiver_task:
                self._receiver_task.cancel()
                with suppress(asyncio.CancelledError):
                    await self._receiver_task
                self._receiver_task = None
            self._event_queue = None

    # ------------------------------------------------------------------
    async def _handle_assistant_message(self, message: AssistantMessage) -> None:
        for block in message.content:
            if isinstance(block, TextBlock):
                await self._emit_event({"type": "assistant_text", "text": block.text})
            elif isinstance(block, ToolUseBlock):
                await self._emit_event(
                    {
                        "type": "tool_use",
                        "toolUseId": block.id,
                        "name": block.name,
                        "input": block.input,
                    }
                )
            elif isinstance(block, ToolResultBlock):
                context = self._pending_tools.pop(block.tool_use_id, {})
                snippet = None
                path = context.get("path")
                if path:
                    try:
                        snippet = Path(path).read_text(encoding="utf-8")[-400:]
                    except Exception:
                        snippet = None
                await self._emit_event(
                    {
                        "type": "tool_result",
                        "toolUseId": block.tool_use_id,
                        "content": self._serialise_tool_result(block.content),
                        "isError": block.is_error,
                        "path": path,
                        "snippet": snippet,
                    }
                )

    async def _emit_event(self, event: dict[str, Any]) -> None:
        if self._event_queue is None:
            return
        await self._event_queue.put(event)

    async def notify_permission_resolution(self, request_id: str, decision: str) -> None:
        context = self._pending_tools.get(request_id)
        if decision != "allow" and context is not None:
            self._pending_tools.pop(request_id, None)
        await self._emit_event(
            {
                "type": "permission_resolution",
                "requestId": request_id,
                "decision": decision,
                "context": context,
            }
        )

    async def _handle_pre_tool_use(
        self, input_data: dict[str, Any], tool_use_id: str | None, _context: Any
    ) -> dict[str, Any]:
        request_id = tool_use_id or str(uuid4())
        tool_name = input_data.get("tool_name", "Unknown")
        tool_input = input_data.get("tool_input", {})

        if tool_name == "Write":
            raw_path = tool_input.get("path")
            absolute_path = None
            if raw_path:
                candidate = Path(raw_path)
                if not candidate.is_absolute() and self._config.workspace:
                    candidate = Path(self._config.workspace) / candidate
                absolute_path = str(candidate)
            self._pending_tools[request_id] = {
                "path": absolute_path,
                "input": tool_input,
            }
        else:
            self._pending_tools[request_id] = {"input": tool_input}

        payload = {
            "requestId": request_id,
            "toolName": tool_name,
            "input": tool_input,
        }

        future = await broker.register(request_id, payload)
        await self._emit_event({"type": "permission_request", **payload})

        decision = await future
        if decision == "allow":
            return {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "allow",
                    "permissionDecisionReason": "User approved",
                }
            }
        else:
            return {
                "decision": "block",
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": "User denied",
                },
            }

    @staticmethod
    def _serialise_tool_result(content: Any) -> str:
        if content is None:
            return ""
        if isinstance(content, str):
            return content
        try:
            return json.dumps(content, ensure_ascii=False)
        except TypeError:
            return str(content)


session = ClaudeSession()
