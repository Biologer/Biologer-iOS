import SwiftUI

struct SettingsFlow: View {
    @State private var path: [SettingsDestination] = []
    @StateObject private var viewModel: SettingsFlowViewModel

    /// The flow owns one Taxon Sync ViewModel so observation and progress remain
    /// alive after the detailed Taxon Sync screen is closed.
    @StateObject private var taxonSyncViewModel: TaxonSyncViewModel

    init(
        viewModel: SettingsFlowViewModel,
        taxonSyncViewModel: TaxonSyncViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _taxonSyncViewModel = StateObject(wrappedValue: taxonSyncViewModel)
    }

    var body: some View {
        NavigationStack(path: $path) {
            SettingsScreen(
                viewModel: viewModel.settingsViewModel,
                taxonSyncViewState: taxonSyncViewModel.viewState,
                onSelectDestination: { path.append($0) }
            )
            .navigationDestination(for: SettingsDestination.self) { destination in
                destinationView(destination)
            }
        }
        .task {
            await taxonSyncViewModel.observeState()
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: SettingsDestination) -> some View {
        switch destination {
        case .projectName:
            ProjectNameSettingsScreen(
                viewModel: viewModel.projectNameViewModel,
                onSaved: {
                    viewModel.settingsViewModel.reload()
                    goBack()
                }
            )
        case .license(let kind):
            LicenseSettingsScreen(
                viewModel: viewModel.licenseViewModel(for: kind)
            )
        case .automaticDownload:
            AutomaticDownloadSettingsScreen(
                viewModel: viewModel.automaticDownloadViewModel
            )
        case .taxonSync:
            TaxonSyncScreen(
                viewModel: taxonSyncViewModel
            )
        case .help:
            BiologerHelpScreen(onDone: goBack)
                .biologerScreen(title: "Settings.support.help".localized)
        case .about:
            SettingsAboutScreen(
                viewModel: viewModel.aboutViewModel,
                onBack: goBack
            )
        case .account:
            SettingsAccountScreen(
                viewModel: viewModel.accountViewModel
            )
        }
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
