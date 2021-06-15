//
//  AppNavigationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 15.6.21..
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
        authorizationRouter.onLoginTapped = { [weak self] _ in
            guard let self = self else { return }
            self.dashboardRouter.start()
            self.mainNavigationController.pushViewController(self.dashboardNavigationController, animated: true)
        }
    }
}
