"""Regular expression patterns and text parsing utilities.

This module consolidates regex patterns used across the codebase for parsing
Claude CLI output, extracting URLs, emails, and cleaning ANSI escape codes.
"""

import re

# Regular expressions for parsing CLI output and text
ANSI_ESCAPE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
URL = re.compile(r"https?://[^\s)]+")  # Exclude trailing )
EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
CLAUDE_LOGIN_URL = re.compile(r"(https?://(?:api\.)?claude\.ai/[^\s)]+)")


def strip_ansi(text: str) -> str:
    """Remove ANSI escape codes from text.

    Args:
        text: Input string potentially containing ANSI codes

    Returns:
        Cleaned string with ANSI codes removed
    """
    return ANSI_ESCAPE.sub("", text)


def extract_url(text: str) -> str | None:
    """Extract first URL from text, preferring claude.ai domains.

    Args:
        text: Input string potentially containing URLs

    Returns:
        First URL found, or None if no URLs present
    """
    # Try Claude-specific URL first
    if match := CLAUDE_LOGIN_URL.search(text):
        return match.group(1)
    # Fall back to any URL
    if match := URL.search(text):
        return match.group(0).rstrip(")")
    return None


def extract_email(text: str) -> str | None:
    """Extract email address from text.

    Args:
        text: Input string potentially containing an email

    Returns:
        First email address found, or None if no email present
    """
    if match := EMAIL.search(text):
        return match.group(0)
    return None