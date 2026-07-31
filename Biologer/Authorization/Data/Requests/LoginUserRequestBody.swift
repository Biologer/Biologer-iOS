import Foundation

struct LoginUserRequestBody: Encodable {
    let username: String
    let password: String
    let scope: String
    let clientSecret: String
    let clientId: String
    let grantType: String

    enum CodingKeys: String, CodingKey {
        case username
        case password
        case scope
        case clientSecret = "client_secret"
        case clientId = "client_id"
        case grantType = "grant_type"
    }
}
