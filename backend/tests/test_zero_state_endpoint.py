from __future__ import annotations

from fastapi.testclient import TestClient

from palette_sidecar import api


def test_zero_state_suggestions_returns_generated_list(monkeypatch) -> None:
    async def fake_generate_suggestions(count: int = 4):  # type: ignore[return-type]
        return [
            "Organize messy downloads folder",
            "Draft a friendly status update",
            "Explain how this works",
            "Try something a bit magical",
        ][:count]

    monkeypatch.setattr(api, "generate_suggestions", fake_generate_suggestions)

    with TestClient(api.app) as client:
        response = client.post("/zero-state/suggestions")

    assert response.status_code == 200
    data = response.json()
    assert "suggestions" in data
    assert len(data["suggestions"]) == 4
    assert data["suggestions"][0] == "Organize messy downloads folder"


def test_zero_state_suggestions_fallback_on_error(monkeypatch) -> None:
    async def boom(count: int = 4):  # type: ignore[return-type]
        raise RuntimeError("oops")

    monkeypatch.setattr(api, "generate_suggestions", boom)

    with TestClient(api.app) as client:
        response = client.post("/zero-state/suggestions")

    assert response.status_code == 200
    data = response.json()
    assert "suggestions" in data
    assert len(data["suggestions"]) == 4
    # Ensure we hit the known fallback phrase
    assert data["suggestions"][0] == "Organize something that needs tidying"


def test_zero_state_suggestions_get_variant(monkeypatch) -> None:
    async def fake_generate_suggestions(count: int = 4):  # type: ignore[return-type]
        return ["A", "B", "C", "D"][:count]

    monkeypatch.setattr(api, "generate_suggestions", fake_generate_suggestions)

    with TestClient(api.app) as client:
        response = client.get("/zero-state/suggestions")

    assert response.status_code == 200
    data = response.json()
    assert data == {"suggestions": ["A", "B", "C", "D"]}
