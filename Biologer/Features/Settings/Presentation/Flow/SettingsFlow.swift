import SwiftUI

enum SettingsDestination: Hashable {
    case projectName
    case license(SettingsLicenseKind)
    case automaticDownload
    case taxonSync
    case help
    case about
    case account
}

struct SettingsFlow: View {
    private let useCases: SettingsUseCases
    private let accountContextProvider: () -> SettingsAccountContext
    private let appVersion: String
    private let onDownloadTaxa: Observer<Void>
    private let accountUseCase: UserAccountUseCase
    private let logoutUseCase: LogoutUseCase
    private let taxonSyncComposition: TaxonSyncComposition

    @StateObject private var settingsViewModel: SettingsScreenViewModel
    @State private var path: [SettingsDestination] = []

    init(
        useCases: SettingsUseCases,
        accountContextProvider: @escaping () -> SettingsAccountContext,
        appVersion: String,
        onDownloadTaxa: @escaping Observer<Void>,
        accountUseCase: UserAccountUseCase,
        logoutUseCase: LogoutUseCase,
        taxonSyncComposition: TaxonSyncComposition
    ) {
        self.useCases = useCases
        self.accountContextProvider = accountContextProvider
        self.appVersion = appVersion
        self.onDownloadTaxa = onDownloadTaxa
        self.accountUseCase = accountUseCase
        self.logoutUseCase = logoutUseCase
        self.taxonSyncComposition = taxonSyncComposition
        _settingsViewModel = StateObject(
            wrappedValue: SettingsScreenViewModel(
                preferencesUseCase: useCases.preferences,
                taxonDataUseCase: useCases.taxonData
            )
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            SettingsScreen(
                viewModel: settingsViewModel,
                onSelectDestination: { destination in
                    path.append(destination)
                },
                onDownloadTaxa: onDownloadTaxa
            )
            .navigationDestination(for: SettingsDestination.self) { destination in
                destinationView(destination)
            }
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: SettingsDestination) -> some View {
        switch destination {
        case .projectName:
            ProjectNameSettingsScreen(
                viewModel: ProjectNameSettingsViewModel(useCase: useCases.preferences),
                onSaved: { _ in
                    settingsViewModel.reload()
                    goBack()
                }
            )
        case .license(let kind):
            LicenseSettingsScreen(
                viewModel: LicenseSettingsViewModel(
                    kind: kind,
                    useCase: useCases.licenses
                )
            )
        case .automaticDownload:
            AutomaticDownloadSettingsScreen(
                viewModel: AutomaticDownloadSettingsViewModel(
                    useCase: useCases.preferences
                )
            )
        case .taxonSync:
            TaxonSyncFlow(
                useCases: taxonSyncComposition.useCases,
                scopeProvider: taxonSyncComposition.scopeProvider
            )
        case .help:
            BiologerHelpScreen(onDone: { _ in goBack() })
                .navigationTitle("SideMenu.lb.Help".localized)
                .navigationBarTitleDisplayMode(.inline)
        case .about:
            let context = accountContextProvider()
            SettingsAboutScreen(
                environment: context.environment,
                version: appVersion,
                onBack: { _ in goBack() }
            )
        case .account:
            SettingsAccountScreen(
                viewModel: SettingsAccountViewModel(
                    context: accountContextProvider(),
                    accountUseCase: accountUseCase,
                    logoutUseCase: logoutUseCase
                )
            )
        }
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
