/// Connects app-scoped infrastructure, feature compositions and top-level flows.
final class AppRootComposition {
    private let infrastructure = SharedInfrastructureComposition()

    // MARK: - Shared Features

    lazy var taxonSyncComposition: TaxonSyncComposition = {
        TaxonSyncComposition(
            authenticatedAPIClient: infrastructure.authenticatedAPIClient,
            environmentProvider: infrastructure.currentEnvironmentProvider,
            pageSize: APIConstants.taxonsPerPage
        )
    }()

    private lazy var sessionComposition: SessionComposition = {
        SessionComposition(
            dependencies: SessionComposition.Dependencies(
                authenticatedAPIClient: infrastructure.authenticatedAPIClient,
                environmentProvider: infrastructure.currentEnvironmentProvider,
                tokenStorage: infrastructure.tokenStorage,
                userStorage: infrastructure.userStorage,
                sessionStore: infrastructure.sessionStore,
                taxonSyncStateProvider: taxonSyncComposition.service,
                taxonScopeProvider: taxonSyncComposition.scopeProvider
            )
        )
    }()

    // MARK: - Feature Compositions

    private lazy var authorizationComposition: AuthorizationComposition = {
        AuthorizationComposition(
            dependencies: AuthorizationComposition.Dependencies(
                apiClient: infrastructure.apiClient,
                environmentProvider: infrastructure.currentEnvironmentProvider,
                tokenStorage: infrastructure.tokenStorage,
                environmentSelectionStorage: infrastructure.environmentSelectionStorage,
                licensePreferenceStorage: infrastructure.licensePreferenceStorage,
                environmentOptionsProvider: infrastructure.environmentOptionsProvider,
                licenseOptionsProvider: infrastructure.licenseOptionsProvider,
                urlProvider: infrastructure.authorizationURLProvider
            )
        )
    }()

    private lazy var findingsComposition: FindingsComposition = {
        FindingsComposition(
            dependencies: FindingsComposition.Dependencies(
                authenticatedAPIClient: infrastructure.authenticatedAPIClient,
                environmentProvider: infrastructure.currentEnvironmentProvider,
                licenseStorage: infrastructure.licensePreferenceStorage,
                licenseOptionsProvider: infrastructure.licenseOptionsProvider,
                settingsStorage: infrastructure.settingsStorage,
                userStorage: infrastructure.userStorage
            )
        )
    }()

    private lazy var findingEditorComposition: FindingEditorComposition = {
        FindingEditorComposition(
            dependencies: FindingEditorComposition.Dependencies(
                authenticatedAPIClient: infrastructure.authenticatedAPIClient,
                environmentProvider: infrastructure.currentEnvironmentProvider,
                taxonSyncComposition: taxonSyncComposition
            )
        )
    }()

    private lazy var settingsComposition: SettingsComposition = {
        SettingsComposition(
            dependencies: SettingsComposition.Dependencies(
                settingsStorage: infrastructure.settingsStorage,
                licenseOptionsProvider: infrastructure.licenseOptionsProvider,
                licensePreferenceStorage: infrastructure.licensePreferenceStorage,
                userStorage: infrastructure.userStorage,
                environmentProvider: infrastructure.currentEnvironmentProvider,
                accountUseCase: sessionComposition.accountUseCase,
                logoutUseCase: sessionComposition.logoutUseCase,
                taxonSyncComposition: taxonSyncComposition
            )
        )
    }()

    // MARK: - App Root

    @MainActor
    lazy var appSessionCoordinator: AppSessionCoordinator = {
        sessionComposition.coordinator
    }()

    lazy var unauthenticatedFlowBuilder: UnauthenticatedFlowBuilder = {
        authorizationComposition.flowBuilder
    }()

    @MainActor
    lazy var mainTabFlowBuilder: MainTabFlowBuilder = {
        MainTabFlowBuilder(
            findingsFlowBuilder: findingsComposition.flowBuilder,
            findingEditorFlowBuilder: findingEditorComposition.flowBuilder,
            settingsFlowBuilder: settingsComposition.flowBuilder,
            findingsFlowController: findingsComposition.flowController
        )
    }()
}
