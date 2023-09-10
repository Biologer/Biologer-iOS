//
//  DashboardRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import UIKit
import SwiftUI
import SideMenu

public final class SideMenuRouterRouter: NavigationRouter {
    
    private let navigationController: UINavigationController
    private let factory: SideMenuViewControllerFactory
    private let commonViewControllerFactory: CommonViewControllerFactory
    private let environmentStorage: EnvironmentStorage
    private let userStorage: UserStorage
    
    public var onLogout: Observer<Void>?
    public var onSetupScreen: Observer<Void>?
    public var onListOfFindingsScreen: Observer<Void>?
    
    init(navigationController: UINavigationController,
         environmentStorage: EnvironmentStorage,
         userStorage: UserStorage,
         factory: SideMenuViewControllerFactory,
         commonViewControllerFactory: CommonViewControllerFactory) {
        self.navigationController = navigationController
        self.environmentStorage = environmentStorage
        self.userStorage = userStorage
        self.factory = factory
        self.commonViewControllerFactory = commonViewControllerFactory
    }
    
    lazy var onLoading: Observer<Bool> = { [weak self] isLoading in
        guard let self = self else { return }
        if isLoading {
            let loader  = self.commonViewControllerFactory.createBlockingProgress()
            self.navigationController.present(loader, animated: false, completion: nil)
        } else {
            self.navigationController.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Public Functions
    
    public func start() {
        let sideMenuListScreen = factory.makeSideMenuListScreen(email: userStorage.getUser()?.email ?? "",
                                                                username: userStorage.getUser()?.fullName ?? "",
                                                                onItemTapped: { item in
            self.navigationController.dismiss(animated: true, completion: nil)
            self.showScreenFormSideMenu(item: item.type)
        })
        let menu = SideMenuNavigationController(rootViewController: sideMenuListScreen)
        menu.setNavigationBarTransparent(false)
        menu.leftSide = true
        self.navigationController.present(menu, animated: true, completion: nil)
    }
    
    // MARK: - Private Functions
    
    private func showListOfFindings() {
        onListOfFindingsScreen?(())
    }
    
    private func showSetupScreen() {
        onSetupScreen?(())
    }
    
    private func showLogoutScreen() {
        let vc = factory.makeLogoutScreen(userEmail: userStorage.getUser()?.email ??  "",
                                          username: userStorage.getUser()?.fullName ?? "",
                                          currentEnv: "https://\(environmentStorage.getEnvironment()?.host ?? "")",
                                          onLogoutTapped: { _ in
            self.onLogout?(())
        })
        vc.setBiologerTitle(text: "SideMenu.lb.Logout".localized)
        addSideMenuIcons(vc: vc)
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
            let appVersionString = "AboutBiologer.lb.appVersion".localized
            appVersion = "\(appVersionString) \(version) (\(build))"
        }
        let vc = factory.makeAboutScreen(currentEnv: currentEnv,
                                         version: appVersion,
                                         onEnvTapped: { [weak self] urlString in
            self?.showSafari(path: urlString)
        })
        addSideMenuIcons(vc: vc)
        vc.setBiologerTitle(text: "SideMenu.lb.aboutUs".localized)
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showHelpScreen() {
        let vc = commonViewControllerFactory.makeHelpScreen(onDone: { _ in
            
        })
        addSideMenuIcons(vc: vc)
        vc.setBiologerTitle(text: "SideMenu.lb.Help".localized)
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showDeleteAccountScreen() {
        let vc = factory.makeDeleteAccountScreen(userEmail: userStorage.getUser()?.email ??  "",
                                                 username: userStorage.getUser()?.fullName ?? "",
                                                 currentEnv: "https://\(environmentStorage.getEnvironment()?.host ?? "")",
                                                 onDeleteAccountTapped: { [weak self] _ in
            guard let self = self else { return }
            guard let env = self.environmentStorage.getEnvironment() else {
                return
            }
            
            var url = ""
            let currentLanguage = NSLocale.current.languageCode
            print("Language: \(String(describing: currentLanguage))")
            
            if currentLanguage == "en" {
                url = "https://biologer.rs/en/preferences/account"
            } else {
                url = "https://biologer.rs\(env.path)/preferences/account"
            }
            
            self.showSafari(path: url)
            self.onLogout?(())
        })
        vc.setBiologerTitle(text: "SideMenu.lb.DeleteAccount".localized)
        addSideMenuIcons(vc: vc)
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
        case .deleteAccount:
            showDeleteAccountScreen()
        }
    }
    
    private func addSideMenuIcons(vc: UIViewController) {
        vc.setBiologerBackBarButtonItem(image: UIImage(named: "side_menu_icon")!,
                                        target: self,
                                        action: #selector(self.sideMenuAction))
    }
    
    @objc private func sideMenuAction() {
        self.start()
    }
    private func showSafari(path: String) {
        if let url = URL(string: path) {
            UIApplication.shared.open(url)
        }
    }
}
