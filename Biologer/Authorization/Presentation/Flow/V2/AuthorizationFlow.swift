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

    private let authorizationUseCases: AuthorizationUseCases
    private let onAuthorizationSuccess: Observer<Void>
    private let onForgotPassword: Observer<Void>
    private let onPrivacyPolicy: Observer<Void>
    private let onLoginError: Observer<AuthorizationFailure>

    init(
        authorizationUseCases: AuthorizationUseCases,
        shouldPresentHelp: Bool,
        onHelpCompleted: @escaping Observer<Void>,
        onAuthorizationSuccess: @escaping Observer<Void>,
        onForgotPassword: @escaping Observer<Void>,
        onPrivacyPolicy: @escaping Observer<Void>,
        onLoginError: @escaping Observer<AuthorizationFailure>
    ) {
        self.authorizationUseCases = authorizationUseCases
        _viewModel = StateObject(
            wrappedValue: AuthorizationFlowViewModel(
                shouldPresentHelp: shouldPresentHelp,
                onHelpCompleted: onHelpCompleted
            )
        )
        self.onAuthorizationSuccess = onAuthorizationSuccess
        self.onForgotPassword = onForgotPassword
        self.onPrivacyPolicy = onPrivacyPolicy
        self.onLoginError = onLoginError
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
    }

    @ViewBuilder
    private var initialScreen: some View {
        if viewModel.isHelpPresented {
            AuthorizationHelpScreen { _ in
                viewModel.completeHelp()
            }
        } else {
            loginScreen
        }
    }

    private var loginScreen: some View {
        LoginScreenV2(
            environmentViewModel: selectedEnvironment,
            viewModel: LoginScreenV2ViewModel(
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
                    onForgotPassword(())
                },
                onLoginError: { error in
                    onLoginError(error)
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
            onPrivacyPolicy: onPrivacyPolicy,
            registrationSuccess: {
                onAuthorizationSuccess(())
            })
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

private struct AuthorizationHelpScreen: View {
    @StateObject private var viewModel: HelpScreenViewModel

    init(onDone: @escaping Observer<Void>) {
        _viewModel = StateObject(
            wrappedValue: HelpScreenViewModel(onDone: onDone)
        )
    }

    var body: some View {
        HelpScreen(loader: viewModel)
    }
}
