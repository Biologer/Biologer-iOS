import XCTest
@testable import Biologer

@MainActor
final class AuthorizationV2ViewModelTests: XCTestCase {
    func test_authorizationFlowStartsWithHelpWhenRequested() {
        let sut = AuthorizationFlowViewModel(
            shouldPresentHelp: true,
            onHelpCompleted: { _ in }
        )

        XCTAssertTrue(sut.isHelpPresented)
    }

    func test_authorizationFlowCompletesHelpOnlyOnce() {
        var completionCount = 0
        let sut = AuthorizationFlowViewModel(
            shouldPresentHelp: true,
            onHelpCompleted: { _ in completionCount += 1 }
        )

        sut.completeHelp()
        sut.completeHelp()

        XCTAssertFalse(sut.isHelpPresented)
        XCTAssertEqual(completionCount, 1)
    }

    func test_personalInfo_updatesDraftAndNavigatesForValidInput() {
        let draft = RegistrationDraft()
        let validator = PersonalInfoValidatorStub()
        var nextCallCount = 0
        let sut = RegistrationPersonalInfoViewModel(
            user: draft,
            validator: validator,
            onNextTapped: { nextCallCount += 1 }
        )
        sut.updateFirstName("Nikola")
        sut.updateLastName("Popovic")
        sut.updateInstitution("Biologer")

        sut.nextButtonTapped()

        XCTAssertEqual(draft.username, "Nikola")
        XCTAssertEqual(draft.lastname, "Popovic")
        XCTAssertEqual(draft.institution, "Biologer")
        XCTAssertEqual(nextCallCount, 1)
    }

    func test_credentials_updatesDraftAndNavigatesForValidInput() {
        let draft = RegistrationDraft()
        let validator = CredentialsValidatorStub()
        var nextCallCount = 0
        let sut = RegistrationCredentialsViewModel(
            user: draft,
            validator: validator,
            onNextTapped: { nextCallCount += 1 }
        )
        sut.updateEmail("user@example.com")
        sut.updatePassword("Password1")
        sut.updateRepeatedPassword("Password1")

        sut.nextButtonTapped()

        XCTAssertEqual(draft.email, "user@example.com")
        XCTAssertEqual(draft.password, "Password1")
        XCTAssertEqual(nextCallCount, 1)
    }

    func test_credentials_acceptsContinuousPasswordUpdates() {
        let sut = RegistrationCredentialsViewModel(
            user: RegistrationDraft(),
            validator: CredentialsValidatorStub(),
            onNextTapped: { _ in }
        )

        sut.updatePassword("P")
        sut.updatePassword("Password1")

        XCTAssertEqual(sut.password, "Password1")
    }

    func test_registrationRequiresPrivacyConsent() async {
        let registerUser = RegisterUserUseCaseSpy()
        let sut = makeRegistrationViewModel(registerUserUseCase: registerUser)

        await sut.registerTapped()

        XCTAssertNil(registerUser.request)
        XCTAssertFalse(sut.errorLabel.isEmpty)
    }

    func test_registrationBuildsRequestAndWaitsForSuccessConfirmation() async {
        let registerUser = RegisterUserUseCaseSpy()
        var successCallCount = 0
        let draft = makeCompletedDraft()
        let sut = makeRegistrationViewModel(
            draft: draft,
            registerUserUseCase: registerUser,
            onSuccess: { successCallCount += 1 }
        )
        sut.acceptPPCheckMark = true

        await sut.registerTapped()

        XCTAssertEqual(registerUser.request?.firstName, draft.username)
        XCTAssertEqual(registerUser.request?.lastName, draft.lastname)
        XCTAssertEqual(registerUser.request?.email, draft.email)
        XCTAssertEqual(registerUser.request?.dataLicenseId, 10)
        XCTAssertEqual(registerUser.request?.imageLicenseId, 20)
        XCTAssertEqual(successCallCount, 0)

        sut.confirmRegistrationSuccess()

        XCTAssertEqual(successCallCount, 1)
    }

    func test_loginReportsDomainFailureAndStopsLoading() async {
        let failure = AuthorizationFailure(summary: "Login failed", message: "Wrong credentials")
        let login = LoginUserUseCaseStub(result: .failure(.authorizationFailed(failure)))
        var receivedFailure: AuthorizationFailure?
        let environment = EnvironmentViewModelFactory().createEnvironment(type: .serbia)
        let sut = LoginScreenV2ViewModel(
            environmentViewModel: environment,
            useCase: login,
            onSelectEnvironmentTapped: {},
            onLoginSuccess: {},
            onRegisterTapped: {},
            onForgotPasswordTapped: {},
            onLoginError: { receivedFailure = $0 }
        )
        sut.updateEmail("user@example.com")
        sut.updatePassword("Password1")

        await sut.login()

        XCTAssertEqual(receivedFailure, failure)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loginPublishesInvalidEmailErrorImmediately() async {
        let login = LoginUserUseCaseStub(result: .failure(.invalidEmail))
        let environment = EnvironmentViewModelFactory().createEnvironment(type: .serbia)
        let sut = LoginScreenV2ViewModel(
            environmentViewModel: environment,
            useCase: login,
            onSelectEnvironmentTapped: {},
            onLoginSuccess: {},
            onRegisterTapped: {},
            onForgotPasswordTapped: {},
            onLoginError: { _ in }
        )
        sut.updateEmail("invalid-email")

        await sut.login()

        XCTAssertEqual(
            sut.emailError,
            "Common.tf.email.error.notValid".localized
        )
    }

    private func makeRegistrationViewModel(
        draft: RegistrationDraft? = nil,
        registerUserUseCase: RegisterUserUseCase,
        onSuccess: @escaping Observer<Void> = { _ in }
    ) -> RegistrationLicenseConsentViewModel {
        RegistrationLicenseConsentViewModel(
            user: draft ?? makeCompletedDraft(),
            topImage: "",
            registerUserUseCase: registerUserUseCase,
            dataLicense: CheckMarkItemMapper.getDataLicense()[0],
            imageLicense: CheckMarkItemMapper.getImageLicense()[1],
            onReadPrivacyPolicy: { _ in },
            onDataLicense: { _ in },
            onImageLicense: { _ in },
            onSuccess: onSuccess
        )
    }

    private func makeCompletedDraft() -> RegistrationDraft {
        let draft = RegistrationDraft()
        draft.username = "Nikola"
        draft.lastname = "Popovic"
        draft.institution = "Biologer"
        draft.email = "user@example.com"
        draft.password = "Password1"
        return draft
    }
}

private final class PersonalInfoValidatorStub: RegistrationPersonalInfoValidating {
    func validatePersonalInfo(
        firstName: String,
        lastName: String,
        institution: String
    ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo {
        RegistrationPersonalInfo(firstName: firstName, lastName: lastName, institution: institution)
    }
}

private final class CredentialsValidatorStub: RegistrationCredentialsValidating {
    func validateCredentials(
        email: String,
        password: String,
        repeatedPassword: String
    ) throws(RegisterUserValidationError) -> RegistrationCredentials {
        RegistrationCredentials(email: email, password: password)
    }
}

private final class RegisterUserUseCaseSpy: RegisterUserUseCase {
    var result: Result<Void, AuthorizationFailure> = .success(())
    private(set) var request: RegistrationRequest?

    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) {
        self.request = request
        try result.get()
    }
}

private final class LoginUserUseCaseStub: LoginUserUseCase {
    let result: Result<Void, LoginError>

    init(result: Result<Void, LoginError>) {
        self.result = result
    }

    func login(email: String, username: String, password: String) async throws(LoginError) {
        try result.get()
    }
}
