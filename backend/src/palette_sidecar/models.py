"""Pydantic models for request/response payloads."""

from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class QueryPayload(BaseModel):
    prompt: str
    session_id: str | None = None


class ApprovalPayload(BaseModel):
    request_id: str
    decision: str
    remember: bool = False


class SettingsPayload(BaseModel):
    """Incoming settings update request."""
    anthropic_api_key: str | None = None
    workspace: str | None = None
    auth_mode: str | None = None


class SettingsResponse(BaseModel):
    """Settings response with camelCase field names for Swift client.

    Schema Contract:
    ----------------
    This model must stay synchronized with `SidecarSettings` in
    `apps/mac/FamiliarApp/Sources/FamiliarApp/Models/SidecarSettings.swift`.

    Field aliases define the JSON key names sent to Swift. The Swift model
    decodes these camelCase keys directly.
    """

    model_config = ConfigDict(populate_by_name=True)

    has_api_key: bool = Field(alias="hasApiKey")
    has_claude_session: bool = Field(alias="hasClaudeSession")
    claude_account_email: str | None = Field(alias="claudeAccountEmail")
    workspace: str | None
    workspace_demo_file: str | None = Field(alias="workspaceDemoFile")
    always_allow: dict[str, list[str]] = Field(alias="alwaysAllow")
    default_workspace: str = Field(alias="defaultWorkspace")
    auth_mode: str = Field(alias="authMode")


class ResumeContextPayload(BaseModel):
    """Small, metadata-first context for generating a resume label."""
    transcript_preview: str | None = None
    path: str | None = None
    project: str | None = None
