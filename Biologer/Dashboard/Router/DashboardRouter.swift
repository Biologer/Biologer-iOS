//
//  DashboardRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 15.6.21..
//

import UIKit

public final class DashboardRouter: NavigationRouter {
    
    private let navigationController: UINavigationController
    private let factory: DashboardViewControllerFactory
    
    init(navigationController: UINavigationController,
         factory: DashboardViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    public func start() {
        showDashboardScreen()
    }
    
    private func showDashboardScreen() {
        let dashboardScreen = factory.createDashboardViewController(onNewItemTapped: { _ in},
                                                                    onItemTapped: { item in },
                                                                    onSideMenuItemTapped: { item in })
        self.navigationController.setViewControllers([dashboardScreen], animated: true)
    }
}
