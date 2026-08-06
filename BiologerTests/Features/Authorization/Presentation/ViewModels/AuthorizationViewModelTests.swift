import XCTest
@testable import Biologer

@MainActor
final class AuthorizationViewModelTests: XCTestCase {
    func test_init_givenDefaultEnvironment_whenViewModelIsCreated_thenPublishesAndMarksDefault() {
        // Given
        let factory = EnvironmentViewModelFactory()
        let defaultEnvironment = factory.createEnvironment(type: .croatia)
        let environments = factory.createAllEnvironments()

        // When
        let sut = makeAuthorizationSUT(
            defaultEnvironment: defaultEnvironment,
            environments: environments
        ).sut

        // Then
        XCTAssertEqual(sut.selectedEnvironment, defaultEnvironment)
        XCTAssertTrue(sut.selectedEnvironment.isSelected)
        XCTAssertEqual(
            sut.environments.filter(\.isSelected).map(\.id),
            [defaultEnvironment.id]
        )
    }

    func test_prepareLogin_givenInjectedDefaultEnvironment_whenCalledTwice_thenPersistsItOnce() {
        // Given
        let factory = EnvironmentViewModelFactory()
        let defaultEnvironment = factory.createEnvironment(type: .croatia)
        let (sut, environmentSpy) = makeAuthorizationSUT(
            defaultEnvironment: defaultEnvironment
        )

        // When
        sut.prepareLogin()
        sut.prepareLogin()

        // Then
        XCTAssertEqual(environmentSpy.receivedEnvironments.count, 1)
        XCTAssertTrue(environmentSpy.receivedEnvironments[0] === defaultEnvironment.env)
    }

    func test_selectEnvironment_givenDifferentEnvironment_whenSelected_thenPublishesAndPersistsIt() {
        // Given
        let environment = EnvironmentViewModelFactory()
            .createEnvironment(type: .montenegro)
        let (sut, environmentSpy) = makeAuthorizationSUT()

        // When
        sut.selectEnvironment(environment)

        // Then
        XCTAssertEqual(sut.selectedEnvironment, environment)
        XCTAssertTrue(sut.selectedEnvironment.isSelected)
        XCTAssertEqual(
            sut.environments.filter(\.isSelected).map(\.id),
            [environment.id]
        )
        XCTAssertEqual(environmentSpy.receivedEnvironments.count, 1)
        XCTAssertTrue(environmentSpy.receivedEnvironments[0] === environment.env)
    }

    func test_selectEnvironment_givenCurrentEnvironment_whenSelectedAgain_thenDoesNotPersistIt() {
        // Given
        let factory = EnvironmentViewModelFactory()
        let environment = factory.createEnvironment(type: .serbia)
        let (sut, environmentSpy) = makeAuthorizationSUT(
            defaultEnvironment: environment
        )

        // When
        sut.selectEnvironment(environment)

        // Then
        XCTAssertTrue(environmentSpy.receivedEnvironments.isEmpty)
    }

    func test_selectEnvironment_givenEnvironmentChanges_whenSelected_thenUpdatesExistingRegistrationViewModel() {
        // Given
        let newEnvironment = EnvironmentViewModelFactory()
            .createEnvironment(type: .bosniaAndHerzegovina)
        let sut = makeAuthorizationSUT().sut
        let registrationViewModel = sut.registrationFlowViewModel

        // When
        sut.selectEnvironment(newEnvironment)

        // Then
        XCTAssertTrue(registrationViewModel === sut.registrationFlowViewModel)
        XCTAssertEqual(registrationViewModel.environmentImage, newEnvironment.image)
        XCTAssertEqual(registrationViewModel.licenseConsentViewModel.topImage, newEnvironment.image)
    }

    func test_externalURL_givenForgotPasswordPage_whenCreated_thenUsesSelectedEnvironment() {
        // Given
        let environment = EnvironmentViewModelFactory()
            .createEnvironment(type: .develop)
        let sut = makeAuthorizationSUT(
            defaultEnvironment: environment
        ).sut

        // When
        let url = sut.externalURL(for: .forgotPassword)

        // Then
        XCTAssertEqual(
            url?.absoluteString,
            "https://\(environment.env.host)\(environment.env.path)/password/reset"
        )
    }

