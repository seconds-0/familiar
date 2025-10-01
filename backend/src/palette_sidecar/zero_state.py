"""Zero state suggestions powered by Claude AI."""

import logging
import json
from datetime import datetime
from typing import Literal, cast

from .claude_service import session

logger = logging.getLogger(__name__)

TimeOfDay = Literal["morning", "afternoon", "evening", "night"]
DayOfWeek = Literal["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]


def get_time_of_day() -> TimeOfDay:
    """Determine time of day based on current hour."""
    hour = datetime.now().hour
    if 5 <= hour < 12:
        return "morning"
    elif 12 <= hour < 17:
        return "afternoon"
    elif 17 <= hour < 21:
        return "evening"
    else:
        return "night"


def get_day_of_week() -> DayOfWeek:
    """Get current day of week."""
    # Cast to DayOfWeek for type-checkers; runtime value always like 'Monday'.
    return cast(DayOfWeek, datetime.now().strftime("%A"))


def build_suggestion_prompt(time_of_day: TimeOfDay, day_of_week: DayOfWeek, recent_history: list[str]) -> str:
    """Build the prompt for Claude to generate suggestions with deduplication."""
    weekend = day_of_week in ["Saturday", "Sunday"]
    day_type = "weekend" if weekend else "weekday"

    history_note = ""
    if recent_history:
        recent_str = ", ".join(f'"{s}"' for s in recent_history)
        history_note = f"\n\nAVOID these recent suggestions: {recent_str}"

    return f"""Generate 4 specific, delightful suggestions that spark curiosity.

Context: It's {time_of_day} on a {day_type} ({day_of_week}).

Guidelines:
- Be SPECIFIC and intriguing (not "research octopuses" but "research why octopuses have blue blood")
- Make the suggestion itself interesting enough to click
- Each should be surprising enough to make someone say "ooh!"
- Avoid common/obvious topics
- Think: what would delight a curious mind?

Categories:
- One creative/generative task (specific scenario, e.g. "Write a haiku about rush hour traffic")
- One organization/management task (specific outcome, e.g. "Organize photos from last summer")
- One research/learning task (specific fascinating fact, e.g. "Learn why cats are obsessed with boxes")
- One unexpected/magical possibility (specific surprise, e.g. "Find constellations visible from your window tonight"){history_note}

Return ONLY a JSON array of 4 strings, nothing else."""


async def generate_suggestions(count: int = 4, history: list[str] | None = None) -> list[str]:
    """
    Generate contextual zero state suggestions using Claude.

    Args:
        count: Number of suggestions to generate (default 4)
        history: Recent suggestions to avoid (default None)

    Returns:
        List of suggestion strings
    """
    try:
        time_of_day = get_time_of_day()
        day_of_week = get_day_of_week()

        logger.info(f"Generating {count} suggestions for {time_of_day} on {day_of_week}")

        prompt = build_suggestion_prompt(time_of_day, day_of_week, history or [])

        # Stream the session and collect the response text
        response_text: list[str] = []
        async for event in session.stream(prompt, session_id="zero-state"):
            if event.get("type") == "assistant_text":
                response_text.append(event.get("text", ""))
            elif event.get("type") == "error":
                raise RuntimeError(event.get("message", "Query failed"))

        # Parse JSON response
        full_text = "".join(response_text).strip()

        # Claude may occasionally wrap JSON in markdown code fences; strip them.
        if full_text.startswith("```"):
            lines = full_text.split("\n")
            if lines and lines[0].startswith("```"):
                lines = lines[1:]
            if lines and lines[-1].strip() == "```":
                lines = lines[:-1]
            full_text = "\n".join(lines).strip()

        suggestions = json.loads(full_text)

        if not isinstance(suggestions, list):
            raise ValueError(f"Expected list, got {type(suggestions)}")

        # Return requested count
        return suggestions[:count]

    except Exception as e:
        logger.error(f"Failed to generate suggestions: {e}")
        # Return fallback suggestions on error
        return [
            "Organize something that needs tidying",
            "Create something new",
            "Learn about a topic you're curious about",
            "Solve a problem you're facing"
        ][:count]


def build_resume_prompt(context_summary: str) -> str:
    """Prompt to produce a single, specific resume label based on recent context.

    The assistant should return only JSON: {"suggestion": "..."}
    The text must be short (<= 12 words), friendly, and specific.
    """
    return (
        "You are writing a single, clickable action for a zero state.\n"
        "Context summary of the previous session:\n"
        f"{context_summary}\n\n"
        "Write ONE short, friendly, specific label the user can click to resume.\n"
        "Rules:\n"
        "- 5–12 words\n"
        "- No trailing punctuation\n"
        "- Use concrete nouns from context if present (file names, project)\n"
        "- Sound human and helpful (no corporate tone)\n"
        "- Examples: 'Get back to editing notes', 'Resume refactor in MyApp', 'Open the docs PR again'\n\n"
        "Return ONLY JSON: {\"suggestion\": \"...\"}."
    )


async def generate_resume_suggestion(context_summary: str) -> str:
    """Generate a single resume suggestion label from a brief context summary."""
    try:
        prompt = build_resume_prompt(context_summary)
        chunks: list[str] = []
        async for event in session.stream(prompt, session_id="resume-suggestion"):
            if event.get("type") == "assistant_text":
                chunks.append(event.get("text", ""))
            elif event.get("type") == "error":
                raise RuntimeError(event.get("message", "Query failed"))

        text = "".join(chunks).strip()
        # Strip code fences if present
        if text.startswith("```"):
            lines = text.split("\n")
            if lines and lines[0].startswith("```"):
                lines = lines[1:]
            if lines and lines[-1].strip() == "```":
                lines = lines[:-1]
            text = "\n".join(lines).strip()

        obj = json.loads(text)
        suggestion = obj.get("suggestion") if isinstance(obj, dict) else None
        if not suggestion or not isinstance(suggestion, str):
            raise ValueError("Missing 'suggestion' in response")
        return suggestion.strip()
    except Exception as e:  # pragma: no cover - best effort
        logger.debug("Failed to generate resume suggestion: %s", e)
        # Fallback string; UI can also provide its own fallback
        return "Keep working on what we were doing before"
