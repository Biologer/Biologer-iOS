//
//  AppNavigationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import Foundation

import UIKit

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
        
        return AuthorizationRouter(factory: SwiftUILoginViewControllerFactory(),
                                   commonViewControllerFactory: commonViewControllerFactory,
                                   navigationController: mainNavigationController,
                                   loginService: loginService,
                                   registerService: registerService,
                                   forgotPasswordService: forgotPasswordService,
                                   environmentStorage: environmentStorage,
                                   tokenStorage: tokenStorage)
    }()
    
    private lazy var environmentStorage: EnvironmentStorage = {
        return KeychainEnvironmentStorage()
    }()
    
    private lazy var tokenStorage: TokenStorage = {
        return KeychainTokenStorage()
    }()
    
    private lazy var commonViewControllerFactory: CommonViewControllerFactory = {
        return IOSUIKitCommonViewControllerFactory()
    } ()
    
    private lazy var dashboardRouter: DashboardRouter = {
        return DashboardRouter(navigationController: dashboardNavigationController,
                               mainNavigationController: mainNavigationController,
                               factory: SwiftUIDashboardViewControllerFactory())
    }()
    
    
    init(mainNavigationController: UINavigationController) {
        self.mainNavigationController = mainNavigationController
        self.mainNavigationController.setNavigationBarTransparency()
    }
    
    public func start() {
        authorizationRouter.start()
        authorizationRouter.onLoginSuccess = { _ in
            self.dashboardRouter.start()
            UINavigationBar.appearance().barTintColor = .biologerGreenColor
            self.dashboardNavigationController.modalPresentationStyle = .overFullScreen
            self.mainNavigationController.present(self.dashboardNavigationController,
                                                  animated: true,
                                                  completion: nil)
        }
    }
}
