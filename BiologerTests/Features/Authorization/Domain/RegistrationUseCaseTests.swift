import XCTest
@testable import Biologer

final class RegistrationUseCaseTests: XCTestCase {
    private var validator: RegistrationValidatorSpy!
    private var licensePreferenceUseCase: RegistrationLicensePreferenceUseCaseSpy!
    private var registerUseCase: RegisterUserUseCaseSpy!
    private var sut: DefaultRegistrationUseCase!

    override func setUp() {
        super.setUp()
        validator = RegistrationValidatorSpy()
        licensePreferenceUseCase = RegistrationLicensePreferenceUseCaseSpy()
        registerUseCase = RegisterUserUseCaseSpy()
        sut = DefaultRegistrationUseCase(
            validator: validator,
            licensePreferenceUseCase: licensePreferenceUseCase,
            registerUseCase: registerUseCase
        )
    }

    override func tearDown() {
        sut = nil
        registerUseCase = nil
        licensePreferenceUseCase = nil
        validator = nil
        super.tearDown()
    }

    func test_validatePersonalInfo_delegatesToValidator() throws {
        let personalInfo = try sut.validatePersonalInfo(
            firstName: "Nikola",
            lastName: "Popovic",
            institution: "Biologer"
        )

        XCTAssertEqual(validator.personalInfoInputs?.firstName, "Nikola")
        XCTAssertEqual(validator.personalInfoInputs?.lastName, "Popovic")
        XCTAssertEqual(validator.personalInfoInputs?.institution, "Biologer")
        XCTAssertEqual(personalInfo, validator.personalInfoResult)
    }

    func test_validateCredentials_delegatesToValidator() throws {
        let credentials = try sut.validateCredentials(
            email: "nikola@example.com",
            password: "Password1",
            repeatedPassword: "Password1"
        )

        XCTAssertEqual(validator.credentialsInputs?.email, "nikola@example.com")
        XCTAssertEqual(validator.credentialsInputs?.password, "Password1")
        XCTAssertEqual(validator.credentialsInputs?.repeatedPassword, "Password1")
        XCTAssertEqual(credentials, validator.credentialsResult)
    }

    func test_createUser_registersUserAndPersistsBothLicensePreferences() async throws {
        let request = makeRequest()

        try await sut.createUser(request: request)

        XCTAssertEqual(registerUseCase.createdRequest, request)
        XCTAssertEqual(
            licensePreferenceUseCase.savedPreferences,
            [
                RegistrationLicensePreference(id: 10, kind: .data),
                RegistrationLicensePreference(id: 20, kind: .image)
            ]
        )
    }

    func test_createUser_propagatesRegisterError() async {
        let expectedError = AuthorizationFailure(message: "Register failed")
        registerUseCase.createUserResult = .failure(expectedError)

        do {
            try await sut.createUser(request: makeRequest())
            XCTFail("Expected createUser to throw.")
        } catch {
            XCTAssertEqual(error, expectedError)
            XCTAssertTrue(licensePreferenceUseCase.savedPreferences.isEmpty)
        }
    }

    private func makeRequest() -> RegistrationRequest {
        RegistrationRequest(
            firstName: "Nikola",
            lastName: "Popovic",
            institution: "Biologer",
            email: "nikola@example.com",
            password: "Password1",
            dataLicenseId: 10,
            imageLicenseId: 20
        )
    }

}

private final class RegistrationValidatorSpy: RegistrationInputValidating {
    var personalInfoInputs: (firstName: String, lastName: String, institution: String)?
    var credentialsInputs: (email: String, password: String, repeatedPassword: String)?
    var personalInfoResult = RegistrationPersonalInfo(
        firstName: "Validated first name",
        lastName: "Validated last name",
        institution: "Validated institution"
    )
    var credentialsResult = RegistrationCredentials(
        email: "validated@example.com",
        password: "Validated1"
    )

    func validatePersonalInfo(
        firstName: String,
        lastName: String,
        institution: String
    ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo {
        personalInfoInputs = (firstName, lastName, institution)
        return personalInfoResult
    }

    func validateCredentials(
        email: String,
        password: String,
        repeatedPassword: String
    ) throws(RegisterUserValidationError) -> RegistrationCredentials {
        credentialsInputs = (email, password, repeatedPassword)
        return credentialsResult
    }
}

private final class RegistrationLicensePreferenceUseCaseSpy: RegistrationLicensePreferenceUseCase {
    var savedPreferences: [RegistrationLicensePreference] = []

    func saveLicense(_ preference: RegistrationLicensePreference) {
        savedPreferences.append(preference)
    }
}

private final class RegisterUserUseCaseSpy: RegisterUserUseCase {
    var createdRequest: RegistrationRequest?
    var createUserResult: Result<Void, AuthorizationFailure> = .success(())

    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) -> Void {
        createdRequest = request
        switch createUserResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}
