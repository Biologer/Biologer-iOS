import UIKit

/// Legacy V1 composition. V2 authorization is composed by AppRootComposition.
final class AuthorizationCoordinatorBuilder {
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

    func makeCoordinator() -> AuthorizationCoordinating {
        AuthorizationRouter(
            factory: authorizationFactory,
            commonViewControllerFactory: commonViewControllerFactory,
            swiftUICommonViewControllerFactory: swiftUICommonViewControllerFactory,
            swiftUIAlertViewControllerFactory: swiftUIAlertViewControllerFactory,
            navigationController: navigationController,
            loginUseCase: DefaultLoginUserUseCase(
                repository: RemoteLoginUserRepository(
                    client: apiClient,
                    environmentStorage: environmentStorage,
                    tokenStorage: tokenStorage
                )
            ),
            registerService: RemoteRegisterUserService(
                client: httpClient,
                environmentStorage: environmentStorage
            ),
            environmentStorage: environmentStorage,
            tutorialRepository: tutorialRepository,
            tokenStorage: tokenStorage,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage
        )
    }
}
