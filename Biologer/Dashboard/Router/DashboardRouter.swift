//
//  DashboardRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import UIKit
import SwiftUI

public final class DashboardRouter: NavigationRouter {
    
    private let navigationController: UINavigationController
    private let factory: DashboardViewControllerFactory
    private var dashboardScreen: UIHostingController<SideMenu<SideMenuScreenViewModel>>?
    
    init(navigationController: UINavigationController,
         factory: DashboardViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    public func start() {
        showDashboardScreen()
    }
    
    private func showDashboardScreen() {
        let dashboardViewController = factory.createDashboardViewController(onNewItemTapped: { _ in},
                                                                    onItemTapped: { item in },
                                                                    onSideMenuItemTapped: { item in
                                                                        
                                                                        self.dashboardScreen?.rootView.loader.selectedItemType = item.type
                                                                        
                                                                        self.dashboardScreen?.rootView.loader.menuOpen = false
                                                                    },
                                                                    onLogoutTapped: { _ in
                                                                        
                                                                    })
        dashboardScreen = dashboardViewController as? UIHostingController<SideMenu<SideMenuScreenViewModel>>
        
        dashboardViewController.setBiologerBackBarButtonItem(image: UIImage(named: "side_menu_icon")!,
                                                               target: self,
                                                               action: #selector(self.sideMenuAction))
        self.navigationController.setViewControllers([dashboardViewController], animated: true)
    }
    
    @objc private func sideMenuAction() {
        dashboardScreen?.rootView.loader.menuOpen = true
    }
}
