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

    private let authorizationUseCase: AuthUseCase
    private let onAuthorizationSuccess: Observer<Void>
    private let onForgotPassword: Observer<Void>
    private let onLoginError: Observer<APIError>

    init(
        authorizationUseCase: AuthUseCase,
        onAuthorizationSuccess: @escaping Observer<Void>,
        onForgotPassword: @escaping Observer<Void>,
        onLoginError: @escaping Observer<APIError>
    ) {
        self.authorizationUseCase = authorizationUseCase
        self.onAuthorizationSuccess = onAuthorizationSuccess
        self.onForgotPassword = onForgotPassword
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
        .onAppear {
            authorizationUseCase.selectEnvironment(selectedEnvironment.env)
        }
    }

    private var initialScreen: some View {
        LoginScreenV2(
            viewModel: LoginScreenV2ViewModel(
                environmentViewModel: selectedEnvironment,
                useCase: authorizationUseCase.loginUseCase,
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
    }

    private var environmentsScreen: some View {
        EnvironmentSelectionScreen(
            selectedEnvironment: $selectedEnvironment,
            environments: EnvironmentViewModelFactory().createAllEnvironments(),
            close: {
                path.removeLast()
            }
        )
        .onChange(of: selectedEnvironment) { environment in
            authorizationUseCase.selectEnvironment(environment.env)
        }
    }

    // MARK: - Register Steps Screens
    private var registrationFlow: some View {
        RegistrationFlow(
            path: $path,
            useCase: authorizationUseCase.registerUseCase,
            environmentImage: selectedEnvironment.image,
            registrationSuccess: {
                onAuthorizationSuccess(())
            })
    }
}
