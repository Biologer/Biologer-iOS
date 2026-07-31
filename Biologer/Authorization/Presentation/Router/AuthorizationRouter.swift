//
//  AuthorizationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import UIKit
import SwiftUI

public final class AuthorizationRouter {
    private let version: AuthorizationUIVersion
    private let factory: AuthorizationViewControllerFactory
    private let navigationController: UINavigationController
    private let authorizationUseCases: AuthorizationUseCases
    private let registerService: RegisterUserService
    private let commonViewControllerFactory: CommonViewControllerFactory
    private let swiftUICommonViewControllerFactory: CommonViewControllerFactory
    private let swiftUIAlertViewControllerFactory: AlertViewControllerFactory
    private let environmentStorage: EnvironmentStorage
    private let tutorialRepository: AuthorizationTutorialRepository
    private let tokenStorage: TokenStorage
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage
    private let envFactory = EnvironmentViewModelFactory()
    public var onLoginSuccess: Observer<Void>?
    private var selectedEnvironmentImage: String = ""

    init(version: AuthorizationUIVersion,
         factory: AuthorizationViewControllerFactory,
         commonViewControllerFactory: CommonViewControllerFactory,
         swiftUICommonViewControllerFactory: CommonViewControllerFactory,
         swiftUIAlertViewControllerFactory: AlertViewControllerFactory,
         navigationController: UINavigationController,
         authorizationUseCases: AuthorizationUseCases,
         registerService: RegisterUserService,
         environmentStorage: EnvironmentStorage,
         tutorialRepository: AuthorizationTutorialRepository,
         tokenStorage: TokenStorage,
         dataLicenseStorage: LicenseStorage,
         imageLicenseStorage: LicenseStorage) {
        self.version = version
        self.factory = factory
        self.commonViewControllerFactory = commonViewControllerFactory
        self.swiftUICommonViewControllerFactory = swiftUICommonViewControllerFactory
        self.swiftUIAlertViewControllerFactory = swiftUIAlertViewControllerFactory
        self.navigationController = navigationController
        self.authorizationUseCases = authorizationUseCases
        self.registerService = registerService
        self.environmentStorage = environmentStorage
        self.tutorialRepository = tutorialRepository
        self.tokenStorage = tokenStorage
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage  = imageLicenseStorage
    }

    public func start(shouldPresentIntroScreens: Bool) {
        if shouldPresentIntroScreens {
            showHelpScreen()
        } else {
            showAuthorization()
        }
    }

    public func restart() {
        navigationController.setViewControllers([makeAuthorizationViewController()], animated: false)
    }

    lazy var onLoading: Observer<Bool> = { [weak self] isLoading in
        self?.performOnMain { [weak self] in
            guard let self = self else { return }
            if isLoading {
                let loader = self.commonViewControllerFactory.createBlockingProgress()
                self.navigationController.present(loader, animated: false, completion: nil)
            } else {
                self.navigationController.dismiss(animated: false, completion: nil)
            }
        }
    }

    private func makeLoginViewController() -> UIViewController {

        var envDelegate: EnvironmentScreenViewModelProtocol?

        let defaultEnv = envFactory.createEnvironment(type: .serbia)
        environmentStorage.saveEnvironment(env: defaultEnv.env)
        selectedEnvironmentImage = defaultEnv.image

        let loginViewController = factory.makeLoginScreen(useCase: authorizationUseCases.login,
                                                          environmentViewModel: defaultEnv,
                                                             onSelectEnvironmentTapped: { [weak self] env in
                                                                self?.showEnvironmentScreen(selectedViewModel: env,
                                                                                            delegate: envDelegate)
                                                             },
                                                             onLoginSuccess: { [weak self] in
                                                                self?.onLoginSuccess?(())
                                                             },
                                                             onLoginError: { [weak self] error in
                                                                self?.showErrorAlert(popUpType: .error,
                                                                                     title: error.summary.isEmpty ? "API.lb.error".localized : error.summary,
                                                                                     description: error.message)
                                                             },
                                                             onRegisterTapped: { [weak self] _ in
                                                                self?.showRegisterStepOneScreen()
                                                             },
                                                             onForgotPasswordTapped: { [weak self] _ in
                                                                self?.showSafari(path: "/password/reset")
                                                             },
                                                             onLoading: onLoading)

        let viewController = loginViewController as? UIHostingController<LoginScreen<LoginScreenViewModel>>
        envDelegate = viewController?.rootView.viewModel

        loginViewController.navigationItem.hidesBackButton = true
        return loginViewController
    }

