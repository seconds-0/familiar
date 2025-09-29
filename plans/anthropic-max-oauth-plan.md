# Anthropic Max OAuth Integration Plan

## Goals

- Provide a first-class "Sign in with Anthropic" experience that supports Anthropic Max subscriptions.
- Prefer Anthropic OAuth tokens over locally stored API keys, falling back automatically when tokens fail.
- Keep the experience aligned with the Claude Code SDK guidance in `docs/claude-code-sdk.md`.

## 1. Research & External Requirements

- Confirm Anthropic OAuth discovery endpoints, required scopes, and PKCE usage for Max accounts.
- Determine client registration steps (redirect URIs, client ID/secret) and document required environment variables.
- Identify token-to-API compatibility: how OAuth access tokens map to Claude SDK authentication and expected expiration policy.
- Review `docs/claude-code-sdk.md` for any SDK expectations around environment variables, permission hooks, or session setup that may need adjustments when tokens rotate.

## 2. Configuration & Storage Design

- Extend sidecar `Settings` dataclass and persisted JSON to store OAuth metadata (access token, refresh token, expiry, token_type, scope).
- Define secure storage on macOS: Keychain entry for OAuth secrets (mirroring current API key handling) with identifiers like `anthropic_oauth_access_token` and `anthropic_oauth_refresh_token`.
- Update `SidecarSettings` Swift model and decode logic to surface OAuth status flags (e.g., `hasOAuthToken`, `oauthExpiresAt`).
- Document migration behavior when existing users upgrade (e.g., default `null` values, versioning safeguards).

## 3. Backend Sidecar Enhancements

- **Auth Routes**
  - `GET /auth/anthropic/start`: generate PKCE verifier/challenge, store verifier in encrypted cache, and return the Anthropic authorization URL.
  - `GET /auth/anthropic/callback`: handle redirect (code + state), exchange code for tokens, persist securely, update session configuration, and return success status to the macOS app.
  - `POST /auth/anthropic/logout`: revoke tokens (if Anthropic supports it) or clear stored credentials and reset session.
  - `GET /auth/anthropic/status`: expose current auth state (connected, expires_at, fallback available) for the Settings UI.
- **Token Lifecycle**
  - Implement background refresh utility that renews access tokens before expiry using the refresh token; persist updates.
  - On refresh failure, clear OAuth state and allow API-key fallback.
- **Session Integration**
  - Update `claude_service.ClaudeSession.configure` to accept OAuth tokens and set SDK options accordingly (e.g., use `options.env` or explicit header overrides respecting `docs/claude-code-sdk.md`).
  - When streaming, attempt OAuth authorization first; on authentication errors (401/403), trigger refresh once, then fall back to API key if the token remains invalid.
- **Settings Payload**
  - Augment responses from `/settings` and `/settings` POST to include OAuth status fields (`hasOAuthToken`, `oauthExpiresAt`, `oauthProvider`).

## 4. macOS Frontend Updates

- **Networking Layer**
  - Add a new `AnthropicAuthClient` Swift actor to wrap the sidecar routes (start login, poll status, disconnect).
  - Handle the local loopback callback or custom URL scheme to receive OAuth redirects in the macOS app and forward them to the sidecar.
- **Settings UI**
  - Introduce an "Anthropic Max Login" section displaying:
    - Current status (Connected, Expires soon, Not connected).
    - `Connect…` button that opens the browser authorization flow and waits for completion.
    - `Refresh`/`Disconnect` actions, plus fallback messaging when only an API key is present.
  - When connected, disable or de-emphasize manual API key entry while keeping it available as backup.
- **App State**
  - Extend `AppState.apply(settings:)` to track OAuth availability and choose authentication mode when issuing queries.
  - Ensure prompt composer indicators (status messages) reflect OAuth readiness.

## 5. Query Execution Preference & Fallback

- Modify request-building paths (Swift client → sidecar) so that:
  - OAuth tokens are injected into the Claude SDK configuration/environment.
  - Errors indicating invalid/expired tokens trigger refresh attempts.
  - On repeated failures, the session automatically reconfigures with the stored API key, logging the fallback event.
- Surface fallback events to the UI (e.g., warning banner in Settings) so users know the API key is currently active.

## 6. Testing Strategy

- **Backend**
  - FastAPI unit tests covering: start URL generation (with PKCE), successful callback exchange (mock token endpoint), refresh flow, logout, and fallback on refresh failure.
- **Frontend**
  - Swift unit tests for `AnthropicAuthClient` state transitions and `SettingsView` bindings (e.g., snapshot/integration tests verifying status display).
  - UI automation checklist: connect via OAuth, verify token expiry countdown, force token refresh, trigger fallback by revoking consent, ensure API key rescue works.
- **Integration**
  - Manual regression scenario ensuring Claude queries prefer OAuth, but continue to work with the API key when OAuth tokens are absent or invalid.

## 7. Documentation & Rollout

- Update user-facing docs or in-app tooltips describing Anthropic Max login, privacy considerations, and fallback behavior.
- Provide upgrade notes for existing installations explaining new settings and how to migrate from API key usage.
- Add troubleshooting section covering common OAuth failures (expired tokens, redirect issues, missing scopes).
