import Foundation

struct RegisterUserEndpoint: APIEndpoint {
    typealias Response = RegisterUserResponse

    let host: String
    let path = APIConstants.registerUserPath
    let method: APIHTTPMethod = .post
    let body: APIRequestBody

    init(request: RegistrationRequest, host: String, clientId: Int, clientSecret: String) {
        self.host = host
        body = .json(
            RegisterUserRequestBody(
                clientId: clientId,
                clientSecret: clientSecret,
                firstName: request.firstName,
                lastName: request.lastName,
                dataLicense: request.dataLicenseId,
                imageLicense: request.imageLicenseId,
                institution: request.institution,
                email: request.email,
                password: request.password
            )
        )
    }
}
