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
    public var onLogout: Observer<Void>?
    
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
    
    private func showSideMenu() {
        let sideMenuListScreen = factory.makeSideMenuListScreen(onItemTapped: { item in
            self.navigationController.dismiss(animated: true, completion: nil)
            self.showScreenFormSideMenu(item: item.type)
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
    
    private func showSetupScreen() {
        let vc = factory.makeSetupScreen(onItemTapped: { item in
            // Present some screen by item type
        })
        addSideMenuIcon(vc: vc)
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showLogoutScreen() {
        let vc = factory.makeLogoutScreen(onLogoutTapped: { _ in
            self.onLogout?(())
        })
        addSideMenuIcon(vc: vc)
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showAboutBiologerScreen() {
        let vc = factory.makeAboutScreen()
        addSideMenuIcon(vc: vc)
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showHelpScreen() {
        let vc = factory.makeHelpScreen(onDone: { _ in
            
        })
        addSideMenuIcon(vc: vc)
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showScreenFormSideMenu(item: SideMenuItemType) {
        switch item {
        case .listOfFindings:
            showDashboardScreen()
        case .setup:
            showSetupScreen()
        case .logout:
            showLogoutScreen()
        case .about:
            showAboutBiologerScreen()
        case .help:
            showHelpScreen()
        }
    }
    
    private func addSideMenuIcon(vc: UIViewController) {
        vc.setBiologerBackBarButtonItem(image: UIImage(named: "side_menu_icon")!,
                                                               target: self,
                                                               action: #selector(self.sideMenuAction))
    }
    
    @objc private func sideMenuAction() {
        self.showSideMenu()
    }
    
    private func showSafari(path: String) {
        if let url = URL(string: path) {
            UIApplication.shared.open(url)
        }
    }
}
