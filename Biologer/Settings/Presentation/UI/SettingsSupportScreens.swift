import SwiftUI

struct SettingsHelpScreen: View {
    @StateObject private var viewModel: HelpScreenViewModel
    let onBack: Observer<Void>

    init(onBack: @escaping Observer<Void>) {
        self.onBack = onBack
        _viewModel = StateObject(
            wrappedValue: HelpScreenViewModel(onDone: onBack)
        )
    }

    var body: some View {
        HelpScreen(loader: viewModel)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
    }

    private var backButton: some View {
        Button(action: { onBack(()) }) {
            Image(systemName: "chevron.left")
        }
    }
}

struct SettingsAboutScreen: View {
    @StateObject private var viewModel: AboutBiologerScreenViewModel
    let onBack: Observer<Void>

    init(
        environment: String,
        version: String,
        onOpenURL: @escaping Observer<String>,
        onBack: @escaping Observer<Void>
    ) {
        self.onBack = onBack
        _viewModel = StateObject(
            wrappedValue: AboutBiologerScreenViewModel(
                currentEnv: environment,
                version: version,
                onEnvTapped: onOpenURL
            )
        )
    }

    var body: some View {
        AboutBiologerScreen(loader: viewModel)
            .navigationTitle("SideMenu.lb.aboutUs".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { onBack(()) }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
    }
}
