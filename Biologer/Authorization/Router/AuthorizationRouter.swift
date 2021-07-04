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
                                                                         onNextTapped: { user in
                                                                            
                                                                         })
        stepTwoViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        stepTwoViewController.setBiologerTitle(text: "REGISTER STEP TWO")
        self.navigationController.pushViewController(stepTwoViewController, animated: true)
    }
    
    private func showRegisterThirdStepScreen(user: User) {
        
    }
    
    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }
}
