"""Claude Code SDK session management for the native palette sidecar."""

from __future__ import annotations

import asyncio
import difflib
import json
import logging
import os
import re
from contextlib import suppress
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, AsyncIterator
from uuid import uuid4

from asyncio.subprocess import PIPE

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

from .config import (
    AUTH_MODE_API_KEY,
    AUTH_MODE_CLAUDE,
    apply_environment,
    ensure_cli_environment,
)
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
class ClaudeAuthStatus:
    active: bool
    account: str | None = None
    message: str | None = None
    login_url: str | None = None
    pending: bool = False


class ClaudeCLIUnavailableError(RuntimeError):
    """Raised when the bundled Claude CLI cannot be executed."""


ANSI_ESCAPE_RE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
URL_PATTERN = re.compile(r"https?://[^\s]+")


def _parse_account_email(output: str) -> str | None:
    """Extract an email address from CLI output."""

    match = re.search(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}", output)
    if match:
        return match.group(0)
    return None


async def _spawn_claude_cli(*args: str) -> asyncio.subprocess.Process:
    """Launch the Claude CLI with the provided arguments."""

    ensure_cli_environment()
    cli_path = os.environ.get("CLAUDE_CODE_CLI_PATH")
    if not cli_path:
        raise ClaudeCLIUnavailableError("Claude CLI path not configured")

    env = os.environ.copy()
    path_value = env.get("PATH", "")
    path_parts = [segment for segment in path_value.split(":") if segment]
    for default_path in ("/usr/bin", "/bin", "/usr/sbin", "/sbin"):
        if default_path not in path_parts:
            path_parts.append(default_path)
    env["PATH"] = ":".join(path_parts)
    command = ["node", cli_path, *args]
    try:
        return await asyncio.create_subprocess_exec(
            *command,
            stdout=PIPE,
            stderr=PIPE,
            env=env,
        )
    except FileNotFoundError as exc:
        raise ClaudeCLIUnavailableError(
            "Claude CLI executable not found. Please reinstall or repair the Familiar app."
        ) from exc
    except OSError as exc:  # pragma: no cover - defensive
        raise ClaudeCLIUnavailableError(str(exc)) from exc


async def _run_claude_cli(*args: str) -> tuple[int, str, str]:
    """Execute the bundled Claude CLI and capture its output."""

    process = await _spawn_claude_cli(*args)
    stdout_bytes, stderr_bytes = await process.communicate()
    stdout_text = stdout_bytes.decode("utf-8", errors="replace")
    stderr_text = stderr_bytes.decode("utf-8", errors="replace")
    return process.returncode, stdout_text, stderr_text


async def fetch_claude_session_status() -> ClaudeAuthStatus:
    """Attempt to resolve the current Claude.ai session status via CLI."""

    for candidate in (("whoami", "--json"), ("whoami",), ("session", "status")):
        try:
            code, stdout, stderr = await _run_claude_cli(*candidate)
        except Exception as exc:  # pragma: no cover - defensive
            logger.debug("Failed to execute CLI status command %s: %s", candidate, exc)
            continue

        output = stdout.strip() or stderr.strip()
        if code != 0:
            normalized = output.lower()
            if "unknown option" in normalized or "unrecognized option" in normalized:
                logger.debug(
                    "Claude CLI command %s does not support flag combination; retrying", candidate
                )
                continue
            if output:
                return ClaudeAuthStatus(active=False, message=output)
            continue

        with suppress(json.JSONDecodeError):
            payload = json.loads(stdout)
            email = (
                payload.get("account")
                or payload.get("email")
                or payload.get("accountEmail")
            )
            if isinstance(email, str) and email:
                return ClaudeAuthStatus(active=True, account=email)

        email = _parse_account_email(output)
        if email:
            return ClaudeAuthStatus(active=True, account=email, message=output)

        if output:
            return ClaudeAuthStatus(active=True, message=output)

    return ClaudeAuthStatus(active=False)


async def perform_claude_logout() -> ClaudeAuthStatus:
    """Terminate Claude.ai authentication."""

    code, stdout, stderr = await _run_claude_cli("logout")
    output = stdout.strip() or stderr.strip()

    if code != 0:
        return ClaudeAuthStatus(active=True, message=output or "Logout failed")

    status = await fetch_claude_session_status()
    if status.active:
        # Some CLI builds may not immediately report logged-out state. Force clear.
        status.active = False
        status.message = output or status.message
        status.account = None
    return status


