import SwiftUI
import XCTest
@testable import Biologer

@MainActor
final class AuthorizationRouterTests: XCTestCase {
    func test_startV1ShowsLegacyLogin() {
        let context = makeSUT(version: .v1)

        context.router.start(shouldPresentIntroScreens: false)

        XCTAssertTrue(context.navigationController.topViewController === context.authorizationFactory.loginViewController)
    }

    func test_startV2ShowsV2Flow() {
        let context = makeSUT(version: .v2)

        context.router.start(shouldPresentIntroScreens: false)

        XCTAssertTrue(context.navigationController.topViewController is UIHostingController<AuthorizationFlow>)
    }

    func test_finishingTutorialInV1UsesLegacyHelpScreen() {
        let context = makeSUT(version: .v1)

        context.router.start(shouldPresentIntroScreens: true)
        XCTAssertTrue(context.navigationController.topViewController === context.commonFactory.helpViewController)

        context.commonFactory.finishHelp()

        XCTAssertTrue(context.tutorialRepository.wasPresented)
        XCTAssertTrue(context.navigationController.topViewController === context.authorizationFactory.loginViewController)
    }

    func test_startV2WithTutorialUsesHelpEmbeddedInFlow() {
        let context = makeSUT(version: .v2)

        context.router.start(shouldPresentIntroScreens: true)

        XCTAssertTrue(context.navigationController.topViewController is UIHostingController<AuthorizationFlow>)
        XCTAssertEqual(context.commonFactory.helpRequestCount, 0)
        XCTAssertFalse(context.tutorialRepository.wasPresented)
    }

    func test_restartReplacesEntireAuthorizationStack() {
        let context = makeSUT(version: .v2)
        context.router.start(shouldPresentIntroScreens: false)
        context.navigationController.pushViewController(UIViewController(), animated: false)

        context.router.restart()

        XCTAssertEqual(context.navigationController.viewControllers.count, 1)
        XCTAssertTrue(context.navigationController.topViewController is UIHostingController<AuthorizationFlow>)
    }

    private func makeSUT(version: AuthorizationUIVersion) -> RouterTestContext {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let authorizationFactory = AuthorizationViewControllerFactorySpy()
        let commonFactory = CommonViewControllerFactorySpy()
        let environmentStorage = EnvironmentStorageSpy()
        let tutorialRepository = AuthorizationTutorialRepositorySpy()
        let useCases = AuthorizationUseCases(
            login: LoginUseCaseStub(),
            registration: RegistrationUseCaseStub(),
            selectEnvironmentUseCase: SelectEnvironmentUseCaseSpy()
        )
        let router = AuthorizationRouter(
            version: version,
            factory: authorizationFactory,
            commonViewControllerFactory: commonFactory,
            swiftUICommonViewControllerFactory: commonFactory,
            swiftUIAlertViewControllerFactory: AlertViewControllerFactoryStub(),
            navigationController: navigationController,
            authorizationUseCases: useCases,
            registerService: RegisterUserServiceStub(),
            environmentStorage: environmentStorage,
            tutorialRepository: tutorialRepository,
            tokenStorage: TokenStorageSpy(),
            dataLicenseStorage: LicenseStorageSpy(),
            imageLicenseStorage: LicenseStorageSpy()
        )
        return RouterTestContext(
            router: router,
            navigationController: navigationController,
            authorizationFactory: authorizationFactory,
            commonFactory: commonFactory,
            tutorialRepository: tutorialRepository
        )
    }
}

private struct RouterTestContext {
    let router: AuthorizationRouter
    let navigationController: UINavigationController
    let authorizationFactory: AuthorizationViewControllerFactorySpy
    let commonFactory: CommonViewControllerFactorySpy
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
