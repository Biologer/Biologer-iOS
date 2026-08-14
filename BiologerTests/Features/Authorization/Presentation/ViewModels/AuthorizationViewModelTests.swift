import XCTest
@testable import Biologer

@MainActor
final class AuthorizationViewModelTests: XCTestCase {
    func test_loginInit_givenStoredEnvironment_thenRestoresItWithoutSavingAgain() {
        let optionsProvider = makeEnvironmentOptions()
        let environmentUseCase = AuthorizationEnvironmentSelectionUseCaseSpy(
            storedID: .croatia
        )

        let sut = makeLoginSUT(
            environmentOptionsProvider: optionsProvider,
            environmentUseCase: environmentUseCase
        )

        XCTAssertEqual(sut.selectedEnvironment.id, .croatia)
        XCTAssertTrue(environmentUseCase.receivedIDs.isEmpty)
    }

    func test_loginInit_givenNoStoredEnvironment_thenSelectsAndSavesDefault() {
        let environmentUseCase = AuthorizationEnvironmentSelectionUseCaseSpy()

        let sut = makeLoginSUT(environmentUseCase: environmentUseCase)

        XCTAssertEqual(sut.selectedEnvironment.id, .serbia)
        XCTAssertEqual(environmentUseCase.receivedIDs, [.serbia])
    }

    func test_selectEnvironment_givenDifferentOption_thenPublishesAndPersistsIt() {
        let optionsProvider = makeEnvironmentOptions()
        let environmentUseCase = AuthorizationEnvironmentSelectionUseCaseSpy()
        let sut = makeLoginSUT(
            environmentOptionsProvider: optionsProvider,
            environmentUseCase: environmentUseCase
        )
        environmentUseCase.receivedIDs.removeAll()

        sut.selectEnvironment(optionsProvider.option(for: .montenegro))

        XCTAssertEqual(sut.selectedEnvironment.id, .montenegro)
        XCTAssertEqual(environmentUseCase.receivedIDs, [.montenegro])
    }

    func test_selectEnvironment_givenCurrentOption_thenDoesNotPersistItAgain() {
        let optionsProvider = makeEnvironmentOptions()
        let environmentUseCase = AuthorizationEnvironmentSelectionUseCaseSpy(
            storedID: .serbia
        )
        let sut = makeLoginSUT(
            environmentOptionsProvider: optionsProvider,
            environmentUseCase: environmentUseCase
        )

        sut.selectEnvironment(optionsProvider.option(for: .serbia))

        XCTAssertTrue(environmentUseCase.receivedIDs.isEmpty)
    }

    func test_selectEnvironment_givenPersistenceFailure_thenKeepsCurrentSelection() {
        let optionsProvider = makeEnvironmentOptions()
        let environmentUseCase = AuthorizationEnvironmentSelectionUseCaseSpy(
            storedID: .serbia
        )
        environmentUseCase.saveResult = .failure(.persistenceFailed)
        let sut = makeLoginSUT(
            environmentOptionsProvider: optionsProvider,
            environmentUseCase: environmentUseCase
        )

        let didSelect = sut.selectEnvironment(
            optionsProvider.option(for: .montenegro)
        )

        XCTAssertFalse(didSelect)
        XCTAssertEqual(sut.selectedEnvironment.id, .serbia)
        XCTAssertNotNil(sut.result)
    }

    func test_externalURL_givenForgotPassword_thenUsesSelectedEnvironment() {
        let configurations = DefaultEnvironmentConfigurationProvider()
        let sut = makeLoginSUT(
            environmentUseCase: AuthorizationEnvironmentSelectionUseCaseSpy(
                storedID: .development
            )
        )

        let url = sut.externalURL(for: .forgotPassword)

        XCTAssertEqual(
            url?.absoluteString,
            "https://\(configurations.configuration(for: .development).host)"
                + "\(configurations.configuration(for: .development).path)"
                + "/password/reset"
        )
    }

    func test_login_givenAuthorizationFailure_thenReturnsFailureAndStopsLoading() async {
        let failure = AuthorizationFailure(
            summary: "Login failed",
            message: "Wrong credentials"
        )
        let sut = makeLoginSUT(
            loginUseCase: LoginUserUseCaseStub(
                result: .failure(.authorizationFailed(failure))
            )
        )
        sut.updateEmail("user@example.com")
        sut.updatePassword("Password1")

        let result = await sut.login()

        XCTAssertEqual(result, .authorizationFailure(failure))
        XCTAssertFalse(sut.isLoading)
    }

    func test_login_givenInvalidEmail_thenPublishesLocalizedError() async {
        let sut = makeLoginSUT(
            loginUseCase: LoginUserUseCaseStub(result: .failure(.invalidEmail))
        )
        sut.updateEmail("invalid-email")

        let result = await sut.login()

        XCTAssertEqual(sut.emailError, "Common.tf.email.error.notValid".localized)
        XCTAssertEqual(result, .validationFailure)
    }