class ClaudeLoginCoordinator:
    """Manage Claude.ai login flows triggered via the CLI."""

    def __init__(self) -> None:
        self._task: asyncio.Task[ClaudeAuthStatus] | None = None
        self._process: asyncio.subprocess.Process | None = None
        self._initial_event: asyncio.Event | None = None
        self._ensure_event_task: asyncio.Task[None] | None = None
        self._pending = False
        self._status = ClaudeAuthStatus(active=False)
        self._initial_message: str | None = None
        self._last_output: str | None = None
        self._login_url: str | None = None
        self._start_lock = asyncio.Lock()

    async def begin_login(self) -> ClaudeAuthStatus:
        """Start a login flow if needed and return the current status."""

        async with self._start_lock:
            if not self._task or self._task.done():
                self._reset_state()
                self._pending = True
                self._status = ClaudeAuthStatus(active=False, pending=True)
                self._task = asyncio.create_task(self._run_login_flow())
                if self._ensure_event_task:
                    self._ensure_event_task.cancel()
                self._ensure_event_task = asyncio.create_task(self._ensure_initial_signal())

        if self._initial_event is not None:
            try:
                await asyncio.wait_for(self._initial_event.wait(), timeout=10)
            except asyncio.TimeoutError:
                pass
        return self.snapshot()

    def snapshot(self) -> ClaudeAuthStatus:
        """Return the most recent status, including pending information."""

        message = self._status.message or self._initial_message
        login_url = self._status.login_url or self._login_url
        return ClaudeAuthStatus(
            active=self._status.active,
            account=self._status.account,
            message=message,
            login_url=login_url,
            pending=self._pending,
        )

    def merge_status(self, status: ClaudeAuthStatus) -> ClaudeAuthStatus:
        """Merge external status updates while preserving pending state."""

        status.login_url = status.login_url or self._login_url
        if self._pending:
            status.pending = True
            status.message = status.message or self._initial_message or self._last_output
        else:
            status.pending = False

        self._status = status
        session.configure(
            claude_session_active=status.active,
            claude_account=status.account,
        )
        return self.snapshot()

    async def wait_for_completion(self) -> ClaudeAuthStatus:
        task = self._task
        if not task:
            return self.snapshot()
        try:
            return await task
        except Exception as exc:  # pragma: no cover - defensive
            logger.error("Claude login task failed: %s", exc)
            status = ClaudeAuthStatus(active=False, message=str(exc), login_url=self._login_url)
            self._finalise(status)
            return status

    async def cancel(self) -> None:
        async with self._start_lock:
            if self._process and self._pending:
                self._process.terminate()
            self._pending = False
            if self._initial_event and not self._initial_event.is_set():
                self._initial_event.set()
            if self._ensure_event_task:
                self._ensure_event_task.cancel()
                self._ensure_event_task = None

    def _reset_state(self) -> None:
        if self._ensure_event_task:
            self._ensure_event_task.cancel()
            self._ensure_event_task = None
        self._initial_event = asyncio.Event()
        self._initial_message = "Opening browser to sign in…"
        self._last_output = None
        self._login_url = None
        self._process = None

    async def _ensure_initial_signal(self) -> None:
        await asyncio.sleep(1)
        if self._initial_event and not self._initial_event.is_set():
            self._initial_event.set()

    async def _consume_stream(self, stream: asyncio.StreamReader) -> None:
        while True:
            chunk = await stream.read(1024)
            if not chunk:
                break
            self._record_output(chunk.decode("utf-8", errors="replace"))

    def _record_output(self, text: str) -> None:
        cleaned = ANSI_ESCAPE_RE.sub("", text).replace("\r", "\n")
        for line in cleaned.splitlines():
            line = line.strip()
            if not line:
                continue
            logger.debug("Claude CLI login output: %s", line)
            self._last_output = line
            if self._initial_message in {None, "Opening browser to sign in…"}:
                self._initial_message = line
            if self._initial_event and not self._initial_event.is_set():
                self._initial_event.set()
            if not self._login_url:
                match = URL_PATTERN.search(line)
                if match:
                    self._login_url = match.group(0).rstrip(")")

    async def _run_login_flow(self) -> ClaudeAuthStatus:
        try:
            process = await _spawn_claude_cli("login")
        except ClaudeCLIUnavailableError as exc:
            logger.error("Claude CLI unavailable: %s", exc)
            status = ClaudeAuthStatus(active=False, message=str(exc))
            self._initial_message = status.message
            self._finalise(status)
            return status
        except Exception as exc:  # pragma: no cover - defensive
            logger.error("Failed to start Claude login: %s", exc)
            status = ClaudeAuthStatus(active=False, message=str(exc))
            self._finalise(status)
            return status

        self._process = process
        stdout_task = asyncio.create_task(self._consume_stream(process.stdout))
        stderr_task = asyncio.create_task(self._consume_stream(process.stderr))

        try:
            returncode = await process.wait()
        finally:
            await asyncio.gather(stdout_task, stderr_task, return_exceptions=True)
            self._process = None

        if returncode != 0:
            message = self._last_output or self._initial_message or "Claude login failed."
            status = ClaudeAuthStatus(active=False, message=message, login_url=self._login_url)
            self._finalise(status)
            return status

        try:
            status = await fetch_claude_session_status()
        except Exception as exc:  # pragma: no cover - defensive
            logger.error("Failed to refresh Claude login status: %s", exc)
            status = ClaudeAuthStatus(active=False, message=str(exc), login_url=self._login_url)
        else:
            status.login_url = status.login_url or self._login_url
            if not status.message:
                status.message = self._last_output or self._initial_message

        self._finalise(status)
        return status

    def _finalise(self, status: ClaudeAuthStatus) -> None:
        self._pending = False
        status.login_url = status.login_url or self._login_url
        status.pending = False
        self._status = status
        if self._ensure_event_task:
            self._ensure_event_task.cancel()
            self._ensure_event_task = None
        if self._initial_event and not self._initial_event.is_set():
            self._initial_event.set()
        session.configure(
            claude_session_active=status.active,
            claude_account=status.account,
        )


