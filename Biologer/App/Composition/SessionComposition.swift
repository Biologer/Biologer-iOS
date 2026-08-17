/// Builds the app-scoped account and session graph.
final class SessionComposition {
    struct Dependencies {
        let authenticatedAPIClient: APIClientProtocol
        let environmentProvider: CurrentEnvironmentProviding
        let tokenStorage: TokenStorage
        let userStorage: UserStorage
        let sessionStore: SessionStore
        let taxonSyncStateProvider: TaxonSyncStateProviding
        let taxonScopeProvider: TaxonCatalogScopeProviding
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    private lazy var accountRepository: AccountRepository = {
        RemoteAccountRepository(
            client: dependencies.authenticatedAPIClient,
            environmentProvider: dependencies.environmentProvider
        )
    }()

    lazy var accountUseCase: UserAccountUseCase = {
        DefaultUserAccountUseCase(
            accountRepository: accountRepository,
            userStorage: dependencies.userStorage
        )
    }()

    private lazy var observationRepository: ObservationRepository = {
        RemoteObservationRepository(
            client: dependencies.authenticatedAPIClient,
            environmentProvider: dependencies.environmentProvider
        )
    }()

    private lazy var prepareSessionUseCase: PrepareSessionUseCase = {
        DefaultPrepareSessionUseCase(
            accountUseCase: accountUseCase,
            observationRepository: observationRepository,
            userStorage: dependencies.userStorage
        )
    }()

    lazy var logoutUseCase: LogoutUseCase = {
        DefaultLogoutUseCase(
            tokenStorage: dependencies.tokenStorage,
            userStorage: dependencies.userStorage,
            localDataDeleting: RealmLogoutLocalDataDeleter(),
            sessionStore: dependencies.sessionStore
        )
    }()

    @MainActor
    lazy var coordinator: AppSessionCoordinator = {
        AppSessionCoordinator(
            sessionStore: dependencies.sessionStore,
            prepareSessionUseCase: prepareSessionUseCase,
            taxonSyncStateProvider: dependencies.taxonSyncStateProvider,
            taxonScopeProvider: dependencies.taxonScopeProvider,
            logoutUseCase: logoutUseCase
        )
    }()
}
