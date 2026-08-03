import SwiftUI

enum SettingsDestination: Hashable {
    case projectName
    case license(SettingsLicenseKind)
    case automaticDownload
    case help
    case about
    case account
}

struct SettingsFlow: View {
    private let useCases: SettingsUseCases
    private let accountContextProvider: () -> SettingsAccountContext
    private let appVersion: String
    private let onOpenURL: Observer<String>
    private let onDownloadTaxa: Observer<Void>
    private let onLogout: Observer<Void>
    private let onDeleteAccount: Observer<Bool>

    @StateObject private var settingsViewModel: SettingsScreenV2ViewModel
    @State private var path: [SettingsDestination] = []

    init(
        useCases: SettingsUseCases,
        accountContextProvider: @escaping () -> SettingsAccountContext,
        appVersion: String,
        onOpenURL: @escaping Observer<String>,
        onDownloadTaxa: @escaping Observer<Void>,
        onLogout: @escaping Observer<Void>,
        onDeleteAccount: @escaping Observer<Bool>
    ) {
        self.useCases = useCases
        self.accountContextProvider = accountContextProvider
        self.appVersion = appVersion
        self.onOpenURL = onOpenURL
        self.onDownloadTaxa = onDownloadTaxa
        self.onLogout = onLogout
        self.onDeleteAccount = onDeleteAccount
        _settingsViewModel = StateObject(
            wrappedValue: SettingsScreenV2ViewModel(
                preferencesUseCase: useCases.preferences,
                taxonDataUseCase: useCases.taxonData
            )
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            SettingsScreenV2(
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
        case .help:
            BiologerHelpScreen(onDone: { _ in goBack() })
                .navigationTitle("SideMenu.lb.Help".localized)
                .navigationBarTitleDisplayMode(.inline)
        case .about:
            let context = accountContextProvider()
            SettingsAboutScreen(
                environment: context.environment,
                version: appVersion,
                onOpenURL: onOpenURL,
                onBack: { _ in goBack() }
            )
        case .account:
            SettingsAccountScreen(
                viewModel: SettingsAccountViewModel(
                    context: accountContextProvider(),
                    onLogout: onLogout,
                    onDeleteAccount: onDeleteAccount
                )
            )
        }
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
