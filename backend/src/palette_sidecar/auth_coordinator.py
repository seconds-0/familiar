"""Claude.ai login flow coordination.

This module handles the interactive Claude.ai authentication flow, managing
browser-based login processes and session status updates.
"""

from __future__ import annotations

import asyncio
import logging
from dataclasses import dataclass

from .claude_cli import (
    ClaudeCLIUnavailableError,
    parse_account_email,
    run_cli,
    spawn_cli,
)
from .patterns import extract_url, strip_ansi

logger = logging.getLogger(__name__)


@dataclass
class ClaudeAuthStatus:
    """Authentication status for Claude.ai sessions."""

    active: bool
    account: str | None = None
    message: str | None = None
    login_url: str | None = None
    pending: bool = False


async def fetch_claude_session_status() -> ClaudeAuthStatus:
    """Attempt to resolve the current Claude.ai session status via CLI."""

    for candidate in (("whoami", "--json"), ("whoami",), ("session", "status")):
        try:
            code, stdout, stderr = await run_cli(*candidate)
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

        # Try JSON parsing for structured output
        import json
        from contextlib import suppress

        with suppress(json.JSONDecodeError):
            payload = json.loads(stdout)
            email = (
                payload.get("account")
                or payload.get("email")
                or payload.get("accountEmail")
            )
            if isinstance(email, str) and email:
                return ClaudeAuthStatus(active=True, account=email)

        # Fall back to text parsing
        email = parse_account_email(output)
        if email:
            return ClaudeAuthStatus(active=True, account=email, message=output)

        if output:
            return ClaudeAuthStatus(active=True, message=output)

    return ClaudeAuthStatus(active=False)


async def perform_claude_logout() -> ClaudeAuthStatus:
    """Terminate Claude.ai authentication."""

    code, stdout, stderr = await run_cli("logout")
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
    """Manage Claude.ai login flows triggered via the CLI.

    This coordinator handles the asynchronous browser-based login process,
    captures CLI output for status updates and login URLs, and maintains
    pending state during authentication.
    """

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

    def merge_status(self, status: ClaudeAuthStatus, session_callback=None) -> ClaudeAuthStatus:
        """Merge external status updates while preserving pending state.

        Args:
            status: The new authentication status to merge
            session_callback: Optional callback to configure session (takes active, account)
        """

        status.login_url = status.login_url or self._login_url
        if self._pending:
            status.pending = True
            status.message = status.message or self._initial_message or self._last_output
        else:
            status.pending = False

        self._status = status
        if session_callback:
            session_callback(
                claude_session_active=status.active,
                claude_account=status.account,
            )
        return self.snapshot()

    async def wait_for_completion(self) -> ClaudeAuthStatus:
        """Wait for the current login task to complete."""

        task = self._task
        if not task:
            return self.snapshot()
        try:
            return await task
        except Exception as exc:  # pragma: no cover - defensive
            logger.error("Claude login task failed: %s", exc)
            status = ClaudeAuthStatus(active=False, message=str(exc), login_url=self._login_url)
            self._finalise(status, session_callback=None)
            return status

    async def cancel(self) -> None:
        """Cancel any pending login operation."""

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
        """Reset internal state for a new login attempt."""

        if self._ensure_event_task:
            self._ensure_event_task.cancel()
            self._ensure_event_task = None
        self._initial_event = asyncio.Event()
        self._initial_message = "Opening browser to sign in…"
        self._last_output = None
        self._login_url = None
        self._process = None

    async def _ensure_initial_signal(self) -> None:
        """Ensure the initial event is set after a timeout."""

        await asyncio.sleep(1)
        if self._initial_event and not self._initial_event.is_set():
            self._initial_event.set()

    async def _consume_stream(self, stream: asyncio.StreamReader) -> None:
        """Consume and record output from a subprocess stream."""

        while True:
            chunk = await stream.read(1024)
            if not chunk:
                break
            self._record_output(chunk.decode("utf-8", errors="replace"))

    def _record_output(self, text: str) -> None:
        """Parse and record CLI output, extracting login URLs and messages."""

        cleaned = strip_ansi(text).replace("\r", "\n")
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
                url = extract_url(line)
                if url:
                    self._login_url = url

    async def _run_login_flow(self) -> ClaudeAuthStatus:
        """Execute the Claude CLI login process and return final status."""

        try:
            process = await spawn_cli("login")
        except ClaudeCLIUnavailableError as exc:
            logger.error("Claude CLI unavailable: %s", exc)
            status = ClaudeAuthStatus(active=False, message=str(exc))
            self._initial_message = status.message
            self._finalise(status, session_callback=None)
            return status
        except Exception as exc:  # pragma: no cover - defensive
            logger.error("Failed to start Claude login: %s", exc)
            status = ClaudeAuthStatus(active=False, message=str(exc))
            self._finalise(status, session_callback=None)
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
            self._finalise(status, session_callback=None)
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

        self._finalise(status, session_callback=None)
        return status

    def _finalise(self, status: ClaudeAuthStatus, session_callback=None) -> None:
        """Finalize the login flow by updating status and clearing pending state."""

        self._pending = False
        status.login_url = status.login_url or self._login_url
        status.pending = False
        self._status = status
        if self._ensure_event_task:
            self._ensure_event_task.cancel()
            self._ensure_event_task = None
        if self._initial_event and not self._initial_event.is_set():
            self._initial_event.set()
        if session_callback:
            session_callback(
                claude_session_active=status.active,
                claude_account=status.account,
            )


# Module-level coordinator instance
login_coordinator = ClaudeLoginCoordinator()


async def trigger_claude_login() -> ClaudeAuthStatus:
    """Public entry point for initiating Claude.ai login."""
    return await login_coordinator.begin_login()


async def trigger_claude_logout() -> ClaudeAuthStatus:
    """Public entry point for logging out of Claude.ai."""
    await login_coordinator.cancel()
    status = await perform_claude_logout()
    # Import session locally to avoid circular dependency
    from .claude_service import session
    return login_coordinator.merge_status(
        status, session_callback=session.configure
    )


async def refresh_claude_auth_state() -> ClaudeAuthStatus:
    """Refresh cached Claude.ai authentication status."""
    status = await fetch_claude_session_status()
    # Import session locally to avoid circular dependency
    from .claude_service import session
    return login_coordinator.merge_status(
        status, session_callback=session.configure
    )
