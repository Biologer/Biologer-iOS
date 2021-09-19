//
//  AuthorizationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import UIKit
import SwiftUI

public final class AuthorizationRouter: NavigationRouter {
    private let factory: AuthorizationViewControllerFactory
    private let navigationController: UINavigationController
    private let loginService: LoginUserService
    private let registerService: RegisterUserService
    private let forgotPasswordService: ForgotPasswordService
    private let commonViewControllerFactory: CommonViewControllerFactory
    private let swiftUICommonViewControllerFactory: CommonViewControllerFactory
    private let swiftUIAlertViewControllerFactory: AlertViewControllerFactory
    private let environmentStorage: EnvironmentStorage
    private let tokenStorage: TokenStorage
    private let envFactory = EnvironmentViewModelFactory()
    public var onLoginSuccess: Observer<Void>?
    private var selectedEnvironmentImage: String = ""
    
    init(factory: AuthorizationViewControllerFactory,
         commonViewControllerFactory: CommonViewControllerFactory,
         swiftUICommonViewControllerFactory: CommonViewControllerFactory,
         swiftUIAlertViewControllerFactory: AlertViewControllerFactory,
         navigationController: UINavigationController,
         loginService: LoginUserService,
         registerService: RegisterUserService,
         forgotPasswordService: ForgotPasswordService,
         environmentStorage: EnvironmentStorage,
         tokenStorage: TokenStorage) {
        self.factory = factory
        self.commonViewControllerFactory = commonViewControllerFactory
        self.swiftUICommonViewControllerFactory = swiftUICommonViewControllerFactory
        self.swiftUIAlertViewControllerFactory = swiftUIAlertViewControllerFactory
        self.navigationController = navigationController
        self.loginService = loginService
        self.registerService = registerService
        self.forgotPasswordService = forgotPasswordService
        self.environmentStorage = environmentStorage
        self.tokenStorage = tokenStorage
    }
    
    public func start() {
        showLoginScreen()
    }
    
    lazy var onLoading: Observer<Bool> = { [weak self] isLoading in
        guard let self = self else { return }
        if isLoading {
            let loader  = self.commonViewControllerFactory.createBlockingProgress()
            self.navigationController.present(loader, animated: false, completion: nil)
        } else {
            self.navigationController.dismiss(animated: false, completion: nil)
        }
    }
    
    private func showLoginScreen() {
        
        var envDelegate: EnvironmentScreenViewModelProtocol?
        
        let defaultEnv = envFactory.createEnvironment(type: .serbia)
        
        let loginViewController = factory.makeLoginScreen(service: loginService,
                                                          environmentViewModel: defaultEnv,
                                                             onSelectEnvironmentTapped: { [weak self] env in
                                                                self?.showEnvironmentScreen(selectedViewModel: env,
                                                                                            delegate: envDelegate)
                                                             },
                                                             onLoginSuccess: { [weak self]  token in
                                                                self?.tokenStorage.saveToken(token: token)
                                                                self?.onLoginSuccess?(())
                                                             },
                                                             onLoginError: { error in
                                                                self.showErrorAlert(title: error.title,
                                                                                    description: error.description)
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
        self.navigationController.pushViewController(loginViewController, animated: true)
    }
    
    private func showEnvironmentScreen(selectedViewModel: EnvironmentViewModel,
                                       delegate: EnvironmentScreenViewModelProtocol? = nil) {
        
        let envs = [envFactory.createEnvironment(type: .serbia),
                    envFactory.createEnvironment(type: .croatia),
                    envFactory.createEnvironment(type: .bosniaAndHerzegovina),
                    envFactory.createEnvironment(type: .develop)
        ]
        
        let enviViewController = factory.makeEnvironmentScreen(selectedViewModel: selectedViewModel,
                                                               envViewModels: envs,
                                                               delegate: delegate,
                                                               onSelectedEnvironment: { [weak self] env in
                                                                    self?.environmentStorage.saveEnvironment(env: env.env)
                                                                    self?.selectedEnvironmentImage = env.image
                                                                    self?.navigationController.popViewController(animated: true)
                                                       })
        
        enviViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        enviViewController.setBiologerTitle(text: "Env.nav.title".localized)
        self.navigationController.pushViewController(enviViewController, animated: true)
    }
    
    private func showRegisterStepOneScreen() {
        let stepOneViewController = factory.makeRegisterFirstStepScreen(user: User(),
                                                                        onNextTapped: { [weak self] user in
                                                                            self?.showRegisterStepTwoScreen(user: user)
                                                                        })
        stepOneViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepOneViewController.setBiologerTitle(text: "Register.one.nav.title".localized)
        self.navigationController.pushViewController(stepOneViewController, animated: true)
    }
    
    private func showRegisterStepTwoScreen(user: User) {
        let stepTwoViewController = factory.makeRegisterSecondStepScreen(user: user,
                                                                         onNextTapped: { [weak self] user in
                                                                            self?.showRegisterThirdStepScreen(user: user)
                                                                         })
        stepTwoViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepTwoViewController.setBiologerTitle(text: "Register.two.nav.title".localized)
        self.navigationController.pushViewController(stepTwoViewController, animated: true)
    }
    
    private func showRegisterThirdStepScreen(user: User) {
        
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
                                                                            self?.onLoginSuccess?(())
                                                                          },
                                                                          onError: { [weak self] error in
                                                                            self?.showErrorAlert(title: error.title,
                                                                                                 description: error.description)
                                                                          },
                                                                          onLoading: onLoading)
        
        let viewController = stepThirdViewController as? UIHostingController<RegisterStepThreeScreen<RegisterStepThreeScreenViewModel>>
        dataLicenseDelegate = viewController?.rootView.loader
        
        stepThirdViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepThirdViewController.setBiologerTitle(text: "REGISTER STEP THREE")
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
        dataLicenseViewController.setBiologerTitle(text: isDataLicense ? "DATA LICENSE" : "IMAGE LICENSE")
        self.navigationController.pushViewController(dataLicenseViewController, animated: true)
    }
    
    private func showErrorAlert(title: String, description: String) {
        let vc = swiftUIAlertViewControllerFactory.makeErrorAlert(title: title,
                                                                  description: description,
                                                                  onTapp: { _ in
                                                                    self.navigationController.dismiss(animated: true, completion: nil)
                                                                  })
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showSplashScreen() {
        let vc = factory.makeSplashScreen(onSplashScreenDone: {
            self.showLoginScreen()
        })
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }
    
    private func showSafari(path: String) {
        if let env = environmentStorage.getEnvironment() {
            let url = "https://\(env.host)\(env.path)\(path)"
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
