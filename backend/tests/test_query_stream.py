"""Smoke tests for the /query streaming endpoint."""

from __future__ import annotations

import json
from typing import AsyncIterator

from fastapi.testclient import TestClient

from palette_sidecar.api import app, session


def test_query_stream_emits_permission_then_result(monkeypatch) -> None:
    events = [
        {
            "type": "permission_request",
            "requestId": "abc",
            "toolName": "Write",
            "input": {"path": "note.txt"},
            "path": "note.txt",
        },
        {
            "type": "tool_result",
            "toolUseId": "abc",
            "content": "done",
            "isError": False,
            "path": "note.txt",
        },
    ]

    async def fake_stream(prompt: str, session_id: str = "default") -> AsyncIterator[dict[str, object]]:
        assert prompt == "hello"
        assert session_id == "default"
        for event in events:
            yield event

    monkeypatch.setattr(session, "stream", fake_stream)

    with TestClient(app) as client:
        with client.stream("POST", "/query", json={"prompt": "hello"}) as response:
            streamed = []
            for line in response.iter_lines():
                if not line.startswith("data: "):
                    continue
                payload = json.loads(line.removeprefix("data: "))
                streamed.append(payload)

    assert [item["type"] for item in streamed] == ["permission_request", "tool_result"]
    assert streamed[0]["requestId"] == "abc"
    assert streamed[1]["toolUseId"] == "abc"
