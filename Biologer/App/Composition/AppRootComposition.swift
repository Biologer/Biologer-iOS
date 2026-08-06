import Foundation

@MainActor
final class AppRootComposition {
    // MARK: - App Root

    lazy var rootViewModel: AppRootViewModel = {
        AppRootViewModel(
            sessionStore: sessionStore,
            prepareSessionUseCase: prepareSessionUseCase,
            getTaxonSyncStateUseCase: taxonSyncUseCases.getState,
            taxonScopeProvider: taxonScopeProvider,
            logoutUseCase: logoutUseCase
        )
    }()

    lazy var sessionStore: SessionStore = {
        DefaultSessionStore(tokenStorage: tokenStorage)
    }()

    // MARK: - Authorization

    private lazy var loginRepository: LoginUserRepository = {
        RemoteLoginUserRepository(
            client: apiClient,
            environmentStorage: environmentStorage,
            tokenStorage: tokenStorage
        )
    }()

    private lazy var registerUserRepository: RegisterUserRepository = {
        RemoteRegisterUserRepository(
            client: apiClient,
            environmentStorage: environmentStorage,
            tokenStorage: tokenStorage
        )
    }()

    private lazy var registrationLicenseRepository:
        RegistrationLicensePreferenceRepository = {
        StoredRegistrationLicensePreferenceRepository(
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage
        )
    }()

    private lazy var authorizationEnvironmentRepository:
        AuthorizationEnvironmentRepository = {
        StoredAuthorizationEnvironmentRepository(storage: environmentStorage)
    }()

    private lazy var tutorialRepository: AuthorizationTutorialRepository = {
        UserDefaultsAuthorizationTutorialRepository()
    }()

    private lazy var authorizationUseCases: AuthorizationUseCases = {
        AuthorizationUseCases(
            login: DefaultLoginUserUseCase(repository: loginRepository),
            registration: DefaultRegistrationUseCase(
                validator: DefaultRegistrationInputValidator(),
                licensePreferenceUseCase: DefaultRegistrationLicensePreferenceUseCase(
                    repository: registrationLicenseRepository
                ),
                registerUseCase: DefaultRegisterUserUseCase(
                    repository: registerUserRepository
                )
            ),
            selectEnvironmentUseCase: DefaultSelectAuthorizationEnvironmentUseCase(
                repository: authorizationEnvironmentRepository
            ),
            tutorial: DefaultAuthorizationTutorialUseCase(
                repository: tutorialRepository
            )
        )
    }()

    lazy var authorizationFlowBuilder: AuthorizationFlowBuilder = {
        AuthorizationFlowBuilder(
            useCases: authorizationUseCases
        )
    }()

    // MARK: - Taxon Sync

    private lazy var taxonCatalogRepository: TaxonCatalogRepository = {
        RealmTaxonCatalogRepository(configuration: RealmManager.realmConfig())
    }()

    private lazy var initialTaxonCatalogRepository: InitialTaxonCatalogRepository = {
        CSVInitialTaxonCatalogRepository(bundle: .main)
    }()

    private lazy var taxonUpdatesRepository: TaxonUpdatesRepository = {
        APITaxonUpdatesRepository(client: authenticatedAPIClient)
    }()

    private lazy var taxonSyncMetadataRepository: TaxonSyncMetadataRepository = {
        UserDefaultsTaxonSyncMetadataRepository()
    }()

    private lazy var taxonSyncController: TaxonSyncController = {
        TaxonSyncController(
            catalogRepository: taxonCatalogRepository,
            initialCatalogRepository: initialTaxonCatalogRepository,
            updatesRepository: taxonUpdatesRepository,
            metadataRepository: taxonSyncMetadataRepository,
            pageSize: APIConstants.taxonsPerPage
        )
    }()

    private lazy var taxonSyncUseCases: TaxonSyncUseCases = {
        TaxonSyncUseCases(
            getState: DefaultGetTaxonSyncStateUseCase(controller: taxonSyncController),
            observeState: DefaultObserveTaxonSyncStateUseCase(controller: taxonSyncController),
            checkForUpdates: DefaultCheckTaxonUpdatesUseCase(controller: taxonSyncController),
            start: DefaultStartTaxonSyncUseCase(controller: taxonSyncController),
            pause: DefaultPauseTaxonSyncUseCase(controller: taxonSyncController),
            resume: DefaultResumeTaxonSyncUseCase(controller: taxonSyncController)
        )
    }()

    private lazy var taxonScopeProvider: TaxonCatalogScopeProviding = {
        EnvironmentTaxonCatalogScopeProvider(environmentStorage: environmentStorage)
    }()

