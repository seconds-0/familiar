import Foundation

/// Health status response from the sidecar backend.
///
/// **Schema Contract:**
/// This model must stay synchronized with the `/health` endpoint in
/// `backend/src/palette_sidecar/api.py`.
struct HealthStatus: Decodable {
    /// Status of the backend: "initializing", "ready", or "degraded"
    let status: String

    /// List of missing prerequisites (only present when status is "degraded")
    let missing: [String]?
}