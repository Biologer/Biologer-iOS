import UIKit

enum AuthorizationUIVersion {
    case v1
    case v2
}

final class AuthorizationRouterBuilder {
    private let version: AuthorizationUIVersion
    private let apiClient: APIClientProtocol
    private let httpClient: HTTPClient
    private let navigationController: UINavigationController
    private let authorizationFactory: AuthorizationViewControllerFactory
    private let commonViewControllerFactory: CommonViewControllerFactory
    private let swiftUICommonViewControllerFactory: CommonViewControllerFactory
    private let swiftUIAlertViewControllerFactory: AlertViewControllerFactory
    private let environmentStorage: EnvironmentStorage
    private let tutorialRepository: AuthorizationTutorialRepository
    private let tokenStorage: TokenStorage
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage

    init(
        version: AuthorizationUIVersion,
        apiClient: APIClientProtocol,
        httpClient: HTTPClient,
        navigationController: UINavigationController,
        authorizationFactory: AuthorizationViewControllerFactory,
        commonViewControllerFactory: CommonViewControllerFactory,
        swiftUICommonViewControllerFactory: CommonViewControllerFactory,
        swiftUIAlertViewControllerFactory: AlertViewControllerFactory,
        environmentStorage: EnvironmentStorage,
        tutorialRepository: AuthorizationTutorialRepository,
        tokenStorage: TokenStorage,
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage
    ) {
        self.version = version
        self.apiClient = apiClient
        self.httpClient = httpClient
        self.navigationController = navigationController
        self.authorizationFactory = authorizationFactory
        self.commonViewControllerFactory = commonViewControllerFactory
        self.swiftUICommonViewControllerFactory = swiftUICommonViewControllerFactory
        self.swiftUIAlertViewControllerFactory = swiftUIAlertViewControllerFactory
        self.environmentStorage = environmentStorage
        self.tutorialRepository = tutorialRepository
        self.tokenStorage = tokenStorage
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
    }

    func makeRouter() -> AuthorizationRouter {
        AuthorizationRouter(
            version: version,
            factory: authorizationFactory,
            commonViewControllerFactory: commonViewControllerFactory,
            swiftUICommonViewControllerFactory: swiftUICommonViewControllerFactory,
            swiftUIAlertViewControllerFactory: swiftUIAlertViewControllerFactory,
            navigationController: navigationController,
            authorizationUseCases: makeAuthorizationUseCases(),
            registerService: makeRegisterService(),
            environmentStorage: environmentStorage,
            tutorialRepository: tutorialRepository,
            tokenStorage: tokenStorage,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage
        )
    }

    private func makeAuthorizationUseCases() -> AuthorizationUseCases {
        AuthorizationUseCases(
            login: makeLoginUseCase(),
            registration: makeRegistrationUseCase(),
            selectEnvironmentUseCase: DefaultSelectAuthorizationEnvironmentUseCase(
                repository: StoredAuthorizationEnvironmentRepository(storage: environmentStorage)
            )
        )
    }

    private func makeLoginUseCase() -> LoginUserUseCase {
        DefaultLoginUserUseCase(
            repository: RemoteLoginUserRepository(
                client: apiClient,
                environmentStorage: environmentStorage,
                tokenStorage: tokenStorage
            )
        )
    }

    private func makeRegistrationUseCase() -> RegistrationUseCase {
        DefaultRegistrationUseCase(
            validator: DefaultRegistrationInputValidator(),
            licensePreferenceUseCase: makeLicensePreferenceUseCase(),
            registerUseCase: makeRegisterUseCase()
        )
    }

    private func makeRegisterUseCase() -> RegisterUserUseCase {
        DefaultRegisterUserUseCase(
            repository: RemoteRegisterUserRepository(
                client: apiClient,
                environmentStorage: environmentStorage,
                tokenStorage: tokenStorage
            )
        )
    }

    private func makeLicensePreferenceUseCase() -> RegistrationLicensePreferenceUseCase {
        DefaultRegistrationLicensePreferenceUseCase(
            repository: StoredRegistrationLicensePreferenceRepository(
                dataLicenseStorage: dataLicenseStorage,
                imageLicenseStorage: imageLicenseStorage
            )
        )
    }

    private func makeRegisterService() -> RegisterUserService {
        RemoteRegisterUserService(
            client: httpClient,
            environmentStorage: environmentStorage
        )
    }
}
