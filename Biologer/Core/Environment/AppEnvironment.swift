import Foundation

/// Stable identity of a Biologer server configuration.
public enum EnvironmentID: String, Codable, CaseIterable, Sendable {
    /// Production server for Serbia.
    case serbia = "rs"

    /// Production server for Croatia.
    case croatia = "hr"

    /// Production server for Bosnia and Herzegovina.
    case bosniaAndHerzegovina = "ba"

    /// Production server for Montenegro.
    case montenegro = "me"

    /// Shared development server.
    case development = "dev"
}

/// Runtime server configuration. Only its stable ID is persisted; endpoints and
/// credentials are rebuilt from the current app version.
public struct AppEnvironment: Equatable, Sendable {
    /// Stable environment identity persisted by the app.
    public let id: EnvironmentID

    /// OAuth client identifier supplied by the current build.
    public let clientId: String

    /// OAuth client secret supplied by the current build.
    public let clientSecret: String

    /// API host without a URL scheme.
    public let host: String

    /// Locale-specific path prefix used by web pages.
    public let path: String

    public init(
        id: EnvironmentID,
        host: String,
        path: String,
        clientSecret: String,
        clientId: String
    ) {
        self.id = id
        self.host = host
        self.path = path
        self.clientSecret = clientSecret
        self.clientId = clientId
    }
}
