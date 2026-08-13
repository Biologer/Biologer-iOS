//
//  AuthorizationFlow.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct AuthorizationFlow: View {

    enum Screen: String {
        case environments
        case registration
    }

    @State private var path: NavigationPath = .init()
    @State private var isHelpPresented: Bool
    @StateObject private var viewModel: AuthorizationFlowViewModel

    @SwiftUI.Environment(\.openURL) private var openURL

    private let onHelpCompleted: () -> Void
    private let onAuthorizationSuccess: () async -> Void

    init(
        viewModel: AuthorizationFlowViewModel,
        shouldPresentHelp: Bool,
        onHelpCompleted: @escaping () -> Void,
        onAuthorizationSuccess: @escaping () async -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _isHelpPresented = State(initialValue: shouldPresentHelp)
        self.onHelpCompleted = onHelpCompleted
        self.onAuthorizationSuccess = onAuthorizationSuccess
    }

    var body: some View {
        NavigationStack(path: $path) {
            initialScreen
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .environments:
                        environmentsScreen
                    case .registration:
                        registrationFlow
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

    @ViewBuilder
    private var initialScreen: some View {
        if isHelpPresented {
            BiologerHelpScreen {
                guard isHelpPresented else { return }
                isHelpPresented = false
                onHelpCompleted()
            }
            .navigationBarBackButtonHidden(true)
        } else {
            loginScreen
        }
    }

    private var loginScreen: some View {
        LoginScreen(
            viewModel: viewModel.loginViewModel,
            onSelectEnvironment: { path.append(Screen.environments) },
            onLoginSuccess: onAuthorizationSuccess,
            onLoginError: viewModel.present,
            onRegister: { path.append(Screen.registration) },
            onForgotPassword: { openExternalPage(.forgotPassword) }
        )
            .biologerNavigationBar()
            .onAppear {
                viewModel.prepareLogin()
            }
    }

    private var environmentsScreen: some View {
        EnvironmentSelectionScreen(
            selectedEnvironment: Binding(
                get: { viewModel.selectedEnvironment },
                set: viewModel.selectEnvironment
            ),
            environments: viewModel.environments,
            close: {
                goBack()
            }
        )
        .biologerNavigationBar(
            title: "Env.nav.title".localized,
            onBack: {
                goBack()
            }
        )
    }

    // MARK: - Register Steps Screens
    private var registrationFlow: some View {
        RegistrationFlow(
            path: $path,
            viewModel: viewModel.registrationFlowViewModel,
            onPrivacyPolicy: {
                openExternalPage(.privacyPolicy)
            },
            registrationSuccess: onAuthorizationSuccess
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
