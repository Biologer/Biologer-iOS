import Foundation

/// Builds the Settings feature and its screen-level ViewModels.
final class SettingsComposition {
    struct Dependencies {
        let settingsStorage: SettingsStorage
        let licenseOptionsProvider: LicenseOptionsProviding
        let licensePreferenceStorage: LicensePreferenceStorage
        let userStorage: UserStorage
        let environmentProvider: CurrentEnvironmentProviding
        let accountUseCase: UserAccountUseCase
        let logoutUseCase: LogoutUseCase
        let taxonSyncComposition: TaxonSyncComposition
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    private lazy var preferencesRepository: SettingsPreferencesRepository = {
        StoredSettingsPreferencesRepository(
            storage: dependencies.settingsStorage
        )
    }()

    private lazy var licenseRepository: SettingsLicenseRepository = {
        StoredSettingsLicenseRepository(
            optionsProvider: dependencies.licenseOptionsProvider,
            storage: dependencies.licensePreferenceStorage
        )
    }()

    private lazy var downloadedTaxaRepository: DownloadedTaxaRepository = {
        RealmDownloadedTaxaRepository()
    }()

    private lazy var useCases: SettingsUseCases = {
        SettingsUseCases(
            preferences: DefaultSettingsPreferencesUseCase(
                repository: preferencesRepository
            ),
            licenses: DefaultSettingsLicenseUseCase(
                repository: licenseRepository
            ),
            taxonData: DefaultSettingsTaxonDataUseCase(
                repository: downloadedTaxaRepository
            )
        )
    }()

    lazy var flowBuilder: SettingsFlowBuilder = {
        SettingsFlowBuilder(
            useCases: useCases,
            accountContextProvider: { [weak self] in
                self?.accountContext() ?? SettingsAccountContext(
                    email: "",
                    username: "",
                    environment: ""
                )
            },
            appVersion: currentAppVersion(),
            accountUseCase: dependencies.accountUseCase,
            logoutUseCase: dependencies.logoutUseCase,
            taxonSyncComposition: dependencies.taxonSyncComposition
        )
    }()

    private func accountContext() -> SettingsAccountContext {
        SettingsAccountContext(
            email: dependencies.userStorage.getUser()?.email ?? "",
            username: dependencies.userStorage.getUser()?.fullName ?? "",
            environment: currentEnvironment()
        )
    }

    private func currentEnvironment() -> String {
        guard let environment = dependencies.environmentProvider.currentEnvironment() else {
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
