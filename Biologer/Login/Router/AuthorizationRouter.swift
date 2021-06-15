//
//  AuthorizationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 15.6.21..
//

import UIKit

public final class AuthorizationRouter: NavigationRouter {
    private let factory: AuthorizationViewControllerFactory
    private let navigationController: UINavigationController
    public var onLoginTapped: Observer<Void>?
    
    init(factory: AuthorizationViewControllerFactory, navigationController: UINavigationController) {
        self.factory = factory
        self.navigationController = navigationController
    }
    
    public func start() {
        showLoginScreen()
    }
    
    private func showLoginScreen() {
        let loginViewController = factory.presentLoginScreen(onSelectEnvironmentTapped: { _ in },
                                                             onLoginTapped: { [weak self] _ in self?.onLoginTapped?(()) },
                                                             onRegisterTapped: { _ in },
                                                             onForgotPasswordTapped: { _ in })
        self.navigationController.setViewControllers([loginViewController], animated: false)
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
}
