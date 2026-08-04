//
//  AppNavigationRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import Foundation

import UIKit

@MainActor
public protocol NavigationRouter {
    func start()
}

@MainActor
public final class AppNavigationRouter: NavigationRouter {
    private let sideMenuNavigationController = BiologerNavigationViewController(shouldBeTransparent: false)
    private let mainNavigationController: BiologerNavigationViewController
    private let authorizationUIVersion: AuthorizationUIVersion
    private let mainUIVersion: MainUIVersion
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
        tokenRefreshDecorator.onLogout = { [weak self] in
            self?.performOnMain { [weak self] in
                self?.logout()
            }
        }
        return tokenRefreshDecorator
    }()

    private lazy var apiHttpClient: APIClientProtocol = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20
        sessionConfig.timeoutIntervalForResource = 20
        let session = URLSession(configuration: sessionConfig)
        let client = APIClient(session: session)
        return client
    }()

    // One composition graph is kept for the whole authenticated app session.
    // Settings, startup and Taxon Search will consume useCases from this object.
    private lazy var taxonSyncComposition: TaxonSyncComposition = {
        TaxonSyncBuilder(
            apiClient: apiHttpClient,
            environmentStorage: environmentStorage
        ).makeComposition()
    }()

    private lazy var remoteProfileService: ProfileService = {
       return RemoteProfileService(client: httpClient, environmentStorage: environmentStorage)
    }()

    private lazy var userAccountUseCase: UserAccountUseCase = {
        DefaultUserAccountUseCase(
            profileService: remoteProfileService,
            userStorage: userStorage
        )
    }()

    private lazy var logoutUseCase: LogoutUseCase = {
        DefaultLogoutUseCase(
            tokenStorage: tokenStorage,
            userStorage: userStorage,
            taxonPaginationInfoStorage: taxonPaginationInfoStorage,
            localDataDeleting: RealmLogoutLocalDataDeleter()
        )
    }()

    private lazy var setupUseCase: SetupUseCase = {
        DefaultSetupUseCase(
            settingsStorage: userDefaultsSettingsStorage,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage,
            taxonPaginationStorage: taxonPaginationInfoStorage,
            taxonLocalDataStore: RealmSetupTaxonLocalDataStore()
        )
    }()

    private lazy var remoteObservationService: ObservationService = {
       return RemoteObservationService(client: httpClient, environmentStorage: environmentStorage)
    }()

    private lazy var taxonServiceCoordinator: TaxonServiceCoordinator = {
        TaxonServiceCoordinator(taxonService: remoteTaxonService,
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

    private lazy var authorizationCoordinator: AuthorizationCoordinating = {
        let builder = AuthorizationCoordinatorBuilder(
            version: authorizationUIVersion,
            apiClient: apiHttpClient,
            httpClient: httpClient,
            navigationController: mainNavigationController,
            authorizationFactory: authorizationFactory,
            commonViewControllerFactory: commonViewControllerFactory,
            swiftUICommonViewControllerFactory: swiftUICommonViewControllerFactory,
            swiftUIAlertViewControllerFactory: swiftUIAlertViewControllerFactory,
            environmentStorage: environmentStorage,
            tutorialRepository: authorizationTutorialRepository,
            tokenStorage: tokenStorage,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage
        )
        let authorization = builder.makeCoordinator()
        authorization.onAuthorizationSuccess = { [weak self] _ in
            self?.performOnMain { [weak self] in
                self?.showMainCoordinator()
            }
        }
        return authorization
    }()

    private lazy var sideMenuRouter: SideMenuRouterRouter = {
        let sideMenuRouter = SideMenuRouterRouter(navigationController: sideMenuNavigationController,
                                                  mainNavigationController: mainNavigationController,
                                                  taxonRouter: taxonRouter,
                                                  setupUseCase: setupUseCase,
                                                  environmentStorage: environmentStorage,
                                                  userStorage: userStorage,
                                                  userAccountUseCase: userAccountUseCase,
                                                  factory: SwiftUIDashboardViewControllerFactory(),
                                                  swiftUIAlertViewControllerFactory: swiftUIAlertViewControllerFactory,
                                                  uiKitCommonViewControllerFactory: commonViewControllerFactory,
                                                  swiftUICommonViewControllerFactory: swiftUICommonViewControllerFactory)
        return sideMenuRouter
    }()

    private lazy var taxonRouter: TaxonRouter = {
        makeTaxonRouter(
            navigationController: sideMenuNavigationController,
            showsSideMenuButton: true
        )
    }()

    private lazy var mainCoordinator: MainCoordinating = {
        let builder = MainCoordinatorBuilder(
            version: mainUIVersion,
            makeLegacyCoordinator: { [unowned self] in
                LegacyMainCoordinator(
                    navigationController: self.sideMenuNavigationController,
                    router: self.sideMenuRouter
                )
            },
            makeTabCoordinator: { [unowned self] in
                let navigationController = BiologerNavigationViewController(
                    shouldBeTransparent: true
                )
                let mainTabBuilder = self.makeMainTabBuilder()
                return MainTabCoordinator(
                    navigationController: navigationController,
                    makeMainViewController: { onDownloadTaxa, onLogout, onDeleteAccount in
                        mainTabBuilder.makeViewController(
                            onDownloadTaxa: onDownloadTaxa,
                            onLogout: onLogout,
                            onDeleteAccount: onDeleteAccount
                        )
                    }
                )
            }
        )
        let coordinator = builder.makeCoordinator()
        coordinator.onLogout = { [weak self] _ in
            self?.performOnMain { [weak self] in
                self?.logout()
            }
        }
        coordinator.onStartDownloadTaxa = { [weak self] navigationController in
            self?.downloadTaxonRouter.start(navigationController: navigationController)
        }
        coordinator.onDeleteAccount = { [weak self] deleteObservations in
            self?.deleteCurrentAccount(deleteObservations: deleteObservations)
        }
        return coordinator
    }()

    private lazy var downloadTaxonRouter: DownloadTaxonRouter = {
        return DownloadTaxonRouter(alertFactory: swiftUIAlertViewControllerFactory,
                                   swiftUICommonFactory: swiftUICommonViewControllerFactory,
                                   taxonServiceCordinator: taxonServiceCoordinator,
                                   settingsStorage: userDefaultsSettingsStorage,
                                   taxonPaginationInfoStorage: taxonPaginationInfoStorage,
                                   environmentStorage: environmentStorage)
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

    private lazy var authorizationTutorialRepository: AuthorizationTutorialRepository = {
        UserDefaultsAuthorizationTutorialRepository()
    }()

    // MARK: - Factories

    private lazy var authorizationFactory: AuthorizationViewControllerFactory = {
        return SwiftUILoginViewControllerFactory()
    }()

    private lazy var swiftUICommonViewControllerFactory: CommonViewControllerFactory = {
        return SwiftUICommonViewControllerFactrory()
    }()

    private lazy var commonViewControllerFactory: CommonViewControllerFactory = {
        return IOSUIKitCommonViewControllerFactory()
    } ()

    private lazy var swiftUIAlertViewControllerFactory: AlertViewControllerFactory = {
        return SwiftUIAlertViewControllerFactory()
    }()

    // MARK: - Location

    private lazy var locationManager: LocationManager = {
       return LocationManager()
    }()

    // MARK: - Init

    init(
        mainNavigationController: BiologerNavigationViewController,
        authorizationUIVersion: AuthorizationUIVersion = .v1,
        mainUIVersion: MainUIVersion = .v1
    ) {
        self.mainNavigationController = mainNavigationController
        self.authorizationUIVersion = authorizationUIVersion
        self.mainUIVersion = mainUIVersion
        //self.mainNavigationController.setNavigationBarTransparency()
    }

    lazy var onLoading: Observer<Bool> = { [weak self] isLoading in
        self?.performOnMain { [weak self] in
            guard let self = self else { return }
            if isLoading {
                let loader = self.commonViewControllerFactory.createBlockingProgress()
                self.mainCoordinator.rootViewController.present(loader, animated: false, completion: nil)
            } else {
                self.mainCoordinator.rootViewController.dismiss(animated: false, completion: nil)
            }
        }
    }

    // MARK: - Public functions
    public func start() {
        launchApp()
    }

    // MARK: - Private Functions
    private func showMainCoordinator() {
        mainCoordinator.start()
        UINavigationBar.appearance().barTintColor = .biologerGreenColor
        let rootViewController = mainCoordinator.rootViewController
        rootViewController.modalPresentationStyle = .overFullScreen
        mainNavigationController.present(
            rootViewController,
            animated: true,
            completion: { [weak self] in
                self?.getMyProfile()
            }
        )
    }

    private func logout() {
        logoutUseCase.logout()

        self.mainNavigationController.dismiss(animated: true, completion: {
            self.authorizationCoordinator.restart()
        })
    }

    private func launchApp() {
        if let _ = tokenStorage.getToken() {
            let vc = authorizationFactory.makeSplashScreen(onSplashScreenDone: { [weak self] in
                self?.showMainCoordinator()
            })
            self.mainNavigationController.setViewControllers([vc], animated: false)
        } else {
            let vc = authorizationFactory.makeSplashScreen(onSplashScreenDone: { [weak self] in
                guard let self = self else { return }
                self.authorizationCoordinator.start(
                    shouldPresentIntroScreens: !self.authorizationTutorialRepository.wasPresented
                )
            })
            mainNavigationController.setViewControllers([vc], animated: false)
        }
    }

    private func getMyProfile() {
        onLoading((true))
        Task { [weak self] in
            guard let self = self else { return }
            do {
                _ = try await self.userAccountUseCase.loadCurrentUser()
                await MainActor.run {
                    self.getObservation()
                }
            } catch let error as APIError {
                await MainActor.run {
                    self.onLoading((false))
                    print("My profile error: \(error.description)")
                    if !error.isInternetConnectionAvailable {
                        print("You don't have a internte connection. Read last data from REALM")
                    }
                }
            } catch {
                await MainActor.run {
                    self.onLoading((false))
                    print("My profile error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func getObservation() {
        remoteObservationService.getObservationTypes(completion: { [weak self] result in
            guard let self = self else { return }
            self.onLoading((false))
            switch result {
            case .failure(let error):
                print("Observation error: \(error.description)")
            case .success(let response):
                response.data.forEach( {
                    RealmManager.add(DBObservetationMapper.mapForDB(observationResponse: $0))
                })
                self.downloadTaxonRouter.start(navigationController: self.mainCoordinator.primaryNavigationController,
                                               sholdPresentConfirmationWhenAllTaxonAleadyDownloaded: false)
            }
        })
    }

    private func makeTaxonRouter(
        navigationController: UINavigationController,
        showsSideMenuButton: Bool
    ) -> TaxonRouter {
        TaxonRouter(
            navigationController: navigationController,
            location: locationManager,
            taxonServiceCordinator: taxonServiceCoordinator,
            taxonPaginationInfoStorage: taxonPaginationInfoStorage,
            settingsStorage: userDefaultsSettingsStorage,
            uploadFindings: uploadFindings,
            factory: SwiftUITaxonViewControllerFactory(
                getAltitudeService: RemoteGetAltitudeService(
                    client: httpClient,
                    environmentStorage: environmentStorage
                )
            ),
            swiftUICommonFactory: swiftUICommonViewControllerFactory,
            uiKitCommonFactory: IOSUIKitCommonViewControllerFactory(),
            alertFactory: swiftUIAlertViewControllerFactory,
            userStorage: userStorage,
            showsSideMenuButton: showsSideMenuButton
        )
    }

    private func makeSettingsBuilder() -> SettingsBuilder {
        SettingsBuilder(
            settingsStorage: userDefaultsSettingsStorage,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage,
            taxonPaginationStorage: taxonPaginationInfoStorage,
            environmentStorage: environmentStorage,
            userStorage: userStorage
        )
    }

    private func makeFindingsBuilder() -> FindingsBuilder {
        FindingsBuilder(
            remotePostService: remoteFindinPostService,
            uploadImageService: remoteUploadImageService,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage,
            settingsStorage: userDefaultsSettingsStorage,
            userStorage: userStorage
        )
    }

    private func makeFindingEditorBuilder() -> FindingEditorBuilder {
        FindingEditorBuilder(
            altitudeService: RemoteGetAltitudeService(
                client: httpClient,
                environmentStorage: environmentStorage
            )
        )
    }

    private func makeMainTabBuilder() -> MainTabBuilder {
        MainTabBuilder(
            findingsBuilder: makeFindingsBuilder(),
            findingEditorBuilder: makeFindingEditorBuilder(),
            settingsBuilder: makeSettingsBuilder(),
            findingsFlowController: FindingsFlowController()
        )
    }

    private func deleteCurrentAccount(deleteObservations: Bool) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await userAccountUseCase.deleteCurrentUser(
                    deleteObservations: deleteObservations
                )
                await MainActor.run {
                    self.showMainAlert(
                        popUpType: .success,
                        title: "DeleteAccount.lb.successTitle".localized,
                        description: "",
                        onDismiss: { [weak self] in
                            guard let self else { return }
                            self.userStorage.deleteAllForUser()
                            self.logout()
                        }
                    )
                }
            } catch let error as APIError {
                await MainActor.run {
                    self.showMainAlert(
                        popUpType: .error,
                        title: error.title,
                        description: error.description
                    )
                }
            } catch {
                await MainActor.run {
                    self.showMainAlert(
                        popUpType: .error,
                        title: "API.lb.error".localized,
                        description: error.localizedDescription
                    )
                }
            }
        }
    }

    private func showMainAlert(
        popUpType: PopUpType,
        title: String,
        description: String,
        onDismiss: (() -> Void)? = nil
    ) {
        let viewController = swiftUIAlertViewControllerFactory.makeConfirmationAlert(
            popUpType: popUpType,
            title: title,
            description: description,
            onTapp: { [weak self] _ in
                self?.mainCoordinator.rootViewController.dismiss(
                    animated: true,
                    completion: onDismiss
                )
            }
        )
        mainCoordinator.rootViewController.present(viewController, animated: true)
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
