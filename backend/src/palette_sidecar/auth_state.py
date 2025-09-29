"""Authentication state machine for Claude.ai session management.

This module consolidates all authentication logic including login orchestration,
status detection, and session management. It replaces the distributed auth logic
previously scattered across claude_service.py and api.py.
"""

from __future__ import annotations

import asyncio
import logging
from dataclasses import dataclass

from .claude_cli import (
    ANSI_ESCAPE_RE,
    URL_PATTERN,
    ClaudeCLIUnavailableError,
    parse_account_email,
    run_cli,
    spawn_cli,
)

logger = logging.getLogger(__name__)


@dataclass
class AuthState:
    """Immutable authentication state snapshot."""

    active: bool
    account: str | None = None
    message: str | None = None
    login_url: str | None = None
    pending: bool = False


class AuthStateMachine:
    """Manages Claude.ai authentication state transitions.

    This state machine consolidates all authentication operations:
    - Login flow orchestration
    - Logout handling
    - Status detection from CLI
    - Login URL extraction and notification
    """

    def __init__(self) -> None:
        self._login_task: asyncio.Task[AuthState] | None = None
        self._login_url: str | None = None
        self._initial_message: str | None = None

    async def login(self) -> AuthState:
        """Start the Claude.ai login flow.

        Returns immediately with pending=True. Use wait_for_completion()
        or poll get_status() to track progress.
        """
        if self._login_task and not self._login_task.done():
            # Login already in progress
            return AuthState(
                active=False,
                pending=True,
                message=self._initial_message or "Login in progress…",
                login_url=self._login_url,
            )

        # Start new login flow
        self._login_url = None
        self._initial_message = "Opening browser to sign in…"
        self._login_task = asyncio.create_task(self._run_login_flow())

        return AuthState(
            active=False,
            pending=True,
            message=self._initial_message,
        )

    async def logout(self) -> AuthState:
        """Terminate Claude.ai authentication."""
        code, stdout, stderr = await run_cli("logout")
        output = stdout.strip() or stderr.strip()

        if code != 0:
            return AuthState(active=True, message=output or "Logout failed")

        return AuthState(active=False, message=output or "Signed out")

    async def refresh(self) -> AuthState:
        """Fetch current authentication status from CLI."""
        return await _fetch_session_status()

    async def get_status(self) -> AuthState:
        """Get current authentication status (non-blocking).

        If login is in progress, returns pending state with progress info.
        Otherwise, fetches current status from CLI.
        """
        if self._login_task and not self._login_task.done():
            return AuthState(
                active=False,
                pending=True,
                message=self._initial_message or "Login in progress…",
                login_url=self._login_url,
            )

        if self._login_task and self._login_task.done():
            # Login completed, return final result
            try:
                return self._login_task.result()
            except Exception as exc:
                logger.error("Login task failed: %s", exc)
                return AuthState(active=False, message=str(exc))

        # No login in progress, fetch current status
        return await self.refresh()

    async def wait_for_completion(self) -> AuthState:
        """Block until login flow completes (if one is running)."""
        if self._login_task:
            return await self._login_task
        return await self.refresh()

    async def _run_login_flow(self) -> AuthState:
        """Execute the login subprocess and monitor its output."""
        try:
            process = await spawn_cli("login")
        except ClaudeCLIUnavailableError as exc:
            logger.error("Claude CLI unavailable: %s", exc)
            status = AuthState(active=False, message=str(exc))
            self._initial_message = status.message
            return status

        # Monitor process output for login URL
        if process.stdout:
            asyncio.create_task(self._scan_login_output(process.stdout))

        # Wait for process completion
        await process.wait()

        # Fetch final status
        final_status = await _fetch_session_status()

        # Clear login state
        self._initial_message = final_status.message
        return final_status

    async def _scan_login_output(self, stream: asyncio.StreamReader) -> None:
        """Scan subprocess output for login URLs and status messages."""
        while True:
            try:
                line_bytes = await stream.readline()
                if not line_bytes:
                    break
                line = line_bytes.decode("utf-8", errors="replace")
                clean_line = ANSI_ESCAPE_RE.sub("", line).strip()
                logger.debug("CLI output: %s", clean_line)

                # Extract login URL if present
                match = URL_PATTERN.search(line)
                if match:
                    self._login_url = match.group(0).rstrip(")")
            except Exception as exc:  # pragma: no cover
                logger.debug("Error reading CLI output: %s", exc)
                break


async def _fetch_session_status() -> AuthState:
    """Attempt to resolve the current Claude.ai session status via CLI.

    Tries multiple CLI commands in order of preference to detect session status.
    """
    for candidate in (("whoami", "--json"), ("whoami",), ("session", "status")):
        try:
            code, stdout, stderr = await run_cli(*candidate)
        except Exception as exc:  # pragma: no cover
            logger.debug("Failed to execute CLI status command %s: %s", candidate, exc)
            continue

        output = stdout.strip() or stderr.strip()
        clean = ANSI_ESCAPE_RE.sub("", output).strip()

        if code != 0:
            if clean and "not" in clean.lower():
                return AuthState(active=False, message=clean)
            if output:
                return AuthState(active=False, message=output)
            continue

        # Try to parse JSON response
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
                return AuthState(active=True, account=email)

        # Try to extract email from text output
        email = parse_account_email(output)
        if email:
            return AuthState(active=True, account=email, message=output)

        if output:
            return AuthState(active=True, message=output)

    return AuthState(active=False)


# Global state machine instance
_auth_machine = AuthStateMachine()


def get_auth_machine() -> AuthStateMachine:
    """Get the global authentication state machine."""
    return _auth_machine