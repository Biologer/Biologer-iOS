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
        case registerFirstStep
    }
    
    @State
    private var selectedEnvironment: EnvironmentViewModel = EnvironmentViewModelFactory().createEnvironment(type: .serbia)
    
    @State
    private var path: NavigationPath = .init()
    
    private let authorizationUseCase: AuthUseCase
    
    init(authorizationUseCase: AuthUseCase) {
        self.authorizationUseCase = authorizationUseCase
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            initialScreen
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .environments:
                        environmentsScreen
                    case .registerFirstStep:
                        registerFirstStepScreen
                    }
                }
        }
    }
    
    private var initialScreen: some View {
        NewLoginScreen(
            viewModel: NewLoginScreenViewModel(
                environmentViewModel: selectedEnvironment,
                useCase: authorizationUseCase.loginUseCase,
                onSelectEnvironmentTapped: {
                    path.append(Screen.environments)
                },
                onLoginSuccess: {
                    
                },
                onRegisterTapped: {
                    path.append(Screen.registerFirstStep)
                },
                onForgotPasswordTapped: {
                    
                },
                onLoginError: { error in
                    
                }
            ))
    }
    
    private var environmentsScreen: some View {
        NewEnvironmentsScreen(
            selectedEnvironment: $selectedEnvironment,
            environments: EnvironmentViewModelFactory().createAllEnvironments(),
            close: {
                path.removeLast()
            }
        )
    }
    
    // MARK: - Register Steps Screens
    private var registerFirstStepScreen: some View {
        Text("Register screen")
    }
}
