from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from palette_sidecar import api
from palette_sidecar import config as sidecar_config
from palette_sidecar import claude_service
from palette_sidecar.claude_service import ClaudeCLIUnavailableError


class StubStatus:
    def __init__(
        self,
        active: bool,
        account: str | None = None,
        message: str | None = None,
        login_url: str | None = None,
        pending: bool = False,
    ) -> None:
        self.active = active
        self.account = account
        self.message = message
        self.login_url = login_url
        self.pending = pending


def test_settings_payload_includes_auth_fields() -> None:
    with TestClient(api.app) as client:
        response = client.get("/settings")

    payload = response.json()
    assert "authMode" in payload
    assert "hasClaudeSession" in payload
    assert "claudeAccountEmail" in payload


def test_claude_login_endpoint(monkeypatch) -> None:
    async def fake_login():  # type: ignore[return-type]
        return StubStatus(active=True, account="tester@example.com", message="Logged in")

    called = False

    def fake_save_settings(settings):  # type: ignore[return-type]
        nonlocal called
        called = True

    monkeypatch.setattr(api, "trigger_claude_login", fake_login)
    monkeypatch.setattr(api, "save_settings", fake_save_settings)

    api._current_settings.auth_mode = sidecar_config.AUTH_MODE_CLAUDE

    with TestClient(api.app) as client:
        response = client.post("/auth/claude/login")

    data = response.json()
    assert data == {
        "active": True,
        "account": "tester@example.com",
        "message": "Logged in",
        "pending": False,
    }
    assert api._current_settings.claude_session_active is True
    assert api._current_settings.claude_account == "tester@example.com"
    assert called is True


def test_claude_status_endpoint(monkeypatch) -> None:
    async def fake_status():  # type: ignore[return-type]
        return StubStatus(active=False, message="Not signed in")

    monkeypatch.setattr(api, "refresh_claude_auth_state", fake_status)
    monkeypatch.setattr(api, "save_settings", lambda settings: None)

    with TestClient(api.app) as client:
        response = client.get("/auth/claude/status")

    data = response.json()
    assert data == {
        "active": False,
        "message": "Not signed in",
        "account": None,
        "pending": False,
    }
    assert api._current_settings.claude_session_active is False
    assert api._current_settings.claude_account is None


@pytest.mark.asyncio
async def test_fetch_status_skips_unknown_option(monkeypatch) -> None:
    calls: list[tuple[str, ...]] = []

    async def fake_run(*args: str) -> tuple[int, str, str]:
        calls.append(args)
        if "--json" in args:
            return 1, "", "error: unknown option '--json'"
        return 0, '{"account": "tester@example.com"}', ""

    monkeypatch.setattr(claude_service, "_run_claude_cli", fake_run)

    status = await claude_service.fetch_claude_session_status()
    assert status.active is True
    assert status.account == "tester@example.com"
    assert len(calls) >= 2


@pytest.mark.asyncio
async def test_login_reports_cli_unavailable(monkeypatch) -> None:
    async def fake_spawn(*args: str):  # type: ignore[return-type]
        raise ClaudeCLIUnavailableError("Claude CLI missing")

    monkeypatch.setattr(claude_service, "_spawn_claude_cli", fake_spawn)

    status = await claude_service.login_coordinator.begin_login()
    assert status.pending is False
    assert status.active is False
    assert status.message == "Claude CLI missing"

    final = await claude_service.login_coordinator.wait_for_completion()
    assert final.pending is False
    assert final.active is False
    assert final.message == "Claude CLI missing"
