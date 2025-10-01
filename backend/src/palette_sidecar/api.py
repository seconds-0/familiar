"""FastAPI entry points for the native palette sidecar."""

from __future__ import annotations

import json
import logging
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Any

from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse, StreamingResponse

from .auth_coordinator import (
    refresh_claude_auth_state,
    trigger_claude_login,
    trigger_claude_logout,
)
from .claude_service import session
from .config import (
    AUTH_MODE_API_KEY,
    AUTH_MODE_CLAUDE,
    apply_auth_environment,
    detect_prerequisites,
    ensure_workspace,
    load_settings,
    register_always_allow,
    save_settings,
    settings_response_payload,
)
from .models import ApprovalPayload, QueryPayload, SettingsPayload
from .permissions import broker
from .zero_state import generate_suggestions


logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle application lifecycle events."""
    # Startup
    await _sync_claude_session_state()
    await session.start()
    yield
    # Shutdown
    await session.shutdown()


app = FastAPI(title="Familiar Sidecar", lifespan=lifespan)

_current_settings = load_settings()
_workspace_path: Path | None = None

if _current_settings.workspace:
    try:
        _workspace_path = ensure_workspace(_current_settings.workspace)
        _current_settings.workspace = str(_workspace_path)
    except Exception as exc:  # pragma: no cover - defensive
        raise RuntimeError(f"Failed to prepare workspace: {exc}") from exc

apply_auth_environment(_current_settings)

if _workspace_path:
    session.configure(
        api_key=_current_settings.anthropic_api_key,
        workspace=_workspace_path,
        always_allow=_current_settings.always_allow,
        auth_mode=_current_settings.auth_mode,
        claude_session_active=_current_settings.claude_session_active,
        claude_account=_current_settings.claude_account,
    )
else:
    session.configure(
        api_key=_current_settings.anthropic_api_key,
        always_allow=_current_settings.always_allow,
        auth_mode=_current_settings.auth_mode,
        claude_session_active=_current_settings.claude_session_active,
        claude_account=_current_settings.claude_account,
    )

save_settings(_current_settings)


def _format_sse(event: dict[str, Any]) -> str:
    return f"data: {json.dumps(event, ensure_ascii=False)}\n\n"


async def _sync_claude_session_state() -> None:
    if _current_settings.auth_mode != AUTH_MODE_CLAUDE:
        return

    try:
        status_obj = await refresh_claude_auth_state()
    except Exception as exc:  # pragma: no cover - defensive
        logger.debug("Failed to refresh Claude session state: %s", exc)
        return

    _current_settings.claude_session_active = status_obj.active
    _current_settings.claude_account = status_obj.account
    save_settings(_current_settings)


@app.post("/query")
async def query(payload: QueryPayload) -> StreamingResponse:
    session_id = payload.session_id or "default"

    async def event_stream():
        async for event in session.stream(payload.prompt, session_id=session_id):
            yield _format_sse(event)

    headers = {"Cache-Control": "no-cache", "Connection": "keep-alive"}
    return StreamingResponse(event_stream(), media_type="text/event-stream", headers=headers)


@app.post("/approve")
async def approve(payload: ApprovalPayload) -> dict[str, str]:
    if payload.decision not in {"allow", "deny"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Decision must be 'allow' or 'deny'",
        )
    try:
        await broker.resolve(payload.request_id, payload.decision)
    except KeyError as exc:  # pragma: no cover - defensive
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc

    context = await session.notify_permission_resolution(
        payload.request_id,
        payload.decision,
        remember=payload.remember,
    )

    if payload.remember and payload.decision == "allow" and context:
        path_value = context.get("path")
        tool_name = context.get("tool")
        if path_value and tool_name:
            register_always_allow(_current_settings, tool=tool_name, path=Path(path_value))
            save_settings(_current_settings)
            session.configure(always_allow=_current_settings.always_allow)

    return {"status": "ok"}


@app.get("/settings")
async def get_settings() -> dict[str, Any]:
    return settings_response_payload(_current_settings)


@app.post("/settings")
async def update_settings(payload: SettingsPayload) -> JSONResponse:
    global _workspace_path

    if payload.anthropic_api_key is not None:
        key = payload.anthropic_api_key.strip() or None
        _current_settings.anthropic_api_key = key

    if payload.auth_mode is not None:
        mode = payload.auth_mode.strip() or AUTH_MODE_CLAUDE
        if mode not in {AUTH_MODE_API_KEY, AUTH_MODE_CLAUDE}:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unsupported auth mode: {mode}",
            )
        _current_settings.auth_mode = mode
        if mode == AUTH_MODE_API_KEY:
            _current_settings.claude_session_active = False
            _current_settings.claude_account = None
        else:
            # Reset cached status; UI will trigger login flow as needed.
            _current_settings.claude_session_active = False

    if payload.workspace is not None:
        workspace_value = payload.workspace.strip()
        if not workspace_value:
            _workspace_path = None
            _current_settings.workspace = None
        else:
            try:
                _workspace_path = ensure_workspace(workspace_value)
                _current_settings.workspace = str(_workspace_path)
            except Exception as exc:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc

    apply_auth_environment(_current_settings)

    save_settings(_current_settings)
    if _workspace_path:
        session.configure(
            api_key=_current_settings.anthropic_api_key,
            workspace=_workspace_path,
            always_allow=_current_settings.always_allow,
            auth_mode=_current_settings.auth_mode,
            claude_session_active=_current_settings.claude_session_active,
            claude_account=_current_settings.claude_account,
        )
    else:
        session.configure(
            api_key=_current_settings.anthropic_api_key,
            always_allow=_current_settings.always_allow,
            auth_mode=_current_settings.auth_mode,
            claude_session_active=_current_settings.claude_session_active,
            claude_account=_current_settings.claude_account,
        )

    if _current_settings.auth_mode == AUTH_MODE_CLAUDE:
        await _sync_claude_session_state()

    await session.start()
    return JSONResponse(settings_response_payload(_current_settings))


def _auth_response(status_obj) -> dict[str, Any]:
    response = {
        "active": status_obj.active,
        "account": status_obj.account,
        "pending": status_obj.pending,
    }
    if status_obj.message:
        response["message"] = status_obj.message
    if status_obj.login_url:
        response["loginUrl"] = status_obj.login_url
    return response


@app.post("/auth/claude/login")
async def auth_claude_login() -> dict[str, Any]:
    if _current_settings.auth_mode != AUTH_MODE_CLAUDE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Switch to Claude.ai login mode before initiating login",
        )

    status_obj = await trigger_claude_login()
    _current_settings.claude_session_active = status_obj.active
    _current_settings.claude_account = status_obj.account
    save_settings(_current_settings)

    return _auth_response(status_obj)


@app.post("/auth/claude/logout")
async def auth_claude_logout() -> dict[str, Any]:
    status_obj = await trigger_claude_logout()
    _current_settings.claude_session_active = status_obj.active
    _current_settings.claude_account = status_obj.account
    save_settings(_current_settings)

    return _auth_response(status_obj)


@app.get("/auth/claude/status")
async def auth_claude_status() -> dict[str, Any]:
    status_obj = await refresh_claude_auth_state()
    _current_settings.claude_session_active = status_obj.active
    _current_settings.claude_account = status_obj.account
    save_settings(_current_settings)

    return _auth_response(status_obj)


@app.get("/health")
async def health() -> dict[str, Any]:
    checks = detect_prerequisites()
    missing = [name for name, ok in checks.items() if not ok]
    status_value = "ok" if not missing else "degraded"
    return {"status": status_value, "missing": missing}


@app.post("/zero-state/suggestions")
async def zero_state_suggestions() -> dict[str, Any]:
    """Generate AI-powered zero state suggestions."""
    try:
        suggestions = await generate_suggestions(count=4)
        return {"suggestions": suggestions}
    except Exception as e:
        logger.error(f"Zero state endpoint error: {e}")
        # Return fallback on any error
        return {
            "suggestions": [
                "Organize something that needs tidying",
                "Create something new",
                "Learn about a topic you're curious about",
                "Solve a problem you're facing"
            ]
        }


@app.get("/zero-state/suggestions")
async def zero_state_suggestions_get() -> dict[str, Any]:
    """Idempotent variant of zero state suggestions."""
    return await zero_state_suggestions()
