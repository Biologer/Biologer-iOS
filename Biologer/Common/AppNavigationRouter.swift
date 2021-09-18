//
//  AppNavigationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import Foundation

import UIKit
import SwiftUI

public protocol NavigationRouter {
    func start()
}

public final class AppNavigationRouter: NavigationRouter {
    private let dashboardNavigationController = UINavigationController()
    private let mainNavigationController: UINavigationController
    
    private lazy var httpClient: HTTPClient = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20
        sessionConfig.timeoutIntervalForResource = 20
        let session = URLSession(configuration: sessionConfig)
        let client = URLSessionHTTPClient(session: session)
        let mainQueueDecorator = MainQueueHTTPClientDecorator(decoratee: client)
        return mainQueueDecorator
    }()
    
    private lazy var authorizationRouter: AuthorizationRouter = {
        let loginService = RemoteLoginUserService(client: httpClient, environmentStorage: environmentStorage)
        let registerService = RemoteRegisterUserService(client: httpClient, environmentStorage: environmentStorage)
        let forgotPasswordService = RemoteForgotPasswordService(client: httpClient)
        
        let authorization =  AuthorizationRouter(factory: authorizationFactory,
                                   commonViewControllerFactory: commonViewControllerFactory,
                                   swiftUICommonViewControllerFactory: SwiftUICommonViewControllerFactrory(),
                                   swiftUIAlertViewControllerFactory: swiftUIAlertViewControllerFactory,
                                   navigationController: mainNavigationController,
                                   loginService: loginService,
                                   registerService: registerService,
                                   forgotPasswordService: forgotPasswordService,
                                   environmentStorage: environmentStorage,
                                   tokenStorage: tokenStorage)
        authorization.onLoginSuccess = { _ in
            self.showDashboardRouter()
        }
        return authorization
    }()
    
    private lazy var environmentStorage: EnvironmentStorage = {
        return KeychainEnvironmentStorage()
    }()
    
    private lazy var authorizationFactory: AuthorizationViewControllerFactory = {
        return SwiftUILoginViewControllerFactory()
    }()
    
    private lazy var tokenStorage: TokenStorage = {
        return KeychainTokenStorage()
    }()
    
    private lazy var commonViewControllerFactory: CommonViewControllerFactory = {
        return IOSUIKitCommonViewControllerFactory()
    } ()
    
    private lazy var swiftUIAlertViewControllerFactory: AlertViewControllerFactory = {
        return SwiftUIAlertViewController()
    }()
    
    private lazy var dashboardRouter: DashboardRouter = {
        let dashboardRouter = DashboardRouter(navigationController: dashboardNavigationController,
                               mainNavigationController: mainNavigationController,
                               setupRouter: setupRouter,
                               factory: SwiftUIDashboardViewControllerFactory())
        
        dashboardRouter.onLogout = { _ in
            self.tokenStorage.delete()
            self.mainNavigationController.dismiss(animated: true, completion: {
                if let vc = self.mainNavigationController.viewControllers.filter({ $0 is UIHostingController<LoginScreen<LoginScreenViewModel>> }).first {
                    self.mainNavigationController.popToViewController(vc, animated: false)
                } else {
                    self.authorizationRouter.start()
                }
            })
        }
        return dashboardRouter
    }()
    
    private lazy var setupRouter: SetupRouter = {
       let setupRouter = SetupRouter(navigationController: dashboardNavigationController,
                                     factory: SwiftUISetupViewControllerFactory(),
                                     swiftUICommonFactory: SwiftUICommonViewControllerFactrory())
        return setupRouter
    }()
    
    init(mainNavigationController: UINavigationController) {
        self.mainNavigationController = mainNavigationController
        self.mainNavigationController.setNavigationBarTransparency()
    }
    
    public func start() {
        launchApp()
    }
    
    private func showDashboardRouter() {
        self.dashboardRouter.start()
        UINavigationBar.appearance().barTintColor = .biologerGreenColor
        self.dashboardNavigationController.modalPresentationStyle = .overFullScreen
        self.mainNavigationController.present(self.dashboardNavigationController,
                                              animated: true,
                                              completion: nil)
    }
    
    private func launchApp() {
        if let _ = tokenStorage.getToken() {
            let vc = authorizationFactory.makeSplashScreen(onSplashScreenDone: { _ in
                self.showDashboardRouter()
            })
            self.mainNavigationController.setViewControllers([vc], animated: false)
        } else {
            let vc = authorizationFactory.makeSplashScreen(onSplashScreenDone: { _ in
                self.authorizationRouter.start()
            })
            self.mainNavigationController.setViewControllers([vc], animated: false)
        }
    }
}
