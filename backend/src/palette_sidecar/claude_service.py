"""Claude Code SDK session management for the native palette sidecar."""

from __future__ import annotations

import asyncio
import difflib
import json
import logging
from contextlib import suppress
from dataclasses import dataclass, field
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

MAX_QUERY_ATTEMPTS = 3

_UNSET = object()

logger = logging.getLogger(__name__)


@dataclass
class SessionConfig:
    api_key: str | None = None
    workspace: Path | None = None
    always_allow: dict[str, list[str]] = field(default_factory=dict)


@dataclass
class ToolContext:
    path: str | None
    relative_path: str | None
    input: dict[str, Any]
    tool: str
    diff: str | None


class ClaudeSession:
    """Manages a persistent ClaudeSDKClient connection and event stream."""

    def __init__(self) -> None:
        self._config = SessionConfig()
        self._options = ClaudeCodeOptions(
            allowed_tools=["Write"],
            permission_mode="default",
            model="claude-sonnet-4-20250514",
            system_prompt=STEEL_THREAD_SYSTEM_PROMPT,
            mcp_servers=self._load_mcp_config(),
        )
        self._client: ClaudeSDKClient | None = None
        self._receiver_task: asyncio.Task[None] | None = None
        self._event_queue: asyncio.Queue[dict[str, Any]] | None = None
        self._pending_tools: dict[str, ToolContext] = {}
        self._needs_restart = True
        self._lock = asyncio.Lock()
        self._workspace_root: Path | None = None
        self._allow_rules: dict[str, set[str]] = {}

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
        always_allow: dict[str, list[str]] | None | object = _UNSET,
    ) -> None:
        if api_key is not _UNSET:
            self._config.api_key = api_key  # type: ignore[assignment]
            if api_key:
                apply_environment(api_key)
        if workspace is not _UNSET:
            resolved = workspace.resolve() if workspace else None
            self._config.workspace = resolved  # type: ignore[assignment]
            self._workspace_root = resolved
            self._options.cwd = str(resolved) if resolved else None
        if always_allow is not _UNSET:
            value = always_allow or {}
            self._config.always_allow = value  # type: ignore[assignment]
            self._allow_rules = {
                tool: {str(path) for path in paths}
                for tool, paths in value.items()
            }
        self._needs_restart = True

    @property
    def is_ready(self) -> bool:
        return self._config.api_key is not None and self._config.workspace is not None

    def _load_mcp_config(self) -> dict[str, Any]:
        """Load MCP server configuration from .mcp.json file."""
        config_path = Path(__file__).parent.parent.parent.parent / ".mcp.json"
        try:
            if config_path.exists():
                with open(config_path, "r", encoding="utf-8") as f:
                    config = json.load(f)
                    return config.get("mcpServers", {})
        except Exception as exc:
            logger.warning("Failed to load MCP config from %s: %s", config_path, exc)
        return {}

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
            await self._query_with_retries(prompt, session_id)
            while True:
                event = await queue.get()
                if event.get("type") == "complete":
                    break
                yield event
        except Exception as exc:  # pragma: no cover - defensive logging
            self._needs_restart = True
            self._log_hook("stream_error", error=str(exc))
            friendly = "Claude request failed after multiple attempts. Please try again."
            await self._emit_event({"type": "error", "message": friendly})
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
                context = self._pending_tools.pop(block.tool_use_id, None)
                canonical_path = context.path if context else None
                relative_path = context.relative_path if context else None
                display_path = relative_path or canonical_path
                snippet = None
                if canonical_path:
                    try:
                        snippet = Path(canonical_path).read_text(encoding="utf-8")[-400:]
                    except Exception:
                        snippet = None
                await self._emit_event(
                    {
                        "type": "tool_result",
                        "toolUseId": block.tool_use_id,
                        "content": self._serialise_tool_result(block.content),
                        "isError": block.is_error,
                        "path": display_path,
                        "canonicalPath": canonical_path,
                        "snippet": snippet,
                    }
                )

    async def _emit_event(self, event: dict[str, Any]) -> None:
        if self._event_queue is None:
            return
        await self._event_queue.put(event)

    def _log_hook(self, event: str, **context: Any) -> None:
        payload = {"event": event, **context}
        logger.info("hook_event %s", json.dumps(payload, ensure_ascii=False))

    def _allow_decision(self) -> dict[str, Any]:
        return {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
                "permissionDecisionReason": "User approved",
            }
        }

    def _deny_decision(self, *, reason: str) -> dict[str, Any]:
        return {
            "decision": "block",
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            },
        }

    def _canonicalise_tool_path(
        self, raw_path: str | None
    ) -> tuple[Path | None, str | None]:
        if not raw_path:
            return None, None
        workspace_root = self._workspace_root
        candidate = Path(raw_path)
        if workspace_root is None:
            return candidate.resolve(), str(candidate)
        if not candidate.is_absolute():
            candidate = workspace_root / candidate
        try:
            resolved = candidate.resolve()
        except (OSError, RuntimeError):
            resolved = workspace_root / Path(raw_path)
        try:
            relative = resolved.relative_to(workspace_root)
        except ValueError:
            return None, None
        return resolved, str(relative)

    def _render_diff(
        self,
        canonical_path: Path | None,
        relative_path: str | None,
        tool_input: dict[str, Any],
    ) -> str | None:
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
                n=3,
            )
        )
        if not diff_lines:
            return None

        max_lines = 200
        if len(diff_lines) > max_lines:
            diff_lines = diff_lines[:max_lines]
            diff_lines.append("... diff truncated ...")

        return "\n".join(diff_lines)

    def _should_auto_allow(self, tool_name: str, canonical_path: Path | None) -> bool:
        if canonical_path is None:
            return False
        allowed = self._allow_rules.get(tool_name)
        if not allowed:
            return False
        return str(canonical_path) in allowed

    def _record_auto_allow(self, tool_name: str, canonical_path: Path) -> None:
        rules = self._allow_rules.setdefault(tool_name, set())
        rules.add(str(canonical_path))

    @staticmethod
    def _context_snapshot(context: ToolContext | None) -> dict[str, Any]:
        if context is None:
            return {}
        return {
            "path": context.path,
            "relativePath": context.relative_path,
            "tool": context.tool,
            "diff": context.diff,
            "input": context.input,
        }

    async def _query_with_retries(self, prompt: str, session_id: str) -> None:
        attempt = 0
        delay = 0.5
        last_exc: Exception | None = None
        while attempt < MAX_QUERY_ATTEMPTS:
            try:
                if self._client is None:
                    raise RuntimeError("Claude SDK client unavailable")
                await self._client.query(prompt, session_id=session_id)
                return
            except Exception as exc:  # pragma: no cover - defensive retry path
                attempt += 1
                last_exc = exc
                self._log_hook("query_retry", attempt=attempt, error=str(exc))
                if attempt >= MAX_QUERY_ATTEMPTS:
                    break
                await asyncio.sleep(delay)
                delay = min(delay * 2, 4.0)
                self._needs_restart = True
                await self.start()
        if last_exc is not None:
            raise last_exc

    async def notify_permission_resolution(
        self,
        request_id: str,
        decision: str,
        *,
        remember: bool = False,
    ) -> dict[str, Any]:
        context = self._pending_tools.get(request_id)
        if decision != "allow" and context is not None:
            self._pending_tools.pop(request_id, None)
        snapshot = self._context_snapshot(context)
        await self._emit_event(
            {
                "type": "permission_resolution",
                "requestId": request_id,
                "decision": decision,
                "context": snapshot,
            }
        )
        self._log_hook(
            "permission_resolution",
            request_id=request_id,
            decision=decision,
            remember=remember,
        )
        if decision == "deny":
            await self._emit_event(
                {
                    "type": "error",
                    "message": "Permission denied. Claude could not run the requested action.",
                }
            )
        elif decision == "allow" and remember and context and context.path:
            self._record_auto_allow(context.tool, Path(context.path))
        return snapshot

    async def _handle_pre_tool_use(
        self, input_data: dict[str, Any], tool_use_id: str | None, _context: Any
    ) -> dict[str, Any]:
        request_id = tool_use_id or str(uuid4())
        tool_name = input_data.get("tool_name", "Unknown")
        tool_input = input_data.get("tool_input", {})
        canonical_path: Path | None = None
        relative_path: str | None = None
        diff_preview: str | None = None

        if tool_name == "Write":
            canonical_path, relative_path = self._canonicalise_tool_path(tool_input.get("path"))
            if tool_input.get("path") and canonical_path is None:
                self._log_hook(
                    "pre_tool_use_blocked",
                    request_id=request_id,
                    tool=tool_name,
                    reason="path_outside_workspace",
                )
                await self._emit_event(
                    {
                        "type": "error",
                        "message": "Write requests must stay inside the configured workspace.",
                    }
                )
                return self._deny_decision(reason="Path outside workspace")

            diff_preview = self._render_diff(canonical_path, relative_path, tool_input)

        context = ToolContext(
            path=str(canonical_path) if canonical_path else None,
            relative_path=relative_path,
            input=tool_input,
            tool=tool_name,
            diff=diff_preview,
        )
        self._pending_tools[request_id] = context

        if self._should_auto_allow(tool_name, canonical_path):
            self._log_hook(
                "auto_allow",
                request_id=request_id,
                tool=tool_name,
                path=context.path,
            )
            return self._allow_decision()

        payload = {
            "requestId": request_id,
            "toolName": tool_name,
            "input": tool_input,
            "path": context.relative_path or context.path,
            "canonicalPath": context.path,
            "diff": context.diff,
        }

        future = await broker.register(request_id, payload)
        await self._emit_event({"type": "permission_request", **payload})
        self._log_hook(
            "permission_request",
            request_id=request_id,
            tool=tool_name,
            path=context.path,
        )

        decision = await future
        self._log_hook(
            "permission_decision",
            request_id=request_id,
            tool=tool_name,
            decision=decision,
        )
        if decision == "allow":
            return self._allow_decision()
        return self._deny_decision(reason="User denied")

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
