"""In-memory broker for coordinating tool permissions between SDK and UI."""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from typing import Any


@dataclass
class PendingDecision:
    future: asyncio.Future[str]
    payload: dict[str, Any]


class PermissionBroker:
    """Tracks pending permission requests and resolves them when the UI responds."""

    def __init__(self) -> None:
        self._pending: dict[str, PendingDecision] = {}
        self._lock = asyncio.Lock()

    async def register(self, request_id: str, payload: dict[str, Any]) -> asyncio.Future[str]:
        """Register a permission request and return a future resolved on decision."""

        async with self._lock:
            if request_id in self._pending:
                raise ValueError(f"Duplicate permission request id {request_id}")
            loop = asyncio.get_running_loop()
            future: asyncio.Future[str] = loop.create_future()
            self._pending[request_id] = PendingDecision(future=future, payload=payload)
            return future

    async def resolve(self, request_id: str, decision: str) -> dict[str, Any]:
        """Resolve a pending permission request and return its payload."""

        async with self._lock:
            pending = self._pending.pop(request_id, None)
        if pending is None:
            raise KeyError(f"No pending permission for {request_id}")
        pending.future.set_result(decision)
        return pending.payload

    async def get_payload(self, request_id: str) -> dict[str, Any] | None:
        async with self._lock:
            pending = self._pending.get(request_id)
            return pending.payload if pending else None


broker = PermissionBroker()
