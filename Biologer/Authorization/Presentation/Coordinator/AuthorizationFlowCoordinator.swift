import SwiftUI
import UIKit

final class AuthorizationFlowCoordinator: AuthorizationCoordinating {
    private let navigationController: UINavigationController
    private let authorizationUseCases: AuthorizationUseCases
    private let environmentStorage: EnvironmentStorage
    private let tutorialRepository: AuthorizationTutorialRepository
    private let alertViewControllerFactory: AlertViewControllerFactory

    var onAuthorizationSuccess: Observer<Void>?

    init(
        navigationController: UINavigationController,
        authorizationUseCases: AuthorizationUseCases,
        environmentStorage: EnvironmentStorage,
        tutorialRepository: AuthorizationTutorialRepository,
        alertViewControllerFactory: AlertViewControllerFactory
    ) {
        self.navigationController = navigationController
        self.authorizationUseCases = authorizationUseCases
        self.environmentStorage = environmentStorage
        self.tutorialRepository = tutorialRepository
        self.alertViewControllerFactory = alertViewControllerFactory
    }

    func start(shouldPresentIntroScreens: Bool) {
        navigationController.pushViewController(
            makeViewController(shouldPresentHelp: shouldPresentIntroScreens),
            animated: true
        )
    }

    func restart() {
        navigationController.setViewControllers(
            [makeViewController(shouldPresentHelp: false)],
            animated: false
        )
    }

    private func makeViewController(shouldPresentHelp: Bool) -> UIViewController {
        let flow = AuthorizationFlow(
            authorizationUseCases: authorizationUseCases,
            shouldPresentHelp: shouldPresentHelp,
            onHelpCompleted: { [weak self] _ in
                self?.tutorialRepository.markPresented()
            },
            onAuthorizationSuccess: { [weak self] _ in
                self?.performOnMain { [weak self] in
                    self?.onAuthorizationSuccess?(())
                }
            },
            onForgotPassword: { [weak self] _ in
                self?.showSafari(path: "/password/reset")
            },
            onPrivacyPolicy: { [weak self] _ in
                self?.showSafari(path: "/pages/privacy-policy")
            },
            onLoginError: { [weak self] error in
                self?.showErrorAlert(error)
            }
        )
        let viewController = UIHostingController(rootView: flow)
        viewController.navigationItem.hidesBackButton = true
        return viewController
    }

    private func showErrorAlert(_ error: AuthorizationFailure) {
        performOnMain { [weak self] in
            guard let self else { return }

            let viewController = alertViewControllerFactory.makeConfirmationAlert(
                popUpType: .error,
                title: error.summary.isEmpty ? "API.lb.error".localized : error.summary,
                description: error.message,
                onTapp: { [weak self] _ in
                    self?.navigationController.dismiss(animated: true)
                }
            )
            navigationController.present(viewController, animated: true)
        }
    }

    private func showSafari(path: String) {
        performOnMain { [weak self] in
            guard
                let environment = self?.environmentStorage.getEnvironment(),
                let url = URL(string: "https://\(environment.host)\(environment.path)\(path)")
            else {
                return
            }

            UIApplication.shared.open(url)
        }
    }

    private func performOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