    func test_externalURL_givenPrivacyPolicyPage_whenCreated_thenUsesSelectedEnvironment() {
        // Given
        let environment = EnvironmentViewModelFactory()
            .createEnvironment(type: .serbia)
        let sut = makeAuthorizationSUT(
            defaultEnvironment: environment
        ).sut

        // When
        let url = sut.externalURL(for: .privacyPolicy)

        // Then
        XCTAssertEqual(
            url?.absoluteString,
            "https://\(environment.env.host)\(environment.env.path)/pages/privacy-policy"
        )
    }

    func test_login_givenAuthorizationFailure_whenLoginCompletes_thenReturnsFailure() async {
        // Given
        let failure = AuthorizationFailure(
            summary: "Login failed",
            message: "Wrong credentials"
        )
        let loginUseCase = LoginUserUseCaseStub(
            result: .failure(.authorizationFailed(failure))
        )
        let sut = makeAuthorizationSUT(
            loginUseCase: loginUseCase
        ).sut
        let loginViewModel = sut.loginViewModel
        loginViewModel.updateEmail("user@example.com")
        loginViewModel.updatePassword("Password1")

        // When
        let result = await loginViewModel.login()

        // Then
        XCTAssertEqual(result, .authorizationFailure(failure))
    }

    func test_dismissResult_givenPresentedResult_whenCalled_thenClearsResult() async {
        // Given
        let failure = AuthorizationFailure(message: "Failure")
        let sut = makeAuthorizationSUT().sut
        sut.present(error: failure)

        // When
        sut.dismissResult()

        // Then
        XCTAssertNil(sut.result)
    }

    func test_init_givenRegistrationOptions_whenFlowViewModelIsCreated_thenSelectsFirstOptions() {
        // Given
        let dataLicenses = CheckMarkItemMapper.getDataLicense()
        let imageLicenses = CheckMarkItemMapper.getImageLicense()

        // When
        let sut = makeRegistrationFlowSUT(
            dataLicenses: dataLicenses,
            imageLicenses: imageLicenses
        )

        // Then
        XCTAssertEqual(sut.selectedDataLicense, dataLicenses[0])
        XCTAssertEqual(sut.selectedImageLicense, imageLicenses[0])
        XCTAssertEqual(sut.environmentImage, "serbia_flag")
    }

    func test_fixedStepViewModels_givenCompletedSteps_whenRegistering_thenShareOneDraft() async {
        // Given
        let registrationUseCase = RegistrationUseCaseSpy()
        let sut = makeRegistrationFlowSUT(
            registrationUseCase: registrationUseCase
        )
        let personalInfoViewModel = sut.personalInfoViewModel
        let credentialsViewModel = sut.credentialsViewModel
        personalInfoViewModel.updateFirstName("Nikola")
        personalInfoViewModel.updateLastName("Popovic")
        personalInfoViewModel.updateInstitution("Biologer")
        XCTAssertTrue(personalInfoViewModel.nextButtonTapped())
        credentialsViewModel.updateEmail("user@example.com")
        credentialsViewModel.updatePassword("Password1")
        credentialsViewModel.updateRepeatedPassword("Password1")
        XCTAssertTrue(credentialsViewModel.nextButtonTapped())
        let consentViewModel = sut.licenseConsentViewModel
        consentViewModel.acceptPPCheckMark = true

        // When
        await consentViewModel.registerTapped()

        // Then
        XCTAssertEqual(registrationUseCase.receivedRequest?.firstName, "Nikola")
        XCTAssertEqual(registrationUseCase.receivedRequest?.lastName, "Popovic")
        XCTAssertEqual(registrationUseCase.receivedRequest?.institution, "Biologer")
        XCTAssertEqual(registrationUseCase.receivedRequest?.email, "user@example.com")
        XCTAssertEqual(registrationUseCase.receivedRequest?.password, "Password1")
    }

    func test_selectedLicenses_givenSelectionsChange_whenUpdated_thenUpdatesConsentViewModel() {
        // Given
        let sut = makeRegistrationFlowSUT()
        sut.selectedDataLicense = sut.dataLicenses.last!
        sut.selectedImageLicense = sut.imageLicenses.last!

        // Then
        XCTAssertEqual(sut.licenseConsentViewModel.dataLicense, sut.selectedDataLicense)
        XCTAssertEqual(sut.licenseConsentViewModel.imageLicense, sut.selectedImageLicense)
    }

