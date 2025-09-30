from __future__ import annotations

import asyncio
from typing import AsyncIterator

from palette_sidecar import zero_state


class _FakeStream:
    def __init__(self, chunks: list[str]):
        self._chunks = chunks

    def __aiter__(self):
        return self._gen()

    async def _gen(self):
        for text in self._chunks:
            yield {"type": "assistant_text", "text": text}
            await asyncio.sleep(0)


async def _fake_stream(_prompt: str, session_id: str = "default") -> AsyncIterator[dict[str, object]]:  # type: ignore[override]
    # Return code-fenced JSON split across chunks
    data = [
        "```json\n",
        "[\n",
        '  "One",\n',
        '  "Two",\n',
        '  "Three",\n',
        '  "Four"\n',
        "]\n",
        "```",
    ]
    async for ev in _FakeStream(data):
        yield ev


def test_generate_suggestions_strips_code_fences(monkeypatch):
    monkeypatch.setattr(zero_state, "session", type("_S", (), {"stream": staticmethod(_fake_stream)}))

    got = asyncio.run(zero_state.generate_suggestions(count=4))
    assert got == ["One", "Two", "Three", "Four"]

