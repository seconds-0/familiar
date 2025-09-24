"""Pydantic models for request/response payloads."""

from __future__ import annotations

from pydantic import BaseModel


class QueryPayload(BaseModel):
    prompt: str
    session_id: str | None = None


class ApprovalPayload(BaseModel):
    request_id: str
    decision: str


class SettingsPayload(BaseModel):
    anthropic_api_key: str | None = None
    workspace: str | None = None
