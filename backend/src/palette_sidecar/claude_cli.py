"""Claude CLI wrapper for authentication and session management.

This module provides a Python interface to the bundled Claude CLI, handling
subprocess spawning, output parsing, and session status detection.
"""

from __future__ import annotations

import asyncio
import json
import logging
import os
import re
from pathlib import Path

from asyncio.subprocess import PIPE

logger = logging.getLogger(__name__)

# Regular expressions for parsing CLI output
ANSI_ESCAPE_RE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
URL_PATTERN = re.compile(r"https?://[^\s]+")
EMAIL_PATTERN = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")


class ClaudeCLIUnavailableError(RuntimeError):
    """Raised when the bundled Claude CLI cannot be executed."""


def parse_account_email(output: str) -> str | None:
    """Extract an email address from CLI output."""
    match = EMAIL_PATTERN.search(output)
    return match.group(0) if match else None


async def spawn_cli(*args: str) -> asyncio.subprocess.Process:
    """Launch the Claude CLI with the provided arguments.

    Args:
        *args: Command-line arguments to pass to the CLI

    Returns:
        The spawned subprocess

    Raises:
        ClaudeCLIUnavailableError: If the CLI cannot be executed
    """
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


async def run_cli(*args: str) -> tuple[int, str, str]:
    """Execute the bundled Claude CLI and capture its output.

    Args:
        *args: Command-line arguments to pass to the CLI

    Returns:
        Tuple of (return_code, stdout, stderr)

    Raises:
        ClaudeCLIUnavailableError: If the CLI cannot be executed
    """
    process = await spawn_cli(*args)
    stdout_bytes, stderr_bytes = await process.communicate()
    stdout_text = stdout_bytes.decode("utf-8", errors="replace")
    stderr_text = stderr_bytes.decode("utf-8", errors="replace")
    return process.returncode, stdout_text, stderr_text