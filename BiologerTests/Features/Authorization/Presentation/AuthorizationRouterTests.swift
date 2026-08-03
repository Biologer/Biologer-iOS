import SwiftUI
import XCTest
@testable import Biologer

@MainActor
final class AuthorizationRouterTests: XCTestCase {
    func test_legacyRouterStartsWithLogin() {
        let context = makeLegacySUT()

        context.coordinator.start(shouldPresentIntroScreens: false)

        XCTAssertTrue(context.navigationController.topViewController === context.authorizationFactory.loginViewController)
    }

    func test_legacyRouterFinishesTutorialBeforeShowingLogin() {
        let context = makeLegacySUT()

        context.coordinator.start(shouldPresentIntroScreens: true)
        XCTAssertTrue(context.navigationController.topViewController === context.commonFactory.helpViewController)

        context.commonFactory.finishHelp()

        XCTAssertTrue(context.tutorialRepository.wasPresented)
        XCTAssertTrue(context.navigationController.topViewController === context.authorizationFactory.loginViewController)
    }

    func test_legacyRouterRestartReplacesEntireStack() {
        let context = makeLegacySUT()
        context.coordinator.start(shouldPresentIntroScreens: false)
        context.navigationController.pushViewController(UIViewController(), animated: false)

        context.coordinator.restart()

        XCTAssertEqual(context.navigationController.viewControllers.count, 1)
        XCTAssertTrue(context.navigationController.topViewController === context.authorizationFactory.loginViewController)
    }

    func test_flowCoordinatorStartsWithV2Flow() {
        let context = makeFlowSUT()

        context.coordinator.start(shouldPresentIntroScreens: false)

        XCTAssertTrue(context.navigationController.topViewController is UIHostingController<AuthorizationFlow>)
    }

    func test_flowCoordinatorKeepsTutorialInsideV2Flow() {
        let context = makeFlowSUT()

        context.coordinator.start(shouldPresentIntroScreens: true)

        XCTAssertTrue(context.navigationController.topViewController is UIHostingController<AuthorizationFlow>)
        XCTAssertFalse(context.tutorialRepository.wasPresented)
    }

    func test_flowCoordinatorRestartReplacesEntireStack() {
        let context = makeFlowSUT()
        context.coordinator.start(shouldPresentIntroScreens: false)
        context.navigationController.pushViewController(UIViewController(), animated: false)

        context.coordinator.restart()

        XCTAssertEqual(context.navigationController.viewControllers.count, 1)
        XCTAssertTrue(context.navigationController.topViewController is UIHostingController<AuthorizationFlow>)
    }

    func test_builderSelectsLegacyRouterForV1() {
        XCTAssertTrue(makeBuilder(version: .v1).makeCoordinator() is AuthorizationRouter)
    }

    func test_builderSelectsFlowCoordinatorForV2() {
        XCTAssertTrue(makeBuilder(version: .v2).makeCoordinator() is AuthorizationFlowCoordinator)
    }

    private func makeLegacySUT() -> LegacyRouterTestContext {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let authorizationFactory = AuthorizationViewControllerFactorySpy()
        let commonFactory = CommonViewControllerFactorySpy()
        let environmentStorage = EnvironmentStorageSpy()
        let tutorialRepository = AuthorizationTutorialRepositorySpy()
        let coordinator = AuthorizationRouter(
            factory: authorizationFactory,
            commonViewControllerFactory: commonFactory,
            swiftUICommonViewControllerFactory: commonFactory,
            swiftUIAlertViewControllerFactory: AlertViewControllerFactoryStub(),
            navigationController: navigationController,
            loginUseCase: LoginUseCaseStub(),
            registerService: RegisterUserServiceStub(),
            environmentStorage: environmentStorage,
            tutorialRepository: tutorialRepository,
            tokenStorage: TokenStorageSpy(),
            dataLicenseStorage: LicenseStorageSpy(),
            imageLicenseStorage: LicenseStorageSpy()
        )
        return LegacyRouterTestContext(
            coordinator: coordinator,
            navigationController: navigationController,
            authorizationFactory: authorizationFactory,
            commonFactory: commonFactory,
            tutorialRepository: tutorialRepository
        )
    }

