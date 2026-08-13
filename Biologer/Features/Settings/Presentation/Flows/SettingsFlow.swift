import SwiftUI

struct SettingsFlow: View {
    @State private var path: [SettingsDestination] = []
    @StateObject private var viewModel: SettingsFlowViewModel

    init(viewModel: SettingsFlowViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $path) {
            SettingsScreen(
                viewModel: viewModel.settingsViewModel,
                onSelectDestination: { path.append($0) }
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
                viewModel: viewModel.taxonSyncViewModel
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
