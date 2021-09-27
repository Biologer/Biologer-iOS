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
        let auth2HttpClientDecorator = Auth2HttpClientDecorator(decoratee: client, tokenStorage: tokenStorage)
        let mainQueueDecorator = MainQueueHTTPClientDecorator(decoratee: auth2HttpClientDecorator)
        let getTokenService = RemoteGetTokenService(client: mainQueueDecorator, environmentStorage: environmentStorage)
        let tokenRefreshDecorator = TokenRefreshingHTTPClientDecorator(decoratee: mainQueueDecorator,
                                                                       getTokenService: getTokenService,
                                                                       tokenStorage: tokenStorage)
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
    
    private lazy var userStorage: UserStorage = {
        return UserDefaultsUserStorage()
    }()
    
    private lazy var commonViewControllerFactory: CommonViewControllerFactory = {
        return IOSUIKitCommonViewControllerFactory()
    } ()
    
    private lazy var swiftUIAlertViewControllerFactory: AlertViewControllerFactory = {
        return SwiftUIAlertViewController()
    }()
    
    private lazy var remoteProfileService: ProfileService = {
       return RemoteProfileService(client: httpClient, environmentStorage: environmentStorage)
    }()
    
    private lazy var remoteObservationService: ObservationService = {
       return RemoteObservationService(client: httpClient, environmentStorage: environmentStorage)
    }()
    
    private lazy var getTokenService: RemoteGetTokenService = {
        return RemoteGetTokenService(client: httpClient, environmentStorage: environmentStorage)
    }()
    
    private lazy var dashboardRouter: DashboardRouter = {
        let dashboardRouter = DashboardRouter(navigationController: dashboardNavigationController,
                               mainNavigationController: mainNavigationController,
                               setupRouter: setupRouter,
                               taxonRouter: taxonRouter,
                               environmentStorage: environmentStorage,
                               userStorage: userStorage,
                               profileService: remoteProfileService,
                               factory: SwiftUIDashboardViewControllerFactory(),
                               uiKitCommonViewControllerFactory: commonViewControllerFactory)
        
        dashboardRouter.onLogout = { _ in
            self.logout()
        }
        return dashboardRouter
    }()
    
    private lazy var taxonRouter: TaxonRouter = {
        let taxonRouter = TaxonRouter(navigationController: dashboardNavigationController,
                                 factory: SwiftUITaxonViewControllerFactory(),
                                 swiftUICommonFactory: SwiftUICommonViewControllerFactrory(),
                                 uiKitCommonFactory: IOSUIKitCommonViewControllerFactory(),
                                 alertFactory: swiftUIAlertViewControllerFactory)
        return taxonRouter
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
                                              completion: {
                                                self.getMyProfile()
                                              })
    }
    
    private func logout() {
        self.environmentStorage.delete()
        self.mainNavigationController.dismiss(animated: true, completion: {
            if let vc = self.mainNavigationController.viewControllers.filter({ $0 is UIHostingController<LoginScreen<LoginScreenViewModel>> }).first {
                self.mainNavigationController.popToViewController(vc, animated: false)
            } else {
                self.authorizationRouter.start()
            }
        })
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
    
    lazy var onLoading: Observer<Bool> = { [weak self] isLoading in
        guard let self = self else { return }
        if isLoading {
            let loader  = self.commonViewControllerFactory.createBlockingProgress()
            self.dashboardNavigationController.present(loader, animated: false, completion: nil)
        } else {
            self.dashboardNavigationController.dismiss(animated: false, completion: nil)
        }
    }
    
    private func getMyProfile() {
        //onLoading((true))
        remoteProfileService.getMyProfile { result in
            switch result {
            case .failure(let error):
          //      self.onLoading((false))
                print("My profile error: \(error.description)")
                if !error.isInternetConnectionAvailable {
                    print("You don't have a internte connection")
                }
            case .success(let response):
                let user = User(id: response.data.id,
                                firstName: response.data.first_name,
                                lastName: response.data.last_name,
                                email: response.data.email,
                                fullName: response.data.full_name,
                                settings: User.Settings(dataLicense: response.data.settings.data_license,
                                                        imageLicense: response.data.settings.image_license,
                                                        language: response.data.settings.language))
                self.userStorage.save(user: user)
                self.getRefreshToken()
            }
        }
    }
    
    private func getObservation() {
        remoteObservationService.getObservation(completion: { result in
            switch result {
            case .failure(let error):
                print("Observation error: \(error.description)")
            case .success(let response):
                print("Observation response: \(response)")
            }
        })
    }
    
    private func getRefreshToken() {
        if let refreshToken = tokenStorage.getToken() {
            getTokenService.getToken(refreshToken: refreshToken.refreshToken) { result in
                switch result {
                case .failure(let error):
                    print("Refresh token error: \(error.description)")
                case .success(let token):
                    print("Refresh token: \(token.refreshToken)")
                    print("Access token: \(token.accessToken)")
                }
            }
        }
    }
}