    private func makeFlowSUT() -> FlowCoordinatorTestContext {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let tutorialRepository = AuthorizationTutorialRepositorySpy()
        let coordinator = AuthorizationFlowCoordinator(
            navigationController: navigationController,
            authorizationUseCases: makeAuthorizationUseCases(),
            environmentStorage: EnvironmentStorageSpy(),
            tutorialRepository: tutorialRepository,
            alertViewControllerFactory: AlertViewControllerFactoryStub()
        )
        return FlowCoordinatorTestContext(
            coordinator: coordinator,
            navigationController: navigationController,
            tutorialRepository: tutorialRepository
        )
    }

    private func makeBuilder(version: AuthorizationUIVersion) -> AuthorizationCoordinatorBuilder {
        let commonFactory = CommonViewControllerFactorySpy()
        return AuthorizationCoordinatorBuilder(
            version: version,
            apiClient: APIClientStub(),
            httpClient: HTTPClientStub(),
            navigationController: UINavigationController(),
            authorizationFactory: AuthorizationViewControllerFactorySpy(),
            commonViewControllerFactory: commonFactory,
            swiftUICommonViewControllerFactory: commonFactory,
            swiftUIAlertViewControllerFactory: AlertViewControllerFactoryStub(),
            environmentStorage: EnvironmentStorageSpy(),
            tutorialRepository: AuthorizationTutorialRepositorySpy(),
            tokenStorage: TokenStorageSpy(),
            dataLicenseStorage: LicenseStorageSpy(),
            imageLicenseStorage: LicenseStorageSpy()
        )
    }

    private func makeAuthorizationUseCases() -> AuthorizationUseCases {
        AuthorizationUseCases(
            login: LoginUseCaseStub(),
            registration: RegistrationUseCaseStub(),
            selectEnvironmentUseCase: SelectEnvironmentUseCaseSpy()
        )
    }
}

private struct LegacyRouterTestContext {
    let coordinator: AuthorizationRouter
    let navigationController: UINavigationController
    let authorizationFactory: AuthorizationViewControllerFactorySpy
    let commonFactory: CommonViewControllerFactorySpy
    let tutorialRepository: AuthorizationTutorialRepositorySpy
}

private struct FlowCoordinatorTestContext {
    let coordinator: AuthorizationFlowCoordinator
    let navigationController: UINavigationController
    let tutorialRepository: AuthorizationTutorialRepositorySpy
}

private final class AuthorizationViewControllerFactorySpy: AuthorizationViewControllerFactory {
    let loginViewController = UIViewController()

    func makeLoginScreen(
        useCase: LoginUserUseCase,
        environmentViewModel: EnvironmentViewModel,
        onSelectEnvironmentTapped: @escaping Observer<EnvironmentViewModel>,
        onLoginSuccess: @escaping Observer<Void>,
        onLoginError: @escaping Observer<AuthorizationFailure>,
        onRegisterTapped: @escaping Observer<Void>,
        onForgotPasswordTapped: @escaping Observer<Void>,
        onLoading: @escaping Observer<Bool>
    ) -> UIViewController {
        loginViewController
    }

    func makeEnvironmentScreen(
        selectedViewModel: EnvironmentViewModel,
        envViewModels: [EnvironmentViewModel],
        delegate: EnvironmentScreenViewModelProtocol?,
        onSelectedEnvironment: @escaping Observer<EnvironmentViewModel>
    ) -> UIViewController {
        UIViewController()
    }

    func makeRegisterFirstStepScreen(
        user: RegisterUser,
        onNextTapped: @escaping Observer<RegisterUser>
    ) -> UIViewController {
        UIViewController()
    }

    func makeRegisterSecondStepScreen(
        user: RegisterUser,
        onNextTapped: @escaping Observer<RegisterUser>
    ) -> UIViewController {
        UIViewController()
    }

    func makeRegisterThreeStepScreen(
        user: RegisterUser,
        topImage: String,
        service: RegisterUserService,
        dataLicense: CheckMarkItem,
        imageLicense: CheckMarkItem,
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage,
        onReadPrivacyPolicy: @escaping Observer<Void>,
        onDataLicense: @escaping Observer<CheckMarkItem>,
        onImageLicense: @escaping Observer<CheckMarkItem>,
        onSuccess: @escaping Observer<Token>,
        onError: @escaping Observer<APIError>,
        onLoading: @escaping Observer<Bool>
    ) -> UIViewController {
        UIViewController()
    }

