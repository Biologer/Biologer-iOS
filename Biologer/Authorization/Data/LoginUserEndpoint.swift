import Foundation

struct LoginUserEndpoint: APIEndpoint {
    typealias Response = LoginUserResponse

    let host: String
    let path = APIConstants.loginUserPath
    let method: APIHTTPMethod = .post
    let body: APIRequestBody

    init(email: String, password: String, host: String, clientId: String, clientSecret: String) {
        self.host = host
        body = .json(
            LoginUserRequestBody(
                username: email,
                password: password,
                scope: APIConstants.scope,
                clientSecret: clientSecret,
                clientId: clientId,
                grantType: APIConstants.grantTypePassword
            )
        )
    }
}

private struct LoginUserRequestBody: Encodable {
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
