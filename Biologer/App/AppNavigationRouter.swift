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
    private let sideMenuNavigationController = BiologerNavigationViewController(shouldBeTransparent: false)
    private let mainNavigationController: BiologerNavigationViewController
    private var downloadTaxonNavigationController: BiologerNavigationViewController?
    
    // MARK: - Services
    
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
        tokenRefreshDecorator.onLogout = {
            self.logout()
        }
        return tokenRefreshDecorator
    }()
    
    private lazy var remoteProfileService: ProfileService = {
       return RemoteProfileService(client: httpClient, environmentStorage: environmentStorage)
    }()
    
    private lazy var loginService: LoginUserService = {
       return RemoteLoginUserService(client: httpClient, environmentStorage: environmentStorage)
    }()
    
    private lazy var registerService: RegisterUserService = {
        return RemoteRegisterUserService(client: httpClient, environmentStorage: environmentStorage)
    }()
    
    private lazy var remoteObservationService: ObservationService = {
       return RemoteObservationService(client: httpClient, environmentStorage: environmentStorage)
    }()
    
    private lazy var taxonServiceManager: TaxonServiceManager = {
        TaxonServiceManager(taxonService: remoteTaxonService,
                            taxonPaginationInfo: taxonPaginationInfoStorage)
    }()
    
    private lazy var remoteTaxonService: TaxonService = {
        return RemoteTaxonService(client: httpClient, environmentStorage: environmentStorage)
    }()
    
    private lazy var remoteFindinPostService: PostFindingService = {
        return RemotePostFindingService(client: httpClient, environmentStorage: environmentStorage)
    }()
    
    private lazy var remoteUploadImageService: PostFindingImageService = {
        return RemotePostFindingImageService(client: httpClient, environmentStorage: environmentStorage)
    }()
    
    private lazy var uploadFindings: UploadFindings = {
       return UploadFindings(remotePostService: remoteFindinPostService,
                             uploadImageService: remoteUploadImageService,
                             dataLicenseStorage: dataLicenseStorage,
                             imageLicenseStorage: imageLicenseStorage,
                             settingsStorage: userDefaultsSettingsStorage)
    }()
    
    // MARK: - Routers
    
    private lazy var authorizationRouter: AuthorizationRouter = {
        let registerService = RemoteRegisterUserService(client: httpClient, environmentStorage: environmentStorage)
        
        let authorization =  AuthorizationRouter(factory: authorizationFactory,
                                                 commonViewControllerFactory: commonViewControllerFactoryImplementation,
                                                 swiftUIAlertViewControllerFactory: swiftUIAlertViewControllerFactory,
                                                 navigationController: mainNavigationController,
                                                 environmentStorage: environmentStorage,
                                                 tokenStorage: tokenStorage,
                                                 taxonSavingUseCase: taxonSavingUseCase)
        authorization.onLoginSuccess = { _ in
            self.showSideMenuRouter()
        }
        return authorization
    }()
    
    private lazy var sideMenuRouter: SideMenuRouterRouter = {
        let sideMenuRouter = SideMenuRouterRouter(navigationController: sideMenuNavigationController,
                                                  environmentStorage: environmentStorage,
                                                  userStorage: userStorage,
                                                  factory: SwiftUISideMenuViewControllerFactory(),
                                                  commonViewControllerFactory: commonViewControllerFactoryImplementation)
        
        sideMenuRouter.onLogout = { _ in
            self.logout()
        }
        
        sideMenuRouter.onSetupScreen = { [weak self] _ in
            self?.setupRouter.start()
        }
        
        sideMenuRouter.onListOfFindingsScreen = { [weak self] _ in
            self?.findingsRouter.start()
        }
        return sideMenuRouter
    }()
    
    private lazy var findingsRouter: FindingsRouter = {
        let taxonRouter = FindingsRouter(navigationController: sideMenuNavigationController,
                                      location: locationManager,
                                      taxonServiceManager: taxonServiceManager,
                                      taxonPaginationInfoStorage: taxonPaginationInfoStorage,
                                      settingsStorage: userDefaultsSettingsStorage,
                                      uploadFindings: uploadFindings,
                                      factory: SwiftUIFindingsViewControllerFactory(getAltitudeService: RemoteGetAltitudeService(client: httpClient, environmentStorage: environmentStorage)),
                                      commonFactory: commonViewControllerFactoryImplementation,
                                      alertFactory: swiftUIAlertViewControllerFactory,
                                      userStorage: userStorage)
        return taxonRouter
    }()
    
    private lazy var setupRouter: SetupRouter = {
       let setupRouter = SetupRouter(navigationController: sideMenuNavigationController,
                                     factory: SwiftUISetupViewControllerFactory(settingsStorage: userDefaultsSettingsStorage),
                                     swiftUICommonFactory: commonViewControllerFactoryImplementation,
                                     alertFactory: swiftUIAlertViewControllerFactory,
                                     taxonPaginationStorage: taxonPaginationInfoStorage,
                                     imageLicenseStorage: imageLicenseStorage,
                                     dataLicenseStorage: dataLicenseStorage,
                                     settingsStorage: userDefaultsSettingsStorage)
        setupRouter.onStartDownloadTaxon = { [weak self] _ in
            guard let self = self else { return }
            self.downloadTaxonRouter.start(navigationController: self.sideMenuNavigationController)
        }
        
        setupRouter.onSideMenuTapped = { [weak self] _ in
            self?.sideMenuRouter.start()
        }
        
        return setupRouter
    }()
    
    private lazy var downloadTaxonRouter: DownloadTaxonRouter = {
        return DownloadTaxonRouter(alertFactory: swiftUIAlertViewControllerFactory,
                                   swiftUICommonFactory: commonViewControllerFactoryImplementation,
                                   taxonUseCase: taxonSavingUseCase,
                                   envvironmentStorage: environmentStorage)
    }()
    
    // MARK: - Storage
    
    private lazy var environmentStorage: EnvironmentStorage = {
        return KeychainEnvironmentStorage()
    }()
    
    private lazy var dataLicenseStorage: LicenseStorage = {
        return UserDefaultsDataLicenseStorage()
    }()
    
    private lazy var imageLicenseStorage: LicenseStorage = {
        return UserDefaultsImageLicenseStorage()
    }()
    
    private lazy var tokenStorage: TokenStorage = {
        return KeychainTokenStorage()
    }()
    
    private lazy var userStorage: UserStorage = {
        return UserDefaultsUserStorage()
    }()
    
    private lazy var taxonPaginationInfoStorage: TaxonsPaginationInfoStorage = {
        return UserDefaultsTaxonsPaginationInfoStorage()
    }()
    
    private lazy var userDefaultsSettingsStorage: SettingsStorage = {
        let settingsStorage = UserDefaultsSettingsStorage()
        
        guard let settings = settingsStorage.getSettings() else {
            settingsStorage.saveSettings(settings: Settings())
            return settingsStorage
        }
        return settingsStorage
    }()
    
    // MARK: - Factories
    
    private lazy var authorizationFactory: AuthorizationViewControllerFactory = {
        return SwiftUILoginViewControllerFactory(loginService: loginService,
                                                 registerService: registerService,
                                                 dataLicenseStorage: dataLicenseStorage,
                                                 imageLicenseStorage: imageLicenseStorage,
                                                 emailValidator: emailValidator,
                                                 passwordValidator: passwordValidator)
    }()
    
    private lazy var commonViewControllerFactoryImplementation: CommonViewControllerFactory = {
        return CommonViewControllerFactroryImplementation()
    }()
    
    private lazy var swiftUIAlertViewControllerFactory: AlertViewControllerFactory = {
        return SwiftUIAlertViewControllerFactory()
    }()
    
    // MARK: - Location
    
    private lazy var locationManager: LocationManager = {
       return LocationManager()
    }()
    
    // MARK: - Utils
    
    private lazy var emailValidator: StringValidator = {
       return EmailValidator()
    }()
    
    private lazy var passwordValidator: StringValidator = {
       return PasswordValidator()
    }()
    
    // MARK: - Taxons Savings
    private lazy var taxonLoader: TaxonLoader = {
       return CSVTaxonLoader(environmentStorage: environmentStorage)
    }()
    
    private lazy var taxonDBManager: TaxonDBManager = {
       return TaxonRealmDBManager()
    }()
    
    private lazy var taxonSavingUseCase: TaxonsSavingUseCase = {
       return CSVTaxonsUseCase(taxonLoader: taxonLoader,
                               taxonDBManager: taxonDBManager,
                               taxonsService: remoteTaxonService,
                               settingsStorage: userDefaultsSettingsStorage)
    }()
    
    // MARK: - Init
    
    init(mainNavigationController: BiologerNavigationViewController) {
        self.mainNavigationController = mainNavigationController
    }
    
    lazy var onLoading: Observer<Bool> = { [weak self] isLoading in
        guard let self = self else { return }
        if isLoading {
            let loader  = self.commonViewControllerFactoryImplementation.createBlockingProgress()
            self.sideMenuNavigationController.present(loader, animated: false, completion: nil)
        } else {
            self.sideMenuNavigationController.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Public functions
    public func start() {
        launchApp()
    }
    
    // MARK: - Private Functions
    private func showSideMenuRouter() {
        findingsRouter.start()
        findingsRouter.onSideMenuTapped = { [weak self] _ in
            self?.sideMenuRouter.start()
        }
        UINavigationBar.appearance().barTintColor = .biologerGreenColor
        self.sideMenuNavigationController.modalPresentationStyle = .overFullScreen
        self.mainNavigationController.present(self.sideMenuNavigationController,
                                              animated: true,
                                              completion: {
                                                self.getMyProfile()
                                              })
    }
    
    private func logout() {
        self.tokenStorage.delete()
        self.userStorage.delete()
        RealmManager.delete(fromEntity: DBFinding.self)
        self.mainNavigationController.dismiss(animated: true, completion: {
            if let vc = self.mainNavigationController.viewControllers.filter({ $0 is UIHostingController<LoginScreen<LoginScreenViewModel>> }).first {
                self.mainNavigationController.popToViewController(vc, animated: false)
            } else {
                self.authorizationRouter.start(shouldPresentIntroScreens: false)
            }
        })
    }
    
    private func launchApp() {
        if let _ = tokenStorage.getToken() {
            let vc = authorizationFactory.makeSplashScreen(onSplashScreenDone: { [weak self] in
                self?.showSideMenuRouter()
            })
            self.mainNavigationController.setViewControllers([vc], animated: false)
        } else {
            let vc = authorizationFactory.makeSplashScreen(onSplashScreenDone: { [weak self] in
                guard let self = self else {
                    print("Self is nil")
                    return
                }
                print("Self is not nil")
                let tutorialPresented = UserDefaults.standard.bool(forKey: UserDefaultsConstants.shouldPresentTutorialKey)
                self.authorizationRouter.start(shouldPresentIntroScreens: !tutorialPresented)
            })
            mainNavigationController.setViewControllers([vc], animated: false)
        }
    }
    
    private func getMyProfile() {
        onLoading((true))
        remoteProfileService.getMyProfile { result in
            switch result {
            case .failure(let error):
                self.onLoading((false))
                print("My profile error: \(error.description)")
                if !error.isInternetConnectionAvailable {
                    print("You don't have a internte connection. Read last data from REALM")
                }
            case .success(let response):
                let user = User(id: response.data.id,
                                firstName: response.data.first_name,
                                lastName: response.data.last_name,
                                email: response.data.email,
                                fullName: response.data.full_name,
                                isVerified: response.data.is_verified,
                                settings: User.Settings(dataLicense: response.data.settings.data_license,
                                                        imageLicense: response.data.settings.image_license,
                                                        language: response.data.settings.language))
                self.userStorage.save(user: user)
                self.getObservation()
            }
        }
    }
    
    private func getObservation() {
        remoteObservationService.getObservation(completion: { [weak self] result in
            guard let self = self else { return }
            self.onLoading((false))
            switch result {
            case .failure(let error):
                print("Observation error: \(error.description)")
            case .success(let response):
                response.data.forEach( {
                    RealmManager.add(DBObservetationMapper.mapForDB(observationResponse: $0))
                })
                self.downloadTaxonRouter.start(navigationController: self.sideMenuNavigationController,
                                               sholdPresentConfirmationWhenAllTaxonAleadyDownloaded: false)
            }
        })
    }
}