    func makeSplashScreen(onSplashScreenDone: @escaping Observer<Void>) -> UIViewController {
        UIViewController()
    }
}

private final class CommonViewControllerFactorySpy: CommonViewControllerFactory {
    let helpViewController = UIViewController()
    private(set) var helpRequestCount = 0
    private var onHelpDone: Observer<Void>?

    func finishHelp() {
        onHelpDone?(())
    }

    func createBlockingProgress() -> UIViewController {
        UIViewController()
    }

    func makeLicenseScreen(
        items: [CheckMarkItem],
        selectedItem: CheckMarkItem,
        delegate: CheckMarkScreenDelegate?,
        onItemTapped: @escaping Observer<CheckMarkItem>
    ) -> UIViewController {
        UIViewController()
    }

    func makeHelpScreen(onDone: @escaping Observer<Void>) -> UIViewController {
        helpRequestCount += 1
        onHelpDone = onDone
        return helpViewController
    }

    func makeBiologerProgressBarView(
        maxValue: Double,
        currentValue: Double,
        onProgressAppeared: @escaping Observer<Double>,
        onCancelTapped: @escaping Observer<Double>
    ) -> UIViewController {
        UIViewController()
    }
}

private final class AlertViewControllerFactoryStub: AlertViewControllerFactory {
    func makeConfirmationAlert(
        popUpType: PopUpType,
        title: String,
        description: String,
        onTapp: @escaping Observer<Void>
    ) -> UIViewController {
        UIViewController()
    }

    func makeYesAndNoAlert(
        title: String,
        onYesTapped: @escaping Observer<Void>,
        onNoTapped: @escaping Observer<Void>
    ) -> UIViewController {
        UIViewController()
    }
}

private final class LoginUseCaseStub: LoginUserUseCase {
    func login(email: String, username: String, password: String) async throws(LoginError) {}
}

private final class RegistrationUseCaseStub: RegistrationUseCase {
    func validatePersonalInfo(
        firstName: String,
        lastName: String,
        institution: String
    ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo {
        RegistrationPersonalInfo(firstName: firstName, lastName: lastName, institution: institution)
    }

    func validateCredentials(
        email: String,
        password: String,
        repeatedPassword: String
    ) throws(RegisterUserValidationError) -> RegistrationCredentials {
        RegistrationCredentials(email: email, password: password)
    }

    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) {}
}

private final class SelectEnvironmentUseCaseSpy: SelectAuthorizationEnvironmentUseCase {
    private(set) var environment: Biologer.Environment?

    func select(_ environment: Biologer.Environment) {
        self.environment = environment
    }
}

private final class RegisterUserServiceStub: RegisterUserService {
    func createUser(user: RegisterUser, completion: @escaping (RegisterUserService.Result) -> Void) {}
}

private final class EnvironmentStorageSpy: EnvironmentStorage {
    private var environment: Biologer.Environment?

    func getEnvironment() -> Biologer.Environment? { environment }
    func saveEnvironment(env: Biologer.Environment) { environment = env }
    func delete() { environment = nil }
}

private final class AuthorizationTutorialRepositorySpy: AuthorizationTutorialRepository {
    private(set) var wasPresented = false

    func markPresented() {
        wasPresented = true
    }
}

private final class TokenStorageSpy: TokenStorage {
    private var token: Token?

    func getToken() -> Token? { token }
    func saveToken(token: Token) { self.token = token }
    func delete() { token = nil }
}

private final class LicenseStorageSpy: LicenseStorage {
    private var license: CheckMarkItem?

    func getLicense() -> CheckMarkItem? { license }
    func saveLicense(license: CheckMarkItem) { self.license = license }
    func delete() { license = nil }
}

private final class APIClientStub: APIClientProtocol {
    func send<Endpoint: APIEndpoint>(_ endpoint: Endpoint) async throws -> Endpoint.Response {
        fatalError("APIClientStub.send should not be called while building a coordinator")
    }
}

private final class HTTPClientStub: HTTPClient {
    func perform(
        from request: URLRequest,
        completion: @escaping (HTTPClient.Result) -> Void
    ) -> HTTPClientTask {
        HTTPClientTaskStub()
    }
}

private final class HTTPClientTaskStub: HTTPClientTask {
    func cancel() {}
    func resume() {}
}
