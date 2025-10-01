#!/usr/bin/env python3
"""Measure context token usage for Claude Agent SDK prompts.

Usage:
    uv run python scripts/measure-context.py --prompt "Your prompt here"
    uv run python scripts/measure-context.py --file path/to/prompt.txt

This utility helps validate context engineering by showing:
- Token count for the prompt
- Estimated API cost
- Remaining budget (based on DEFAULT_MAX_TOKENS)
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

# Add src to path for config imports
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

try:
    import tiktoken
except ImportError:
    print("❌ tiktoken not installed. Install with: uv pip install tiktoken")
    sys.exit(1)

from palette_sidecar.config import DEFAULT_MAX_TOKENS


def count_tokens(text: str, model: str = "claude-sonnet-4-20250514") -> int:
    """Count tokens using tiktoken (approximate for Claude models).

    Note: Claude uses a different tokenizer than OpenAI, but tiktoken provides
    a reasonable approximation for estimation purposes.
    """
    # Use cl100k_base encoding as approximation for Claude
    encoding = tiktoken.get_encoding("cl100k_base")
    return len(encoding.encode(text))


def estimate_cost(tokens: int, model: str = "claude-sonnet-4-20250514") -> float:
    """Estimate API cost based on token count.

    Pricing as of 2025-01 (check anthropic.com/pricing for current rates):
    - Claude Sonnet 4: $3 per million input tokens
    """
    # Pricing per million tokens
    pricing = {
        "claude-sonnet-4-20250514": 3.0,  # Input tokens
        "claude-sonnet-4-5-20250929": 3.0,  # Input tokens
    }

    rate = pricing.get(model, 3.0)
    return (tokens / 1_000_000) * rate


def format_tokens(tokens: int) -> str:
    """Format token count with color coding."""
    if tokens < 1000:
        return f"\033[32m{tokens:,}\033[0m"  # Green
    elif tokens < 5000:
        return f"\033[33m{tokens:,}\033[0m"  # Yellow
    else:
        return f"\033[31m{tokens:,}\033[0m"  # Red


def main():
    parser = argparse.ArgumentParser(
        description="Measure context token usage for Claude Agent SDK prompts"
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--prompt", type=str, help="Prompt text to measure")
    group.add_argument("--file", type=Path, help="File containing prompt text")
    parser.add_argument(
        "--model",
        type=str,
        default="claude-sonnet-4-20250514",
        help="Model to use for pricing (default: claude-sonnet-4-20250514)",
    )

    args = parser.parse_args()

    # Load prompt text
    if args.file:
        if not args.file.exists():
            print(f"❌ File not found: {args.file}")
            sys.exit(1)
        prompt_text = args.file.read_text(encoding="utf-8")
    else:
        prompt_text = args.prompt

    # Count tokens
    token_count = count_tokens(prompt_text, args.model)

    # Calculate metrics
    cost = estimate_cost(token_count, args.model)
    budget_remaining = DEFAULT_MAX_TOKENS - token_count
    budget_percent = (token_count / DEFAULT_MAX_TOKENS) * 100

    # Display results
    print("\n" + "=" * 60)
    print("📊 Context Measurement Results")
    print("=" * 60)
    print(f"\n📝 Prompt length: {len(prompt_text):,} characters")
    print(f"🎯 Token count: {format_tokens(token_count)} tokens")
    print(f"💰 Estimated cost: ${cost:.6f} USD")
    print(f"\n📦 Budget status:")
    print(f"   Total budget: {DEFAULT_MAX_TOKENS:,} tokens")
    print(f"   Used: {token_count:,} tokens ({budget_percent:.1f}%)")

    if budget_remaining > 0:
        print(f"   Remaining: \033[32m{budget_remaining:,} tokens\033[0m ✅")
    else:
        print(f"   \033[31mOver budget by {abs(budget_remaining):,} tokens!\033[0m ❌")

    print(f"\n📚 Model: {args.model}")

    # Recommendations
    print("\n💡 Recommendations:")
    if token_count < 1000:
        print("   ✅ Excellent - well within budget")
    elif token_count < 5000:
        print("   ⚠️  Moderate - consider metadata-first patterns")
    else:
        print("   ❌ High - review context engineering patterns")
        print("      See: docs/reference/claude-agent-sdk.md:Context-Engineering-Best-Practices")

    print("\n" + "=" * 60 + "\n")

    # Exit code reflects budget status
    sys.exit(0 if budget_remaining > 0 else 1)


if __name__ == "__main__":
    main()
