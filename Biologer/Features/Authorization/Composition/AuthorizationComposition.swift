/// Builds the Authorization feature from app-scoped dependencies.
final class AuthorizationComposition {
    struct Dependencies {
        let apiClient: APIClientProtocol
        let environmentProvider: CurrentEnvironmentProviding
        let tokenStorage: TokenStorage
        let environmentSelectionStorage: EnvironmentSelectionStorage
        let licensePreferenceStorage: LicensePreferenceStorage
        let environmentOptionsProvider: EnvironmentOptionsProviding
        let licenseOptionsProvider: LicenseOptionsProviding
        let urlProvider: AuthorizationURLProviding
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    private lazy var loginRepository: LoginUserRepository = {
        RemoteLoginUserRepository(
            client: dependencies.apiClient,
            environmentProvider: dependencies.environmentProvider,
            tokenStorage: dependencies.tokenStorage
        )
    }()

    private lazy var registerUserRepository: RegisterUserRepository = {
        RemoteRegisterUserRepository(
            client: dependencies.apiClient,
            environmentProvider: dependencies.environmentProvider,
            tokenStorage: dependencies.tokenStorage
        )
    }()

    private lazy var registrationLicenseRepository:
        RegistrationLicensePreferenceRepository = {
        StoredRegistrationLicensePreferenceRepository(
            storage: dependencies.licensePreferenceStorage
        )
    }()

    private lazy var environmentSelectionRepository:
        AuthorizationEnvironmentSelectionRepository = {
        StoredAuthorizationEnvironmentSelectionRepository(
            storage: dependencies.environmentSelectionStorage
        )
    }()

    private lazy var tutorialRepository: AuthorizationTutorialRepository = {
        UserDefaultsAuthorizationTutorialRepository()
    }()

    private lazy var useCases: AuthorizationUseCases = {
        AuthorizationUseCases(
            login: DefaultLoginUserUseCase(repository: loginRepository),
            registration: DefaultRegistrationUseCase(
                validator: DefaultRegistrationInputValidator(),
                licensePreferenceUseCase: DefaultRegistrationLicensePreferenceUseCase(
                    repository: registrationLicenseRepository
                ),
                registerUseCase: DefaultRegisterUserUseCase(
                    repository: registerUserRepository
                )
            ),
            environmentSelection: DefaultAuthorizationEnvironmentSelectionUseCase(
                repository: environmentSelectionRepository
            ),
            tutorial: DefaultAuthorizationTutorialUseCase(
                repository: tutorialRepository
            )
        )
    }()

    lazy var flowBuilder: UnauthenticatedFlowBuilder = {
        UnauthenticatedFlowBuilder(
            useCases: useCases,
            environmentOptionsProvider: dependencies.environmentOptionsProvider,
            licenseOptionsProvider: dependencies.licenseOptionsProvider,
            urlProvider: dependencies.urlProvider
        )
    }()
}