    func test_registrationInit_thenUsesFirstProvidedLicenses() {
        let licenseOptionsProvider = DefaultLicenseOptionsProvider()

        let sut = makeRegistrationSUT(
            licenseOptionsProvider: licenseOptionsProvider
        )

        XCTAssertEqual(
            sut.draft.dataLicenseID,
            licenseOptionsProvider.defaultOption(for: .data).id
        )
        XCTAssertEqual(
            sut.draft.imageLicenseID,
            licenseOptionsProvider.defaultOption(for: .image).id
        )
    }

    func test_registration_givenCompletedSteps_thenOneDraftBuildsRequest() async {
        let useCase = RegistrationUseCaseSpy()
        let sut = makeRegistrationSUT(useCase: useCase)
        sut.updateFirstName("Nikola")
        sut.updateLastName("Popovic")
        sut.updateInstitution("Biologer")
        XCTAssertTrue(sut.validatePersonalInfo())
        sut.updateEmail("user@example.com")
        sut.updatePassword("Password1")
        sut.updateRepeatedPassword("Password1")
        XCTAssertTrue(sut.validateCredentials())
        sut.selectDataLicense(id: sut.dataLicenses.last!.id)
        sut.selectImageLicense(id: sut.imageLicenses.last!.id)
        sut.acceptsPrivacyPolicy = true

        await sut.register()

        XCTAssertEqual(useCase.receivedRequest?.firstName, "Nikola")
        XCTAssertEqual(useCase.receivedRequest?.lastName, "Popovic")
        XCTAssertEqual(useCase.receivedRequest?.institution, "Biologer")
        XCTAssertEqual(useCase.receivedRequest?.email, "user@example.com")
        XCTAssertEqual(useCase.receivedRequest?.password, "Password1")
        XCTAssertEqual(useCase.receivedRequest?.dataLicenseId, sut.dataLicenses.last?.id)
        XCTAssertEqual(useCase.receivedRequest?.imageLicenseId, sut.imageLicenses.last?.id)
        XCTAssertEqual(sut.registrationPopup?.id, "success")
    }

    func test_register_givenPrivacyIsNotAccepted_thenDoesNotSubmit() async {
        let useCase = RegistrationUseCaseSpy()
        let sut = makeRegistrationSUT(useCase: useCase)

        await sut.register()

        XCTAssertNil(useCase.receivedRequest)
        XCTAssertFalse(sut.privacyPolicyError.isEmpty)
    }

    func test_credentials_givenContinuousPasswordInput_thenKeepsLatestValue() {
        let sut = makeRegistrationSUT()

        sut.updatePassword("P")
        sut.updatePassword("Password1")

        XCTAssertEqual(sut.draft.password, "Password1")
    }

    private func makeLoginSUT(
        environmentOptionsProvider: EnvironmentOptionsProviding? = nil,
        environmentUseCase: AuthorizationEnvironmentSelectionUseCaseSpy = .init(),
        loginUseCase: LoginUserUseCase = LoginUserUseCaseStub(result: .success(()))
    ) -> LoginFlowViewModel {
        let configurations = DefaultEnvironmentConfigurationProvider()
        return LoginFlowViewModel(
            environmentOptionsProvider: environmentOptionsProvider
                ?? DefaultEnvironmentOptionsProvider(
                    configurationProvider: configurations
                ),
            loginUseCase: loginUseCase,
            environmentSelectionUseCase: environmentUseCase,
            urlProvider: DefaultAuthorizationURLProvider(
                configurationProvider: configurations
            )
        )
    }

    private func makeRegistrationSUT(
        licenseOptionsProvider: LicenseOptionsProviding = DefaultLicenseOptionsProvider(),
        useCase: RegistrationUseCase = RegistrationUseCaseSpy()
    ) -> RegistrationFlowViewModel {
        let environment = makeEnvironmentOptions().defaultOption
        return RegistrationFlowViewModel(
            environmentID: environment.id,
            environmentImage: environment.image,
            dataLicenses: licenseOptionsProvider.options(for: .data),
            imageLicenses: licenseOptionsProvider.options(for: .image),
            useCase: useCase
        )
    }

    private func makeEnvironmentOptions() -> EnvironmentOptionsProviding {
        DefaultEnvironmentOptionsProvider(
            configurationProvider: DefaultEnvironmentConfigurationProvider()
        )
    }
}

private final class AuthorizationEnvironmentSelectionUseCaseSpy:
    AuthorizationEnvironmentSelectionUseCase {
    private let storedID: EnvironmentID?
    var receivedIDs: [EnvironmentID] = []
    var saveResult: Result<Void, AuthorizationEnvironmentSelectionError> = .success(())

    init(storedID: EnvironmentID? = nil) {
        self.storedID = storedID
    }

    func selectedEnvironmentID() -> EnvironmentID? {
        storedID
    }

    func select(
        _ id: EnvironmentID
    ) throws(AuthorizationEnvironmentSelectionError) {
        receivedIDs.append(id)
        try saveResult.get()
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

    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) {
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
