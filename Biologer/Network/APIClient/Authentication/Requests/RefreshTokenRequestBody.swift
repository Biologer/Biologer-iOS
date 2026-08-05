import Foundation

struct RefreshTokenRequestBody: Encodable {
    let refreshToken: String
    let scope: String
    let clientSecret: String
    let clientId: String
    let grantType: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case scope
        case clientSecret = "client_secret"
        case clientId = "client_id"
        case grantType = "grant_type"
    }
}
