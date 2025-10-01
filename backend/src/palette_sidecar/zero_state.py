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


def build_suggestion_prompt(time_of_day: TimeOfDay, day_of_week: DayOfWeek) -> str:
    """Build the prompt for Claude to generate suggestions."""
    weekend = day_of_week in ["Saturday", "Sunday"]
    day_type = "weekend" if weekend else "weekday"

    return f"""Generate 4 short, inspiring suggestions for what I could help with right now.

Context: It's {time_of_day} on a {day_type} ({day_of_week}).

Show the breadth of what's possible across these categories:
- One creative/generative task (writing, creating, designing)
- One organization/management task (organizing, cleaning, sorting)
- One research/learning task (explaining, researching, learning)
- One unexpected/magical possibility (surprising, automating, discovering)

Guidelines:
- Be specific and actionable (5-8 words each)
- Use natural, conversational language
- Universal appeal (from grandma to developer)
- Never focus on coding or technical tasks
- Think: intent to action

Return ONLY a JSON array of 4 strings, nothing else.
Example: ["Organize cluttered desktop files", "Create a birthday invitation", "Research vacation destinations", "Automate a tedious task"]"""


async def generate_suggestions(count: int = 4) -> list[str]:
    """
    Generate contextual zero state suggestions using Claude.

    Args:
        count: Number of suggestions to generate (default 4)

    Returns:
        List of suggestion strings
    """
    try:
        time_of_day = get_time_of_day()
        day_of_week = get_day_of_week()

        logger.info(f"Generating {count} suggestions for {time_of_day} on {day_of_week}")

        prompt = build_suggestion_prompt(time_of_day, day_of_week)

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