    lazy var taxonSyncComposition: TaxonSyncComposition = {
        TaxonSyncComposition(
            useCases: taxonSyncUseCases,
            scopeProvider: taxonScopeProvider
        )
    }()

    lazy var taxonSyncFlowBuilder: TaxonSyncFlowBuilder = {
        TaxonSyncFlowBuilder(composition: taxonSyncComposition)
    }()

    // MARK: - Findings

    private lazy var findingsRepository = {
        RealmFindingsRepository(configuration: RealmManager.realmConfig())
    }()

    private lazy var remoteFindingUploadRepository: FindingRemoteUploadRepository = {
        RemoteFindingUploadRepository(
            client: authenticatedAPIClient,
            environmentStorage: environmentStorage
        )
    }()

    private lazy var findingUploadRepository: FindingUploadRepository = {
        RealmFindingUploadRepository(
            configuration: RealmManager.realmConfig(),
            remoteRepository: remoteFindingUploadRepository,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage,
            settingsStorage: settingsStorage
        )
    }()

    private lazy var findingSubmissionAccessRepository:
        FindingSubmissionAccessRepository = {
        StoredFindingSubmissionAccessRepository(userStorage: userStorage)
    }()

    private lazy var findingsUseCases: FindingsUseCases = {
        let uploadFindings = DefaultUploadFindingsUseCase(
            repository: findingUploadRepository
        )
        let checkSubmissionAccess = DefaultCheckFindingSubmissionAccessUseCase(
            repository: findingSubmissionAccessRepository
        )
        return FindingsUseCases(
            list: ListOfFindingsUseCases(
                getFindings: DefaultGetFindingsUseCase(repository: findingsRepository),
                deleteFinding: DefaultDeleteFindingUseCase(repository: findingsRepository),
                deleteFindings: DefaultDeleteFindingsUseCase(repository: findingsRepository),
                deleteAllFindings: DefaultDeleteAllFindingsUseCase(repository: findingsRepository),
                uploadFindings: uploadFindings,
                checkSubmissionAccess: checkSubmissionAccess
            ),
            details: FindingDetailsUseCases(
                getFindingDetails: DefaultGetFindingDetailsUseCase(
                    repository: findingsRepository
                ),
                uploadFindings: uploadFindings,
                checkSubmissionAccess: checkSubmissionAccess
            )
        )
    }()

    lazy var findingsFlowBuilder: FindingsFlowBuilder = {
        FindingsFlowBuilder(useCases: findingsUseCases)
    }()

    lazy var findingsFlowController: FindingsFlowController = {
        FindingsFlowController()
    }()

    // MARK: - Finding Editor

    private lazy var findingEditorRepository: FindingEditorRepository = {
        RealmFindingEditorRepository(configuration: RealmManager.realmConfig())
    }()

    private lazy var findingTaxonSearchRepository: FindingTaxonSearchRepository = {
        RealmFindingTaxonSearchRepository(configuration: RealmManager.realmConfig())
    }()

    private lazy var findingCurrentLocationRepository:
        FindingCurrentLocationRepository = {
        CoreLocationFindingCurrentLocationRepository()
    }()

    private lazy var findingAltitudeRepository: FindingAltitudeRepository = {
        RemoteFindingAltitudeRepository(
            client: authenticatedAPIClient,
            environmentStorage: environmentStorage
        )
    }()

    private lazy var findingEditorUseCases: FindingEditorUseCases = {
        FindingEditorUseCases(
            loadFinding: DefaultLoadFindingEditorUseCase(
                repository: findingEditorRepository
            ),
            saveFinding: DefaultSaveFindingEditorUseCase(
                repository: findingEditorRepository
            ),
            searchTaxa: DefaultSearchFindingTaxaUseCase(
                repository: findingTaxonSearchRepository
            ),
            location: FindingLocationUseCases(
                observeCurrentLocation: DefaultObserveCurrentFindingLocationUseCase(
                    repository: findingCurrentLocationRepository
                ),
                resolveLocation: DefaultResolveFindingLocationUseCase(
                    altitudeRepository: findingAltitudeRepository
                )
            )
        )
    }()

    lazy var findingEditorFlowBuilder: FindingEditorFlowBuilder = {
        FindingEditorFlowBuilder(
            useCases: findingEditorUseCases,
            taxonSyncComposition: taxonSyncComposition
        )
    }()

    // MARK: - Settings

    private lazy var settingsPreferencesRepository: SettingsPreferencesRepository = {
        StoredSettingsPreferencesRepository(storage: settingsStorage)
    }()