    private func showAuthorization() {
        navigationController.pushViewController(makeAuthorizationViewController(), animated: true)
    }

    private func makeAuthorizationViewController() -> UIViewController {
        switch version {
        case .v1:
            return makeLoginViewController()
        case .v2:
            return makeAuthorizationFlowV2ViewController()
        }
    }

    private func makeAuthorizationFlowV2ViewController() -> UIViewController {
        let loginFlow = AuthorizationFlow(
            authorizationUseCases: authorizationUseCases,
            onAuthorizationSuccess: { [weak self] _ in
                self?.performOnMain { [weak self] in
                    self?.onLoginSuccess?(())
                }
            },
            onForgotPassword: { [weak self] _ in
                self?.showSafari(path: "/password/reset")
            },
            onPrivacyPolicy: { [weak self] _ in
                self?.showSafari(path: "/pages/privacy-policy")
            },
            onLoginError: { [weak self] error in
                self?.showErrorAlert(
                    popUpType: .error,
                    title: error.summary.isEmpty ? "API.lb.error".localized : error.summary,
                    description: error.message
                )
            }
        )
        let viewController = UIHostingController(rootView: loginFlow)
        viewController.navigationItem.hidesBackButton = true
        return viewController
    }

    private func showEnvironmentScreen(selectedViewModel: EnvironmentViewModel,
                                       delegate: EnvironmentScreenViewModelProtocol? = nil) {

        let envs = envFactory.createAllEnvironments()
        let enviViewController = factory.makeEnvironmentScreen(selectedViewModel: selectedViewModel,
                                                               envViewModels: envs,
                                                               delegate: delegate,
                                                               onSelectedEnvironment: { [weak self] env in
                                                                    self?.environmentStorage.saveEnvironment(env: env.env)
                                                                    self?.selectedEnvironmentImage = env.image
                                                                    self?.navigationController.setNavigationBarTransparent(true)
                                                                    self?.navigationController.popViewController(animated: true)
                                                       })

        enviViewController.setBiologerBackBarButtonItem { [weak self] in
            self?.navigationController.setNavigationBarTransparent(true)
            self?.goBack()
        }
        enviViewController.setBiologerTitle(text: "Env.nav.title".localized)
        self.navigationController.setNavigationBarTransparent(false)
        self.navigationController.pushViewController(enviViewController, animated: true)
    }

    private func showRegisterStepOneScreen() {
        let stepOneViewController = factory.makeRegisterFirstStepScreen(user: RegisterUser(),
                                                                        onNextTapped: { [weak self] user in
                                                                            self?.showRegisterStepTwoScreen(user: user)
                                                                        })
        stepOneViewController.setBiologerBackBarButtonItem { [weak self] in
            self?.navigationController.setNavigationBarTransparent(true)
            self?.goBack()
        }
        stepOneViewController.setBiologerTitle(text: "Register.one.nav.title".localized)
        self.navigationController.setNavigationBarTransparent(false)
        self.navigationController.pushViewController(stepOneViewController, animated: true)
    }

    private func showRegisterStepTwoScreen(user: RegisterUser) {
        let stepTwoViewController = factory.makeRegisterSecondStepScreen(user: user,
                                                                         onNextTapped: { [weak self] user in
                                                                            self?.showRegisterThirdStepScreen(user: user)
                                                                         })
        stepTwoViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepTwoViewController.setBiologerTitle(text: "Register.two.nav.title".localized)
        self.navigationController.pushViewController(stepTwoViewController, animated: true)
    }

