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
    private let setupRouter: SetupRouter
    private let taxonRouter: TaxonRouter
    private let factory: DashboardViewControllerFactory
    private let environmentStorage: EnvironmentStorage
    public var onLogout: Observer<Void>?
    
    init(navigationController: UINavigationController,
         mainNavigationController: UINavigationController,
         setupRouter: SetupRouter,
         taxonRouter: TaxonRouter,
         environmentStorage: EnvironmentStorage,
         factory: DashboardViewControllerFactory) {
        self.navigationController = navigationController
        self.mainNavigationController = mainNavigationController
        self.setupRouter = setupRouter
        self.taxonRouter = taxonRouter
        self.environmentStorage = environmentStorage
        self.factory = factory
    }
    
    public func start() {
        showListOfFindings()
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
    
    private func showListOfFindings() {
        taxonRouter.start()
        taxonRouter.onSideMenuTapped = { [weak self] _ in
            self?.showSideMenu()
        }
    }
    
    private func showSetupScreen() {
        setupRouter.start()
        setupRouter.onSideMenuTapped = { [weak self] _ in
            self?.showSideMenu()
        }
    }
    
    private func showLogoutScreen() {
        let vc = factory.makeLogoutScreen(onLogoutTapped: { _ in
            self.onLogout?(())
        })
        addSideMenuIcon(vc: vc)
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showAboutBiologerScreen() {
        var currentEnv = ""
        var appVersion = ""
        if let env = environmentStorage.getEnvironment() {
            currentEnv = "https://\(env.host)"
        }
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String{
            appVersion = "App Version: \(version) (\(build))"
        }
        let vc = factory.makeAboutScreen(currentEnv: currentEnv,
                                         version: appVersion,
                                         onEnvTapped: { [weak self] urlString in
                                            self?.showSafari(path: urlString)
                                         })
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
            showListOfFindings()
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
