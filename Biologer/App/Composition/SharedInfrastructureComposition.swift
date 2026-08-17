import Foundation

/// Owns the app-scoped infrastructure shared by multiple feature compositions.
/// Only composition code should access these dependencies directly.
final class SharedInfrastructureComposition {
    // MARK: - Session

    lazy var sessionStore: SessionStore = {
        DefaultSessionStore(tokenStorage: tokenStorage)
    }()

    // MARK: - Storage And Providers

    lazy var tokenStorage: TokenStorage = KeychainTokenStorage()

    private lazy var environmentConfigurationProvider:
        EnvironmentConfigurationProviding = {
        DefaultEnvironmentConfigurationProvider()
    }()

    lazy var environmentOptionsProvider: EnvironmentOptionsProviding = {
        DefaultEnvironmentOptionsProvider(
            configurationProvider: environmentConfigurationProvider
        )
    }()

    lazy var environmentSelectionStorage: EnvironmentSelectionStorage = {
        KeychainEnvironmentSelectionStorage(
            configurationProvider: environmentConfigurationProvider,
            dataStore: KeychainEnvironmentSecureDataStore(),
            keys: .production
        )
    }()

    lazy var currentEnvironmentProvider: CurrentEnvironmentProviding = {
        DefaultCurrentEnvironmentProvider(
            selectionStorage: environmentSelectionStorage,
            configurationProvider: environmentConfigurationProvider
        )
    }()

    lazy var authorizationURLProvider: AuthorizationURLProviding = {
        DefaultAuthorizationURLProvider(
            configurationProvider: environmentConfigurationProvider
        )
    }()

    lazy var userStorage: UserStorage = UserDefaultsUserStorage()

    lazy var licenseOptionsProvider: LicenseOptionsProviding = {
        DefaultLicenseOptionsProvider()
    }()

    lazy var licensePreferenceStorage: LicensePreferenceStorage = {
        UserDefaultsLicensePreferenceStorage(
            optionsProvider: licenseOptionsProvider
        )
    }()

    lazy var settingsStorage: SettingsStorage = {
        let storage = UserDefaultsSettingsStorage()
        if storage.getSettings() == nil {
            storage.saveSettings(settings: Settings())
        }
        return storage
    }()

    // MARK: - Networking

    lazy var apiClient: APIClientProtocol = {
        APIClient(session: URLSession(configuration: .default))
    }()

    lazy var authenticatedAPIClient: APIClientProtocol = {
        let refresher = RemoteAccessTokenRefresher(
            client: apiClient,
            environmentProvider: currentEnvironmentProvider,
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
