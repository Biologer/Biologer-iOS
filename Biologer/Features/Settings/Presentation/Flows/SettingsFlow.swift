import SwiftUI

struct SettingsFlow: View {
    @State private var path: [SettingsDestination] = []
    @StateObject private var viewModel: SettingsFlowViewModel

    private let onDownloadTaxa: Observer<Void>

    init(
        viewModel: SettingsFlowViewModel,
        onDownloadTaxa: @escaping Observer<Void>
    ) {
        self.onDownloadTaxa = onDownloadTaxa
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $path) {
            SettingsScreen(
                viewModel: viewModel.settingsViewModel,
                onSelectDestination: { path.append($0) },
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
                viewModel: viewModel.projectNameViewModel,
                onSaved: { _ in
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
            TaxonSyncFlow(
                viewModel: viewModel.taxonSyncViewModel
            )
        case .help:
            BiologerHelpScreen(onDone: { _ in goBack() })
                .navigationTitle("Settings.support.help".localized)
                .navigationBarTitleDisplayMode(.inline)
        case .about:
            SettingsAboutScreen(
                viewModel: viewModel.aboutViewModel,
                onBack: { _ in goBack() }
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
