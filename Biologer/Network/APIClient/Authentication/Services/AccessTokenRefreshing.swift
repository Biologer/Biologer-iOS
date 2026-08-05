import Foundation

protocol AccessTokenRefreshing {
    func refreshAccessToken(for session: TokenSnapshot) async throws -> String
}

struct TokenSnapshot: Hashable, Sendable {
    let accessToken: String
    let refreshToken: String
}

enum AccessTokenRefreshError: Error {
    case sessionExpired(APIErrorPayload?)
    case sessionChanged
}
