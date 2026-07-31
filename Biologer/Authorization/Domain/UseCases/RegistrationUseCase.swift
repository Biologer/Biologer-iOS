import Foundation

protocol RegistrationPersonalInfoValidating {
    func validatePersonalInfo(
        firstName: String,
        lastName: String,
        institution: String
    ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo
}

protocol RegistrationCredentialsValidating {
    func validateCredentials(
        email: String,
        password: String,
        repeatedPassword: String
    ) throws(RegisterUserValidationError) -> RegistrationCredentials
}

protocol RegistrationUseCase:
    RegistrationPersonalInfoValidating,
    RegistrationCredentialsValidating,
    RegisterUserUseCase {
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

    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) -> Void {
        try await registerUseCase.createUser(request: request)
        licensePreferenceUseCase.saveLicense(
            RegistrationLicensePreference(id: request.dataLicenseId, kind: .data)
        )
        licensePreferenceUseCase.saveLicense(
            RegistrationLicensePreference(id: request.imageLicenseId, kind: .image)
        )
    }
}
