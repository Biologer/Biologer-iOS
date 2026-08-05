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

    @State
    private var selectedEnvironment: EnvironmentViewModel = EnvironmentViewModelFactory().createEnvironment(type: .serbia)

    @State
    private var path: NavigationPath = .init()

    @StateObject
    private var viewModel: AuthorizationFlowViewModel
    @State private var errorAlert: AuthorizationAlert?
    @SwiftUI.Environment(\.openURL) private var openURL

    private let authorizationUseCases: AuthorizationUseCases
    private let onAuthorizationSuccess: Observer<Void>

    init(
        authorizationUseCases: AuthorizationUseCases,
        shouldPresentHelp: Bool,
        onHelpCompleted: @escaping Observer<Void>,
        onAuthorizationSuccess: @escaping Observer<Void>
    ) {
        self.authorizationUseCases = authorizationUseCases
        _viewModel = StateObject(
            wrappedValue: AuthorizationFlowViewModel(
                shouldPresentHelp: shouldPresentHelp,
                onHelpCompleted: onHelpCompleted
            )
        )
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
        .alert(item: $errorAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("Common.btn.ok".localized))
            )
        }
    }

    @ViewBuilder
    private var initialScreen: some View {
        if viewModel.isHelpPresented {
            BiologerHelpScreen { _ in
                viewModel.completeHelp()
            }
            .navigationBarBackButtonHidden(true)
        } else {
            loginScreen
        }
    }

    private var loginScreen: some View {
        LoginScreen(
            environmentViewModel: selectedEnvironment,
            viewModel: LoginScreenViewModel(
                environmentViewModel: selectedEnvironment,
                useCase: authorizationUseCases.login,
                onSelectEnvironmentTapped: {
                    path.append(Screen.environments)
                },
                onLoginSuccess: {
                    onAuthorizationSuccess(())
                },
                onRegisterTapped: {
                    path.append(Screen.registration)
                },
                onForgotPasswordTapped: {
                    openExternalPage(path: "/password/reset")
                },
                onLoginError: { error in
                    errorAlert = AuthorizationAlert(
                        title: error.summary.isEmpty ? "API.lb.error".localized : error.summary,
                        message: error.message
                    )
                }
            ))
            .authorizationNavigationBar()
            .onAppear {
                authorizationUseCases.selectEnvironment(selectedEnvironment.env)
            }
    }

    private var environmentsScreen: some View {
        EnvironmentSelectionScreen(
            selectedEnvironment: $selectedEnvironment,
            environments: EnvironmentViewModelFactory().createAllEnvironments(),
            close: {
                goBack()
            }
        )
        .authorizationNavigationBar(
            title: "Env.nav.title".localized,
            onBack: {
                goBack()
            }
        )
        .onChange(of: selectedEnvironment) { environment in
            authorizationUseCases.selectEnvironment(environment.env)
        }
    }

    // MARK: - Register Steps Screens
    private var registrationFlow: some View {
        RegistrationFlow(
            path: $path,
            registrationUseCase: authorizationUseCases.registration,
            environmentImage: selectedEnvironment.image,
            onPrivacyPolicy: { _ in
                openExternalPage(path: "/pages/privacy-policy")
            },
            registrationSuccess: {
                onAuthorizationSuccess(())
            })
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    private func openExternalPage(path: String) {
        guard let url = URL(
            string: "https://\(selectedEnvironment.env.host)\(selectedEnvironment.env.path)\(path)"
        ) else {
            errorAlert = AuthorizationAlert(
                title: "API.lb.error".localized,
                message: "API.lb.parsingError".localized
            )
            return
        }
        openURL(url)
    }
}

private struct AuthorizationAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
