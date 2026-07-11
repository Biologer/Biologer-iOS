import Foundation

protocol RegisterUserUseCase {
    func createUser(user: RegistrationDraft) async throws(APIError) -> Void
    func updatePersonalInfo(
        username: String,
        lastName: String,
        institution: String,
        for user: RegistrationDraft
    ) throws(RegisterUserValidationError)
    func updateCredentials(
        email: String,
        password: String,
        repeatedPassword: String,
        for user: RegistrationDraft
    ) throws(RegisterUserValidationError)
    func saveData(license: CheckMarkItem)
    func saveImage(license: CheckMarkItem)
    var environment: Environment? { get }
}

final class RemoteRegisterUserUseCase: RegisterUserUseCase {
    private let client: APIClientProtocol
    private let environmentStorage: EnvironmentStorage
    private let tokenStorage: TokenStorage
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage

    var environment: Environment? {
        return environmentStorage.getEnvironment()
    }

    public init(
        client: APIClientProtocol,
        environmentStorage: EnvironmentStorage,
        tokenStorage: TokenStorage,
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage
    ) {
        self.client = client
        self.environmentStorage = environmentStorage
        self.tokenStorage = tokenStorage
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
    }

    func saveData(license: CheckMarkItem) {
        dataLicenseStorage.saveLicense(license: license)
    }

    func saveImage(license: CheckMarkItem) {
        imageLicenseStorage.saveLicense(license: license)
    }

    func updatePersonalInfo(
        username: String,
        lastName: String,
        institution: String,
        for user: RegistrationDraft
    ) throws(RegisterUserValidationError) {
        guard AuthInputValidator.isNotEmpty(value: username) else {
            throw .emptyUsername
        }

        guard AuthInputValidator.isNotEmpty(value: lastName) else {
            throw .emptyLastName
        }

        user.username = username
        user.lastname = lastName
        user.institution = institution
    }

    func updateCredentials(
        email: String,
        password: String,
        repeatedPassword: String,
        for user: RegistrationDraft
    ) throws(RegisterUserValidationError) {
        guard AuthInputValidator.isNotEmpty(value: email) else {
            throw .emptyEmail
        }

        guard AuthInputValidator.isValid(email: email) else {
            throw .invalidEmail
        }

        guard AuthInputValidator.isNotEmpty(value: password) else {
            throw .emptyPassword
        }

        guard AuthInputValidator.isValid(password: password) else {
            throw .invalidPassword
        }

        guard AuthInputValidator.passwordsMatch(password: password, repeatedPassword: repeatedPassword) else {
            throw .passwordsDoNotMatch
        }

        user.email = email
        user.password = password
    }

    func createUser(user: RegistrationDraft) async throws(APIError) -> Void {
        guard let environment = environmentStorage.getEnvironment() else {
            throw APIError(description: ErrorConstant.environmentNotSelected)
        }

        let endpoint = RegisterUserEndpoint(
            user: user,
            host: environment.host,
            clientId: Int(environment.clientId) ?? 0,
            clientSecret: environment.clientSecret
        )

        do {
            let response = try await client.send(endpoint)
            tokenStorage.saveToken(token: Token(response))
            return
        } catch let error as APIClientError {
            throw error.asAPIError()
        } catch {
            throw APIError(description: error.localizedDescription)
        }
    }
}

private extension Token {
    convenience init(_ response: RegisterUserEndpoint.Response) {
        self.init(accessToken: response.access_token, refreshToken: response.refresh_token)
    }
}

enum RegisterUserValidationError: Error {
    case emptyUsername
    case emptyLastName
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case invalidPassword
    case passwordsDoNotMatch
}
