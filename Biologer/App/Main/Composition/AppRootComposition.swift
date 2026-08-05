import Foundation

@MainActor
final class AppRootComposition {
    lazy var rootViewModel: AppRootViewModel = {
        AppRootViewModel(
            sessionStore: sessionStore,
            prepareSessionUseCase: prepareSessionUseCase,
            getTaxonSyncStateUseCase: taxonSyncComposition.useCases.getState,
            taxonScopeProvider: taxonSyncComposition.scopeProvider,
            logoutUseCase: logoutUseCase
        )
    }()

    lazy var sessionStore: SessionStore = {
        DefaultSessionStore(tokenStorage: tokenStorage)
    }()

    lazy var authorizationUseCases: AuthorizationUseCases = {
        AuthorizationUseCases(
            login: DefaultLoginUserUseCase(
                repository: RemoteLoginUserRepository(
                    client: apiClient,
                    environmentStorage: environmentStorage,
                    tokenStorage: tokenStorage
                )
            ),
            registration: DefaultRegistrationUseCase(
                validator: DefaultRegistrationInputValidator(),
                licensePreferenceUseCase: DefaultRegistrationLicensePreferenceUseCase(
                    repository: StoredRegistrationLicensePreferenceRepository(
                        dataLicenseStorage: dataLicenseStorage,
                        imageLicenseStorage: imageLicenseStorage
                    )
                ),
                registerUseCase: DefaultRegisterUserUseCase(
                    repository: RemoteRegisterUserRepository(
                        client: apiClient,
                        environmentStorage: environmentStorage,
                        tokenStorage: tokenStorage
                    )
                )
            ),
            selectEnvironmentUseCase: DefaultSelectAuthorizationEnvironmentUseCase(
                repository: StoredAuthorizationEnvironmentRepository(storage: environmentStorage)
            )
        )
    }()

    lazy var taxonSyncComposition: TaxonSyncComposition = {
        TaxonSyncBuilder(
            apiClient: authenticatedAPIClient,
            environmentStorage: environmentStorage
        ).makeComposition()
    }()

    lazy var findingsBuilder: FindingsBuilder = {
        FindingsBuilder(
            remoteRepository: RemoteFindingUploadRepository(
                client: authenticatedAPIClient,
                environmentStorage: environmentStorage
            ),
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage,
            settingsStorage: settingsStorage,
            userStorage: userStorage
        )
    }()

    lazy var findingEditorBuilder: FindingEditorBuilder = {
        FindingEditorBuilder(
            altitudeRepository: RemoteFindingAltitudeRepository(
                client: authenticatedAPIClient,
                environmentStorage: environmentStorage
            ),
            taxonSyncComposition: taxonSyncComposition
        )
    }()

    lazy var settingsBuilder: SettingsBuilder = {
        SettingsBuilder(
            settingsStorage: settingsStorage,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage,
            taxonPaginationStorage: taxonPaginationStorage,
            environmentStorage: environmentStorage,
            userStorage: userStorage,
            taxonSyncComposition: taxonSyncComposition,
            accountUseCase: accountUseCase,
            logoutUseCase: logoutUseCase
        )
    }()

    lazy var findingsFlowController: FindingsFlowController = {
        FindingsFlowController()
    }()

    lazy var accountUseCase: UserAccountUseCase = {
        DefaultUserAccountUseCase(
            accountRepository: RemoteAccountRepository(
                client: authenticatedAPIClient,
                environmentStorage: environmentStorage
            ),
            userStorage: userStorage
        )
    }()

    lazy var observationRepository: ObservationRepository = {
        RemoteObservationRepository(
            client: authenticatedAPIClient,
            environmentStorage: environmentStorage
        )
    }()

    lazy var prepareSessionUseCase: PrepareSessionUseCase = {
        DefaultPrepareSessionUseCase(
            accountUseCase: accountUseCase,
            observationRepository: observationRepository,
            userStorage: userStorage
        )
    }()

    lazy var logoutUseCase: LogoutUseCase = {
        DefaultLogoutUseCase(
            tokenStorage: tokenStorage,
            userStorage: userStorage,
            taxonPaginationInfoStorage: taxonPaginationStorage,
            localDataDeleting: RealmLogoutLocalDataDeleter(),
            sessionStore: sessionStore
        )
    }()

    lazy var tutorialRepository: AuthorizationTutorialRepository = {
        UserDefaultsAuthorizationTutorialRepository()
    }()

    private lazy var tokenStorage: TokenStorage = KeychainTokenStorage()
    private lazy var environmentStorage: EnvironmentStorage = KeychainEnvironmentStorage()
    private lazy var userStorage: UserStorage = UserDefaultsUserStorage()
    private lazy var dataLicenseStorage: LicenseStorage = UserDefaultsDataLicenseStorage()
    private lazy var imageLicenseStorage: LicenseStorage = UserDefaultsImageLicenseStorage()
    private lazy var settingsStorage: SettingsStorage = {
        let storage = UserDefaultsSettingsStorage()
        if storage.getSettings() == nil {
            storage.saveSettings(settings: Settings())
        }
        return storage
    }()
    private lazy var taxonPaginationStorage: TaxonsPaginationInfoStorage = {
        UserDefaultsTaxonsPaginationInfoStorage()
    }()

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
}
