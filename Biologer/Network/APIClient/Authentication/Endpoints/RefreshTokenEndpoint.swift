import Foundation

struct RefreshTokenEndpoint: APIEndpoint {
    typealias Response = RefreshTokenResponse

    let host: String
    let path = APIConstants.loginUserPath
    let method: APIHTTPMethod = .post
    let body: APIRequestBody

    init(
        refreshToken: String,
        host: String,
        clientId: String,
        clientSecret: String
    ) {
        self.host = host
        body = .json(
            RefreshTokenRequestBody(
                refreshToken: refreshToken,
                scope: APIConstants.scope,
                clientSecret: clientSecret,
                clientId: clientId,
                grantType: APIConstants.grantTypeRefreshToken
            )
        )
    }
}