    func test_personalInfo_givenValidInput_whenContinuing_thenUpdatesDraftAndNavigates() {
        // Given
        let draft = RegistrationDraft()
        let sut = RegistrationPersonalInfoViewModel(
            user: draft,
            validator: PersonalInfoValidatorStub()
        )
        sut.updateFirstName("Nikola")
        sut.updateLastName("Popovic")
        sut.updateInstitution("Biologer")

        // When
        let shouldNavigate = sut.nextButtonTapped()

        // Then
        XCTAssertEqual(draft.username, "Nikola")
        XCTAssertEqual(draft.lastname, "Popovic")
        XCTAssertEqual(draft.institution, "Biologer")
        XCTAssertTrue(shouldNavigate)
    }

    func test_credentials_givenValidInput_whenContinuing_thenUpdatesDraftAndNavigates() {
        // Given
        let draft = RegistrationDraft()
        let sut = RegistrationCredentialsViewModel(
            user: draft,
            validator: CredentialsValidatorStub()
        )
        sut.updateEmail("user@example.com")
        sut.updatePassword("Password1")
        sut.updateRepeatedPassword("Password1")

        // When
        let shouldNavigate = sut.nextButtonTapped()

        // Then
        XCTAssertEqual(draft.email, "user@example.com")
        XCTAssertEqual(draft.password, "Password1")
        XCTAssertTrue(shouldNavigate)
    }

    func test_credentials_givenContinuousPasswordInput_whenUpdated_thenKeepsLatestValue() {
        // Given
        let sut = RegistrationCredentialsViewModel(
            user: RegistrationDraft(),
            validator: CredentialsValidatorStub()
        )

        // When
        sut.updatePassword("P")
        sut.updatePassword("Password1")

        // Then
        XCTAssertEqual(sut.password, "Password1")
    }

    func test_register_givenPrivacyIsNotAccepted_whenSubmitted_thenDoesNotCallUseCase() async {
        // Given
        let registrationUseCase = RegistrationUseCaseSpy()
        let sut = makeRegistrationConsentSUT(
            registrationUseCase: registrationUseCase
        )

        // When
        await sut.registerTapped()

        // Then
        XCTAssertNil(registrationUseCase.receivedRequest)
        XCTAssertFalse(sut.errorLabel.isEmpty)
    }

    func test_register_givenValidDraft_whenSubmittedAndConfirmed_thenBuildsRequestAndCompletes() async {
        // Given
        let registrationUseCase = RegistrationUseCaseSpy()
        let draft = makeCompletedDraft()
        let sut = makeRegistrationConsentSUT(
            draft: draft,
            registrationUseCase: registrationUseCase
        )
        sut.acceptPPCheckMark = true

        // When
        await sut.registerTapped()

        // Then
        XCTAssertEqual(registrationUseCase.receivedRequest?.firstName, draft.username)
        XCTAssertEqual(registrationUseCase.receivedRequest?.lastName, draft.lastname)
        XCTAssertEqual(registrationUseCase.receivedRequest?.email, draft.email)
        XCTAssertEqual(registrationUseCase.receivedRequest?.dataLicenseId, 10)
        XCTAssertEqual(registrationUseCase.receivedRequest?.imageLicenseId, 20)
        XCTAssertEqual(sut.registrationPopup?.id, "success")

        // When
        sut.confirmRegistrationSuccess()

        // Then
        XCTAssertNil(sut.registrationPopup)
    }

    func test_login_givenDomainFailure_whenSubmitted_thenReportsFailureAndStopsLoading() async {
        // Given
        let failure = AuthorizationFailure(
            summary: "Login failed",
            message: "Wrong credentials"
        )
        let environment = EnvironmentViewModelFactory()
            .createEnvironment(type: .serbia)
        let sut = LoginScreenViewModel(
            environmentViewModel: environment,
            useCase: LoginUserUseCaseStub(
                result: .failure(.authorizationFailed(failure))
            )
        )
        sut.updateEmail("user@example.com")
        sut.updatePassword("Password1")

        // When
        let result = await sut.login()

        // Then
        XCTAssertEqual(result, .authorizationFailure(failure))
        XCTAssertFalse(sut.isLoading)
    }

    func test_login_givenInvalidEmail_whenSubmitted_thenPublishesLocalizedError() async {
        // Given
        let environment = EnvironmentViewModelFactory()
            .createEnvironment(type: .serbia)
        let sut = LoginScreenViewModel(
            environmentViewModel: environment,
            useCase: LoginUserUseCaseStub(result: .failure(.invalidEmail))
        )
        sut.updateEmail("invalid-email")

        // When
        let result = await sut.login()

        // Then
        XCTAssertEqual(
            sut.emailError,
            "Common.tf.email.error.notValid".localized
        )
        XCTAssertEqual(result, .validationFailure)
    }

