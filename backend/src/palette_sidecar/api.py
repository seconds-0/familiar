"""FastAPI entry points for the native palette sidecar."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse, StreamingResponse

from .claude_service import session
from .config import (
    apply_environment,
    detect_prerequisites,
    ensure_workspace,
    load_settings,
    register_always_allow,
    save_settings,
    settings_response_payload,
)
from .models import ApprovalPayload, QueryPayload, SettingsPayload
from .permissions import broker

app = FastAPI(title="Palette Sidecar")

_current_settings = load_settings()
_workspace_path: Path | None = None

if _current_settings.workspace:
    try:
        _workspace_path = ensure_workspace(_current_settings.workspace)
        _current_settings.workspace = str(_workspace_path)
    except Exception as exc:  # pragma: no cover - defensive
        raise RuntimeError(f"Failed to prepare workspace: {exc}") from exc

if _current_settings.anthropic_api_key:
    apply_environment(_current_settings.anthropic_api_key)

if _workspace_path:
    session.configure(
        api_key=_current_settings.anthropic_api_key,
        workspace=_workspace_path,
        always_allow=_current_settings.always_allow,
    )
else:
    session.configure(
        api_key=_current_settings.anthropic_api_key,
        always_allow=_current_settings.always_allow,
    )

save_settings(_current_settings)


def _format_sse(event: dict[str, Any]) -> str:
    return f"data: {json.dumps(event, ensure_ascii=False)}\n\n"


@app.on_event("startup")
async def _startup() -> None:
    await session.start()


@app.on_event("shutdown")
async def _shutdown() -> None:
    await session.shutdown()


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
        apply_environment(key)

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

    save_settings(_current_settings)
    if _workspace_path:
        session.configure(
            api_key=_current_settings.anthropic_api_key,
            workspace=_workspace_path,
            always_allow=_current_settings.always_allow,
        )
    else:
        session.configure(
            api_key=_current_settings.anthropic_api_key,
            always_allow=_current_settings.always_allow,
        )

    await session.start()
    return JSONResponse(settings_response_payload(_current_settings))


@app.get("/health")
async def health() -> dict[str, Any]:
    checks = detect_prerequisites()
    missing = [name for name, ok in checks.items() if not ok]
    status_value = "ok" if not missing else "degraded"
    return {"status": status_value, "missing": missing}
