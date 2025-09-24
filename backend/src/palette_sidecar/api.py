"""FastAPI entry points for the native palette sidecar."""

from __future__ import annotations

from fastapi import FastAPI, HTTPException
from fastapi.responses import Response, StreamingResponse

from .claude_service import session
from .models import ApprovalPayload, QueryPayload
from .permissions import broker

app = FastAPI(title="Palette Sidecar")


@app.on_event("startup")
async def _startup() -> None:
    await session.start()


@app.on_event("shutdown")
async def _shutdown() -> None:
    await session.shutdown()


@app.post("/query")
async def query(payload: QueryPayload) -> Response:
    async def event_stream():
        async for chunk in session.stream(payload.prompt):
            yield f"data: {chunk}\n\n"

    headers = {"Cache-Control": "no-cache", "Connection": "keep-alive"}
    return StreamingResponse(event_stream(), media_type="text/event-stream", headers=headers)


@app.post("/approve")
async def approve(payload: ApprovalPayload) -> dict[str, str]:
    try:
        await broker.resolve(payload.request_id, payload.decision)
    except KeyError as exc:  # pragma: no cover - defensive
        raise HTTPException(status_code=404, detail=str(exc)) from exc
    return {"status": "ok"}


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
