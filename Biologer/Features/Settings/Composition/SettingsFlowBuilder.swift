import Foundation

@MainActor
final class SettingsFlowBuilder {
    private let useCases: SettingsUseCases
    private let accountContextProvider: () -> SettingsAccountContext
    private let appVersion: String
    private let accountUseCase: UserAccountUseCase
    private let logoutUseCase: LogoutUseCase
    private let taxonSyncComposition: TaxonSyncComposition

    init(
        useCases: SettingsUseCases,
        accountContextProvider: @escaping () -> SettingsAccountContext,
        appVersion: String,
        accountUseCase: UserAccountUseCase,
        logoutUseCase: LogoutUseCase,
        taxonSyncComposition: TaxonSyncComposition
    ) {
        self.useCases = useCases
        self.accountContextProvider = accountContextProvider
        self.appVersion = appVersion
        self.accountUseCase = accountUseCase
        self.logoutUseCase = logoutUseCase
        self.taxonSyncComposition = taxonSyncComposition
    }

    func makeFlow() -> SettingsFlow {
        let context = accountContextProvider()
        let flowViewModel = SettingsFlowViewModel(
            settingsViewModel: SettingsScreenViewModel(
                preferencesUseCase: useCases.preferences,
                taxonDataUseCase: useCases.taxonData
            ),
            projectNameViewModel: ProjectNameSettingsViewModel(
                useCase: useCases.preferences
            ),
            dataLicenseViewModel: LicenseSettingsViewModel(
                kind: .data,
                useCase: useCases.licenses
            ),
            imageLicenseViewModel: LicenseSettingsViewModel(
                kind: .image,
                useCase: useCases.licenses
            ),
            automaticDownloadViewModel: AutomaticDownloadSettingsViewModel(
                useCase: useCases.preferences
            ),
            taxonSyncViewModel: taxonSyncComposition.makeViewModel(),
            aboutViewModel: SettingsAboutViewModel(
                environment: context.environment,
                version: appVersion
            ),
            accountViewModel: SettingsAccountViewModel(
                context: context,
                accountUseCase: accountUseCase,
                logoutUseCase: logoutUseCase
            )
        )

        return SettingsFlow(viewModel: flowViewModel)
    }
}
