import Foundation

protocol RegistrationUseCase {
    func validatePersonalInfo(
        firstName: String,
        lastName: String,
        institution: String
    ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo

    func validateCredentials(
        email: String,
        password: String,
        repeatedPassword: String
    ) throws(RegisterUserValidationError) -> RegistrationCredentials

    func saveData(license: CheckMarkItem)
    func saveImage(license: CheckMarkItem)
    func createUser(request: RegistrationRequest) async throws(APIError) -> Void
}

final class DefaultRegistrationUseCase: RegistrationUseCase {
    private let validator: RegistrationInputValidating
    private let licensePreferenceUseCase: RegistrationLicensePreferenceUseCase
    private let registerUseCase: RegisterUserUseCase

    init(
        validator: RegistrationInputValidating,
        licensePreferenceUseCase: RegistrationLicensePreferenceUseCase,
        registerUseCase: RegisterUserUseCase
    ) {
        self.validator = validator
        self.licensePreferenceUseCase = licensePreferenceUseCase
        self.registerUseCase = registerUseCase
    }

    func validatePersonalInfo(
        firstName: String,
        lastName: String,
        institution: String
    ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo {
        try validator.validatePersonalInfo(
            firstName: firstName,
            lastName: lastName,
            institution: institution
        )
    }

    func validateCredentials(
        email: String,
        password: String,
        repeatedPassword: String
    ) throws(RegisterUserValidationError) -> RegistrationCredentials {
        try validator.validateCredentials(
            email: email,
            password: password,
            repeatedPassword: repeatedPassword
        )
    }

    func saveData(license: CheckMarkItem) {
        licensePreferenceUseCase.saveData(license: license)
    }

    func saveImage(license: CheckMarkItem) {
        licensePreferenceUseCase.saveImage(license: license)
    }

    func createUser(request: RegistrationRequest) async throws(APIError) -> Void {
        try await registerUseCase.createUser(request: request)
    }
}