    private func showRegisterThirdStepScreen(user: RegisterUser) {

        let dataLicenses = CheckMarkItemMapper.getDataLicense()

        let imageLicenses = CheckMarkItemMapper.getImageLicense()

        let dataLicense = dataLicenses[0]
        let imageLicense = imageLicenses[0]

        var dataLicenseDelegate: CheckMarkScreenDelegate?

        let stepThirdViewController = factory.makeRegisterThreeStepScreen(user: user,
                                                                          topImage: self.selectedEnvironmentImage,
                                                                          service: registerService,
                                                                          dataLicense: dataLicense,
                                                                          imageLicense: imageLicense,
                                                                          dataLicenseStorage: dataLicenseStorage,
                                                                          imageLicenseStorage: imageLicenseStorage,
                                                                          onReadPrivacyPolicy: { [weak self] _ in
            self?.showSafari(path: "/pages/privacy-policy")
        },
                                                                          onDataLicense: { [weak self] dataLicense in
            self?.showLicenseScreen(isDataLicense: true,
                                    selectedItem: dataLicense,
                                    items: dataLicenses,
                                    presentDatePicker: dataLicenseDelegate)
        },
                                                                          onImageLicense: { [weak self] imageLicense in
            self?.showLicenseScreen(isDataLicense: false,
                                    selectedItem: imageLicense,
                                    items: imageLicenses,
                                    presentDatePicker: dataLicenseDelegate)
        },
                                                                          onSuccess: { [weak self] token in
            self?.tokenStorage.saveToken(token: token)
            self?.showConfirmAlert(popUpType: .success,
                                   title: "Register.three.successPopUp.title".localized,
                                   description: "Register.three.successPopUp.description".localized,
                                   onTap: { _ in
                self?.navigationController.dismiss(animated: true, completion: nil)
                self?.onLoginSuccess?(())
            })
        },
                                                                          onError: { [weak self] error in
            self?.showErrorAlert(popUpType: .error,
                                 title: error.title,
                                 description: error.description)
        },
                                                                          onLoading: onLoading)

        let viewController = stepThirdViewController as? UIHostingController<RegisterStepThreeScreen<RegisterStepThreeScreenViewModel>>
        dataLicenseDelegate = viewController?.rootView.loader

        stepThirdViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepThirdViewController.setBiologerTitle(text: "Register.three.nav.title".localized)
        self.navigationController.pushViewController(stepThirdViewController, animated: true)
    }

    private func showLicenseScreen(isDataLicense: Bool,
                                   selectedItem: CheckMarkItem,
                                   items: [CheckMarkItem],
                                   presentDatePicker: CheckMarkScreenDelegate?) {

        let dataLicenseViewController = swiftUICommonViewControllerFactory.makeLicenseScreen(items: items,
                                                                                             selectedItem: selectedItem,
                                                                  delegate: presentDatePicker) { [weak self] dataLicenses in
            self?.navigationController.popViewController(animated: true)
        }
        dataLicenseViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        dataLicenseViewController.setBiologerTitle(text: isDataLicense ? "DataLicense.nav.title".localized : "ImgLicense.nav.title".localized
        )
        self.navigationController.pushViewController(dataLicenseViewController, animated: true)
    }

    private func showHelpScreen() {
        let vc = swiftUICommonViewControllerFactory.makeHelpScreen(onDone: { [weak self] _ in
            self?.tutorialRepository.markPresented()
            self?.showAuthorization()
        })
        vc.removeBackButtonItem()
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func showConfirmAlert(popUpType: PopUpType,
                                  title: String,
                                  description: String,
                                  onTap: @escaping Observer<Void>) {
        performOnMain { [weak self] in
            guard let self = self else { return }
            let vc = self.swiftUIAlertViewControllerFactory.makeConfirmationAlert(popUpType: popUpType,
                                                                                  title: title,
                                                                                  description: description,
                                                                                  onTapp: onTap)
            self.navigationController.present(vc, animated: true, completion: nil)
        }
    }

    private func showErrorAlert(popUpType: PopUpType,
                                title: String,
                                description: String) {
        performOnMain { [weak self] in
            guard let self = self else { return }
            let vc = self.swiftUIAlertViewControllerFactory.makeConfirmationAlert(popUpType: popUpType,
                                                                                  title: title,
                                                                                  description: description,
                                                                                  onTapp: { [weak self] _ in
                                                                                    self?.navigationController.dismiss(animated: true, completion: nil)
                                                                                  })
            self.navigationController.present(vc, animated: true, completion: nil)
        }
    }

    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }

    private func showSafari(path: String) {
        performOnMain { [weak self] in
            guard let self = self, let env = self.environmentStorage.getEnvironment() else { return }
            let url = "https://\(env.host)\(env.path)\(path)"
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
    }

    private func performOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async {
                action()
            }
        }
    }
}
