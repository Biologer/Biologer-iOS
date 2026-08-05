import Foundation

/// Shared server environment model, independent of authorization UI.
public final class AppEnvironment: Codable {
    public var clientId: String
    public let clientSecret: String
    public let host: String
    public let path: String

    public init(host: String, path: String, clientSecret: String, cliendId: String) {
        self.host = host
        self.path = path
        self.clientSecret = clientSecret
        self.clientId = cliendId
    }

    public func getFileId() -> String {
        switch host {
        case APIConstants.serbiaHost: return "rs"
        case APIConstants.croatiaHost: return "hr"
        case APIConstants.bosnianAndHerzegovinHost: return "ba"
        case APIConstants.montenegroHost: return "me"
        default: return "dev"
        }
    }
}
