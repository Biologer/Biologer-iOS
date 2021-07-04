//
//  AuthorizationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import UIKit

public final class AuthorizationRouter: NavigationRouter {
    private let factory: AuthorizationViewControllerFactory
    private let navigationController: UINavigationController
    private let loginService: LoginUserService
    private let registerService: RegisterUserService
    private let forgotPasswordService: ForgotPasswordService
    public var onLoginTapped: Observer<Void>?
    
    init(factory: AuthorizationViewControllerFactory,
         navigationController: UINavigationController,
         loginService: LoginUserService,
         registerService: RegisterUserService,
         forgotPasswordService: ForgotPasswordService) {
        self.factory = factory
        self.navigationController = navigationController
        self.loginService = loginService
        self.registerService = registerService
        self.forgotPasswordService = forgotPasswordService
    }
    
    public func start() {
        showLoginScreen()
    }
    
    private func showLoginScreen() {
        let loginViewController = factory.makeLoginScreen(service: loginService,
                                                             onSelectEnvironmentTapped: { _ in },
                                                             onLoginTapped: { [weak self]  _ in
                                                                self?.onLoginTapped?(())
                                                             },
                                                             onRegisterTapped: { [weak self] _ in                                                                self?.showRegisterStepOneScreen()
                                                             },
                                                             onForgotPasswordTapped: { _ in })
        self.navigationController.setViewControllers([loginViewController], animated: false)
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    private func showRegisterStepOneScreen() {
        let stepOneViewController = factory.makeRegisterFirstStepScreen(user: User(),
                                                                        onNextTapped: { [weak self] user in
                                                                            self?.showRegisterStepTwoScreen(user: user)
                                                                        })
        stepOneViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepOneViewController.setBiologerTitle(text: "REGISTER STEP ONE")
        self.navigationController.pushViewController(stepOneViewController, animated: true)
    }
    
    private func showRegisterStepTwoScreen(user: User) {
        let stepTwoViewController = factory.makeRegisterSecondStepScreen(user: user,
                                                                         onNextTapped: { [weak self] user in
                                                                            self?.showRegisterThirdStepScreen(user: user)
                                                                         })
        stepTwoViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepTwoViewController.setBiologerTitle(text: "REGISTER STEP TWO")
        self.navigationController.pushViewController(stepTwoViewController, animated: true)
    }
    
    private func showRegisterThirdStepScreen(user: User) {
        
        let dataLicense = DataLicense(id: 1, title: "Free, NonCommercial (CC BY-SA-NC)", placeholder: "Data License")
        let imageLicense = DataLicense(id: 1, title: "Share images for free (CC-BY-SA)", placeholder: "Image License")
        
        let stepThirdViewController = factory.makeRegisterThreeStepScreen(user: user,
                                                                          service: registerService,
                                                                          dataLicense: dataLicense,
                                                                          imageLicense: imageLicense,
                                                                          onReadPrivacyPolicy: { _ in
                                                                            
                                                                          },
                                                                          onDataLicense: { _ in },
                                                                          onImageLicense: { _ in },
                                                                          onSuccess: { _ in },
                                                                          onError: { _ in })
        stepThirdViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepThirdViewController.setBiologerTitle(text: "REGISTER STEP THREE")
        self.navigationController.pushViewController(stepThirdViewController, animated: true)
    }
    
    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }
}
