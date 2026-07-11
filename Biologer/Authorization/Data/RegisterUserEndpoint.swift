import Foundation

struct RegisterUserEndpoint: APIEndpoint {
    typealias Response = RegisterUserResponse

    let host: String
    let path = APIConstants.registerUserPath
    let method: APIHTTPMethod = .post
    let body: APIRequestBody

    init(user: RegistrationDraft, host: String, clientId: Int, clientSecret: String) {
        self.host = host
        body = .json(
            RegisterUserRequestBody(
                clientId: clientId,
                clientSecret: clientSecret,
                firstName: user.username,
                lastName: user.lastname,
                dataLicense: user.dataLicense.id,
                imageLicense: user.imageLicense.id,
                institution: user.institution,
                email: user.email,
                password: user.password
            )
        )
    }
}

private struct RegisterUserRequestBody: Encodable {
    let clientId: Int
    let clientSecret: String
    let firstName: String
    let lastName: String
    let dataLicense: Int
    let imageLicense: Int
    let institution: String?
    let email: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case firstName = "first_name"
        case lastName = "last_name"
        case dataLicense = "data_license"
        case imageLicense = "image_license"
        case institution
        case email
        case password
    }
}