@dataclass
class SessionConfig:
    api_key: str | None = None
    workspace: Path | None = None
    always_allow: dict[str, list[str]] = field(default_factory=dict)
    auth_mode: str = AUTH_MODE_CLAUDE
    claude_session_active: bool = False
    claude_account: str | None = None


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

    async def _safe_disconnect(self) -> None:
        if self._client is None:
            return
        try:
            await self._client.disconnect()
        except (RuntimeError, AttributeError) as exc:  # pragma: no cover - defensive
            logger.debug("Ignoring disconnect error: %s", exc)
        except Exception as exc:  # pragma: no cover - defensive
            logger.warning("Unexpected disconnect error: %s", exc)
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
        auth_mode: str | object = _UNSET,
        claude_session_active: bool | object = _UNSET,
        claude_account: str | None | object = _UNSET,
    ) -> None:
        if api_key is not _UNSET:
            self._config.api_key = api_key  # type: ignore[assignment]
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
        if auth_mode is not _UNSET:
            self._config.auth_mode = auth_mode  # type: ignore[assignment]
        if claude_session_active is not _UNSET:
            self._config.claude_session_active = bool(claude_session_active)  # type: ignore[assignment]
        if claude_account is not _UNSET:
            self._config.claude_account = claude_account  # type: ignore[assignment]

        if self._config.auth_mode == AUTH_MODE_API_KEY:
            apply_environment(self._config.api_key)
        else:
            apply_environment(None)
        self._needs_restart = True

    @property
    def is_ready(self) -> bool:
        if self._config.workspace is None:
            return False

        if self._config.auth_mode == AUTH_MODE_API_KEY:
            return self._config.api_key is not None

        if self._config.auth_mode == AUTH_MODE_CLAUDE:
            return self._config.claude_session_active

        # Fallback to require API key for unknown modes
        return self._config.api_key is not None

    def _configuration_error(self) -> str:
        if self._config.workspace is None:
            return "Workspace not configured."

        if self._config.auth_mode == AUTH_MODE_API_KEY:
            return "API key missing."

        if self._config.auth_mode == AUTH_MODE_CLAUDE:
            return "Claude.ai login required."

        return "Authentication configuration incomplete."

    def _load_mcp_config(self) -> dict[str, Any]:
        """Load MCP server configuration from .mcp.json file with environment variable substitution."""
        config_path = Path(__file__).parent.parent.parent.parent / ".mcp.json"
        try:
            if config_path.exists():
                with open(config_path, "r", encoding="utf-8") as f:
                    content = f.read()

                # Substitute environment variables (${VAR_NAME} format)
                def replace_env_var(match):
                    var_name = match.group(1)
                    env_value = os.getenv(var_name)
                    if env_value is None:
                        logger.warning("Environment variable %s not found, skipping MCP server configuration", var_name)
                        return ""
                    return env_value

                content = re.sub(r'\$\{([^}]+)\}', replace_env_var, content)

                # Only proceed if we have valid content after substitution
                if content and not content.isspace():
                    config = json.loads(content)
                    return config.get("mcpServers", {})
                else:
                    logger.info("MCP configuration skipped due to missing environment variables")

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
                await self._safe_disconnect()
                self._client = None

            self._client = ClaudeSDKClient(options=self._options)
            await self._client.connect()
            self._needs_restart = False

    async def shutdown(self) -> None:
        async with self._lock:
            if self._client is not None:
                await self._safe_disconnect()
                self._client = None
            self._needs_restart = True

    # ------------------------------------------------------------------
    async def stream(self, prompt: str, session_id: str = "default") -> AsyncIterator[dict[str, Any]]:
        if not self.is_ready:
            yield {
                "type": "error",
                "message": self._configuration_error(),
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


async def trigger_claude_login() -> ClaudeAuthStatus:
    """Public entry point for initiating Claude.ai login."""

    status = await login_coordinator.begin_login()
    return status


async def trigger_claude_logout() -> ClaudeAuthStatus:
    """Public entry point for logging out of Claude.ai."""

    await login_coordinator.cancel()
    status = await perform_claude_logout()
    return login_coordinator.merge_status(status)


async def refresh_claude_auth_state() -> ClaudeAuthStatus:
    """Refresh cached Claude.ai authentication status."""

    status = await fetch_claude_session_status()
    return login_coordinator.merge_status(status)


login_coordinator = ClaudeLoginCoordinator()

session = ClaudeSession()
