import Foundation

struct LoginUserEndpoint: APIEndpoint {
    typealias Response = AuthorizationTokenResponse

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
