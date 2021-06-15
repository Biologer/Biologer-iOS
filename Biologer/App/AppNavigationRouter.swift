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
    
    init(mainNavigationController: UINavigationController) {
        self.mainNavigationController = mainNavigationController
    }
    
    public func start() {
        authorizationRouter.start()
        authorizationRouter.onLoginTapped = { _ in
            
        }
    }
}
