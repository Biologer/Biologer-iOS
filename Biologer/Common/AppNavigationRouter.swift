//
//  AppNavigationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import Foundation

import UIKit

public protocol NavigationRouter {
    func start()
}

public final class AppNavigationRouter: NavigationRouter {
    private let dashboardNavigationController = UINavigationController()
    private let mainNavigationController: UINavigationController
    
    private lazy var authorizationRouter: AuthorizationRouter = {
        return AuthorizationRouter(factory: SwiftUILoginViewControllerFactory(),
                                   navigationController: mainNavigationController)
    }()
    
    private lazy var dashboardRouter: DashboardRouter = {
        return DashboardRouter(navigationController: dashboardNavigationController,
                               factory: SwiftUIDashboardViewControllerFactory())
    }()
    
    
    init(mainNavigationController: UINavigationController) {
        self.mainNavigationController = mainNavigationController
    }
    
    public func start() {
        authorizationRouter.start()
        authorizationRouter.onLoginTapped = { _ in
            self.dashboardRouter.start()
            self.dashboardNavigationController.modalPresentationStyle = .overFullScreen
            self.mainNavigationController.present(self.dashboardNavigationController,
                                                  animated: true,
                                                  completion: nil)
        }
    }
}
