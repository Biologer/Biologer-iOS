//
//  DashboardRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import UIKit
import SwiftUI
import SideMenu

public final class DashboardRouter: NavigationRouter {
    
    private let navigationController: UINavigationController
    private let mainNavigationController: UINavigationController
    private let factory: DashboardViewControllerFactory
    
    init(navigationController: UINavigationController,
         mainNavigationController: UINavigationController,
         factory: DashboardViewControllerFactory) {
        self.navigationController = navigationController
        self.mainNavigationController = mainNavigationController
        self.factory = factory
    }
    
    public func start() {
        showDashboardScreen()
    }
    
    private func sideMenu() {
        let sideMenuListScreen = factory.makeSideMenuListScreen(onItemTapped: { item in
            self.navigationController.dismiss(animated: true, completion: nil)
            self.presentItemFormSideMenu(item: item.type)
        })
        let menu = SideMenuNavigationController(rootViewController: sideMenuListScreen)
        menu.leftSide = true
        self.navigationController.present(menu, animated: true, completion: nil)
    }
    
    private func showDashboardScreen() {
        let dashboardViewController = factory.makeListOfFindingsScreen(onNewItemTapped: { _ in
                            
                                                                            },
                                                                            onItemTapped: { item in
                                                                        
                                                                            })
        addSideMenuIcon(vc: dashboardViewController)
        self.navigationController.setViewControllers([dashboardViewController], animated: false)
    }
    
    private func presentSetupScreen() {
        let vc = factory.makeSetupScreen()
        addSideMenuIcon(vc: vc)
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func presentItemFormSideMenu(item: SideMenuItemType) {
        switch item {
        case .listOfFindings:
            showDashboardScreen()
        case .setup:
            presentSetupScreen()
        default:
            break
        }
    }
    
    private func addSideMenuIcon(vc: UIViewController) {
        vc.setBiologerBackBarButtonItem(image: UIImage(named: "side_menu_icon")!,
                                                               target: self,
                                                               action: #selector(self.sideMenuAction))
    }
    
    @objc private func sideMenuAction() {
        self.sideMenu()
    }
    
    private func showSafari(path: String) {
        if let url = URL(string: path) {
            UIApplication.shared.open(url)
        }
    }
}