    private func makeAuthorizationSUT(
        defaultEnvironment: EnvironmentViewModel? = nil,
        environments: [EnvironmentViewModel]? = nil,
        loginUseCase: LoginUserUseCase = LoginUserUseCaseStub(result: .success(()))
    ) -> (
        sut: AuthorizationFlowViewModel,
        environmentSpy: SelectAuthorizationEnvironmentUseCaseSpy
    ) {
        let factory = EnvironmentViewModelFactory()
        let environmentSpy = SelectAuthorizationEnvironmentUseCaseSpy()
        let selectedEnvironment = defaultEnvironment
            ?? factory.createEnvironment(type: .serbia)
        let registrationUseCase = RegistrationUseCaseSpy()
        let sut = AuthorizationFlowViewModel(
            selectEnvironment: environmentSpy,
            defaultEnvironment: selectedEnvironment,
            environments: environments ?? factory.createAllEnvironments(),
            loginViewModel: LoginScreenViewModel(
                environmentViewModel: selectedEnvironment,
                useCase: loginUseCase
            ),
            registrationFlowViewModel: makeRegistrationFlowSUT(
                registrationUseCase: registrationUseCase,
                environmentImage: selectedEnvironment.image
            )
        )
        return (sut, environmentSpy)
    }

    private func makeRegistrationFlowSUT(
        registrationUseCase: RegistrationUseCase = RegistrationUseCaseSpy(),
        environmentImage: String = "serbia_flag",
        dataLicenses: [CheckMarkItem] = CheckMarkItemMapper.getDataLicense(),
        imageLicenses: [CheckMarkItem] = CheckMarkItemMapper.getImageLicense()
    ) -> RegistrationFlowViewModel {
        let draft = RegistrationDraft()
        return RegistrationFlowViewModel(
            environmentImage: environmentImage,
            dataLicenses: dataLicenses,
            imageLicenses: imageLicenses,
            personalInfoViewModel: RegistrationPersonalInfoViewModel(
                user: draft,
                validator: registrationUseCase
            ),
            credentialsViewModel: RegistrationCredentialsViewModel(
                user: draft,
                validator: registrationUseCase
            ),
            licenseConsentViewModel: RegistrationLicenseConsentViewModel(
                user: draft,
                topImage: environmentImage,
                registerUserUseCase: registrationUseCase,
                dataLicense: dataLicenses[0],
                imageLicense: imageLicenses[0]
            )
        )
    }

    private func makeRegistrationConsentSUT(
        draft: RegistrationDraft? = nil,
        registrationUseCase: RegistrationUseCase
    ) -> RegistrationLicenseConsentViewModel {
        RegistrationLicenseConsentViewModel(
            user: draft ?? makeCompletedDraft(),
            topImage: "",
            registerUserUseCase: registrationUseCase,
            dataLicense: CheckMarkItemMapper.getDataLicense()[0],
            imageLicense: CheckMarkItemMapper.getImageLicense()[1]
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

private final class SelectAuthorizationEnvironmentUseCaseSpy:
    SelectAuthorizationEnvironmentUseCase {
    private(set) var receivedEnvironments: [AppEnvironment] = []

    func select(_ environment: AppEnvironment) {
        receivedEnvironments.append(environment)
    }
}

private final class PersonalInfoValidatorStub: RegistrationPersonalInfoValidating {
    func validatePersonalInfo(
        firstName: String,
        lastName: String,
        institution: String
    ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo {
        RegistrationPersonalInfo(
            firstName: firstName,
            lastName: lastName,
            institution: institution
        )
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

private final class RegistrationUseCaseSpy: RegistrationUseCase {
    private(set) var receivedRequest: RegistrationRequest?
    var result: Result<Void, AuthorizationFailure> = .success(())

    func validatePersonalInfo(
        firstName: String,
        lastName: String,
        institution: String
    ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo {
        RegistrationPersonalInfo(
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
        RegistrationCredentials(email: email, password: password)
    }

    func createUser(
        request: RegistrationRequest
    ) async throws(AuthorizationFailure) {
        receivedRequest = request
        try result.get()
    }
}

private final class LoginUserUseCaseStub: LoginUserUseCase {
    let result: Result<Void, LoginError>

    init(result: Result<Void, LoginError>) {
        self.result = result
    }

    func login(
        email: String,
        username: String,
        password: String
    ) async throws(LoginError) {
        try result.get()
    }
}
