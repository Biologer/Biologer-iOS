import SwiftUI

struct LoginFlow: View {
    private enum Screen: Hashable {
        case environments
    }

    @State private var path = NavigationPath()
    @StateObject private var viewModel: LoginFlowViewModel

    @SwiftUI.Environment(\.openURL) private var openURL

    private let onRegister: (EnvironmentID) -> Void
    private let onLoginSuccess: () async -> Void

    init(
        dependencies: LoginFlowDependencies,
        onRegister: @escaping (EnvironmentID) -> Void,
        onLoginSuccess: @escaping () async -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: LoginFlowViewModel(
                environmentOptionsProvider: dependencies.environmentOptionsProvider,
                loginUseCase: dependencies.loginUseCase,
                environmentSelectionUseCase: dependencies.environmentSelectionUseCase,
                urlProvider: dependencies.urlProvider
            )
        )
        self.onRegister = onRegister
        self.onLoginSuccess = onLoginSuccess
    }

    var body: some View {
        NavigationStack(path: $path) {
            loginScreen
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .environments:
                        environmentsScreen
                    }
                }
        }
        .sheet(item: $viewModel.result) { result in
            BiologerResultSheet(
                style: .failure,
                title: result.title,
                message: result.message,
                onConfirm: viewModel.dismissResult
            )
        }
    }

    private var loginScreen: some View {
        LoginScreen(
            viewModel: viewModel,
            onSelectEnvironment: { path.append(Screen.environments) },
            onLoginSuccess: onLoginSuccess,
            onLoginError: viewModel.present,
            onRegister: { onRegister(viewModel.selectedEnvironment.id) },
            onForgotPassword: { openExternalPage(.forgotPassword) }
        )
        .biologerNavigationBar()
    }

    private var environmentsScreen: some View {
        EnvironmentSelectionScreen(
            selectedEnvironment: viewModel.selectedEnvironment,
            environments: viewModel.environments,
            onSelect: viewModel.selectEnvironment,
            close: goBack
        )
        .biologerNavigationBar(
            title: "Env.nav.title".localized,
            onBack: goBack
        )
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    private func openExternalPage(_ page: AuthorizationExternalPage) {
        guard let url = viewModel.externalURL(for: page) else { return }
        openURL(url)
    }
}
