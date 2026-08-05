//
//  DashboardRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.6.21..
//

import UIKit
import SwiftUI
import SideMenu

public final class SideMenuRouterRouter {
    
    private let navigationController: UINavigationController
    private let mainNavigationController: UINavigationController
    private let taxonRouter: TaxonRouter
    private let setupUseCase: SetupUseCase
    private let factory: DashboardViewControllerFactory
    private let uiKitCommonViewControllerFactory: CommonViewControllerFactory
    private let swiftUICommonViewControllerFactory: CommonViewControllerFactory
    private let swiftUIAlertViewControllerFactory: AlertViewControllerFactory
    private let environmentStorage: EnvironmentStorage
    private let userStorage: UserStorage
    private let userAccountUseCase: UserAccountUseCase
    public var onLogout: Observer<Void>?
    public var onStartDownloadTaxon: Observer<Void>?
    
    init(navigationController: UINavigationController,
         mainNavigationController: UINavigationController,
         taxonRouter: TaxonRouter,
         setupUseCase: SetupUseCase,
         environmentStorage: EnvironmentStorage,
         userStorage: UserStorage,
         userAccountUseCase: UserAccountUseCase,
         factory: DashboardViewControllerFactory,
         swiftUIAlertViewControllerFactory: AlertViewControllerFactory,
         uiKitCommonViewControllerFactory: CommonViewControllerFactory,
         swiftUICommonViewControllerFactory: CommonViewControllerFactory) {
        self.navigationController = navigationController
        self.mainNavigationController = mainNavigationController
        self.taxonRouter = taxonRouter
        self.setupUseCase = setupUseCase
        self.environmentStorage = environmentStorage
        self.userStorage = userStorage
        self.userAccountUseCase = userAccountUseCase
        self.factory = factory
        self.uiKitCommonViewControllerFactory = uiKitCommonViewControllerFactory
        self.swiftUICommonViewControllerFactory = swiftUICommonViewControllerFactory
        self.swiftUIAlertViewControllerFactory = swiftUIAlertViewControllerFactory
    }
    
    public func start() {
        showListOfFindings()
    }
    
    lazy var onLoading: Observer<Bool> = { [weak self] isLoading in
        self?.performOnMain { [weak self] in
            guard let self = self else { return }
            if isLoading {
                let loader = self.uiKitCommonViewControllerFactory.createBlockingProgress()
                self.navigationController.present(loader, animated: false, completion: nil)
            } else {
                self.navigationController.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    private func showSideMenu() {
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
    
    private func showListOfFindings() {
        taxonRouter.start()
        taxonRouter.onSideMenuTapped = { [weak self] _ in
            self?.showSideMenu()
        }
    }
    
    private func showSetupScreen() {
        let setupFlow = SetupFlow(
            setupUseCase: setupUseCase,
            onSideMenuTapped: { [weak self] _ in
                self?.showSideMenu()
            },
            onStartDownloadTaxon: { [weak self] _ in
                self?.onStartDownloadTaxon?(())
            }
        )
        let vc = UIHostingController(rootView: setupFlow)
        self.navigationController.setViewControllers([vc], animated: false)
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
        let vc = swiftUICommonViewControllerFactory.makeHelpScreen(onDone: { _ in
            
        })
        addSideMenuIcons(vc: vc)
        vc.setBiologerTitle(text: "SideMenu.lb.Help".localized)
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showDeleteAccountScreen() {
        let vc = factory.makeDeleteAccountScreen(userEmail: userStorage.getUser()?.email ??  "",
                                                 username: userStorage.getUser()?.fullName ?? "",
                                                 currentEnv: "https://\(environmentStorage.getEnvironment()?.host ?? "")",
                                                 onDeleteAccountTapped: { [weak self] deleteObservations in
            guard let self = self else { return }

            Task {
                do {
                    try await self.userAccountUseCase.deleteCurrentUser(deleteObservations: deleteObservations)
                    await MainActor.run {
                    self.showInfoAlert(popUpType: .success, title: "DeleteAccount.lb.successTitle".localized, description: "", completion: {
                        print("User deleted successfully")
                        
                        self.onLogout?(())
                        self.userStorage.deleteAllForUser()
                    })
                    }
                } catch let error as APIError {
                    await MainActor.run {
                        self.showErrorAlert(popUpType: .error, title: error.title, description: error.description)
                        print("Error: \(error.description)")
                    }
                } catch {
                    await MainActor.run {
                        self.showErrorAlert(
                            popUpType: .error,
                            title: "API.lb.error".localized,
                            description: error.localizedDescription
                        )
                    }
                }
            }
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
        self.showSideMenu()
    }
    private func showSafari(path: String) {
        if let url = URL(string: path) {
            UIApplication.shared.open(url)
        }
    }
    
    private func showErrorAlert(popUpType: PopUpType,
                                title: String,
                                description: String) {
        performOnMain { [weak self] in
            guard let self = self else { return }
            let vc = self.swiftUIAlertViewControllerFactory.makeConfirmationAlert(popUpType: popUpType,
                                                                                  title: title,
                                                                                  description: description,
                                                                                  onTapp: { [weak self] _ in
                                                                                    self?.navigationController.dismiss(animated: true, completion: nil)
                                                                                  })
            self.navigationController.present(vc, animated: true, completion: nil)
        }
    }
    
    private func showInfoAlert(popUpType: PopUpType,
                                title: String,
                                description: String,
                               completion: @escaping (() -> Void)) {
        performOnMain { [weak self] in
            guard let self = self else { return }
            let vc = self.swiftUIAlertViewControllerFactory.makeConfirmationAlert(popUpType: popUpType,
                                                                                  title: title,
                                                                                  description: description,
                                                                                  onTapp: { [weak self] _ in
                                                                                    self?.navigationController.dismiss(animated: true, completion: completion)
                                                                                  })
            self.navigationController.present(vc, animated: true, completion: nil)
        }
    }

    private func performOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async {
                action()
            }
        }
    }
}