    private lazy var settingsLicenseRepository: SettingsLicenseRepository = {
        StoredSettingsLicenseRepository(
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage
        )
    }()

    private lazy var downloadedTaxaRepository: DownloadedTaxaRepository = {
        RealmDownloadedTaxaRepository()
    }()

    private lazy var settingsUseCases: SettingsUseCases = {
        SettingsUseCases(
            preferences: DefaultSettingsPreferencesUseCase(
                repository: settingsPreferencesRepository
            ),
            licenses: DefaultSettingsLicenseUseCase(
                repository: settingsLicenseRepository
            ),
            taxonData: DefaultSettingsTaxonDataUseCase(
                repository: downloadedTaxaRepository
            )
        )
    }()

    lazy var settingsFlowBuilder: SettingsFlowBuilder = {
        SettingsFlowBuilder(
            useCases: settingsUseCases,
            accountContextProvider: { [weak self] in
                SettingsAccountContext(
                    email: self?.userStorage.getUser()?.email ?? "",
                    username: self?.userStorage.getUser()?.fullName ?? "",
                    environment: self?.currentEnvironment() ?? ""
                )
            },
            appVersion: currentAppVersion(),
            accountUseCase: accountUseCase,
            logoutUseCase: logoutUseCase,
            taxonSyncComposition: taxonSyncComposition
        )
    }()

    // MARK: - Main Tab

    lazy var mainTabFlowBuilder: MainTabFlowBuilder = {
        MainTabFlowBuilder(
            findingsFlowBuilder: findingsFlowBuilder,
            findingEditorFlowBuilder: findingEditorFlowBuilder,
            settingsFlowBuilder: settingsFlowBuilder,
            findingsFlowController: findingsFlowController
        )
    }()

    // MARK: - Account And Session

    private lazy var accountRepository: AccountRepository = {
        RemoteAccountRepository(
            client: authenticatedAPIClient,
            environmentStorage: environmentStorage
        )
    }()

    lazy var accountUseCase: UserAccountUseCase = {
        DefaultUserAccountUseCase(
            accountRepository: accountRepository,
            userStorage: userStorage
        )
    }()

    private lazy var observationRepository: ObservationRepository = {
        RemoteObservationRepository(
            client: authenticatedAPIClient,
            environmentStorage: environmentStorage
        )
    }()

    private lazy var prepareSessionUseCase: PrepareSessionUseCase = {
        DefaultPrepareSessionUseCase(
            accountUseCase: accountUseCase,
            observationRepository: observationRepository,
            userStorage: userStorage
        )
    }()

    private lazy var logoutUseCase: LogoutUseCase = {
        DefaultLogoutUseCase(
            tokenStorage: tokenStorage,
            userStorage: userStorage,
            localDataDeleting: RealmLogoutLocalDataDeleter(),
            sessionStore: sessionStore
        )
    }()

    // MARK: - Storage

    private lazy var tokenStorage: TokenStorage = KeychainTokenStorage()
    private lazy var environmentStorage: EnvironmentStorage = KeychainEnvironmentStorage()
    private lazy var userStorage: UserStorage = UserDefaultsUserStorage()
    private lazy var dataLicenseStorage: LicenseStorage = {
        UserDefaultsLicenseStorage(key: "dataLicense.key")
    }()
    private lazy var imageLicenseStorage: LicenseStorage = {
        UserDefaultsLicenseStorage(key: "imageLicense.key")
    }()
    private lazy var settingsStorage: SettingsStorage = {
        let storage = UserDefaultsSettingsStorage()
        if storage.getSettings() == nil {
            storage.saveSettings(settings: Settings())
        }
        return storage
    }()

    // MARK: - Networking

    private lazy var apiClient: APIClientProtocol = {
        APIClient(session: URLSession(configuration: .default))
    }()

    private lazy var authenticatedAPIClient: APIClientProtocol = {
        let refresher = RemoteAccessTokenRefresher(
            client: apiClient,
            environmentStorage: environmentStorage,
            tokenStorage: tokenStorage
        )
        return AuthenticatedAPIClientDecorator(
            decoratee: apiClient,
            tokenStorage: tokenStorage,
            tokenRefresher: TokenRefreshCoordinator(refresher: refresher),
            sessionStore: sessionStore
        )
    }()

    // MARK: - Helpers

    private func currentEnvironment() -> String {
        guard let environment = environmentStorage.getEnvironment() else {
            return ""
        }
        return "https://\(environment.host)"
    }

    private func currentAppVersion() -> String {
        guard
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else {
            return ""
        }
        return "\("AboutBiologer.lb.appVersion".localized) \(version) (\(build))"
    }
}
