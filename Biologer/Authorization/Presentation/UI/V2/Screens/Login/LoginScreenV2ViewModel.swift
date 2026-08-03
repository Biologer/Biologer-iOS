//
//  LoginScreenV2ViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

@MainActor
public final class LoginScreenV2ViewModel: ObservableObject {

    @Published public var isLoading: Bool = false
    @Published public var environmentViewModel: EnvironmentViewModel
    @Published public private(set) var email: String = ""
    @Published public private(set) var password: String = ""
    @Published public private(set) var emailError: String?
    @Published public private(set) var passwordError: String?

    private let useCase: LoginUserUseCase
    private let onSelectEnvironmentTapped: Observer<Void>
    private let onLoginSuccess: Observer<Void>
    private let onLoginError: Observer<AuthorizationFailure>
    private let onRegisterTapped: Observer<Void>
    private let onForgotPasswordTapped: Observer<Void>

    init(
        environmentViewModel: EnvironmentViewModel,
        useCase: LoginUserUseCase,
        onSelectEnvironmentTapped: @escaping Observer<Void>,
        onLoginSuccess: @escaping Observer<Void>,
        onRegisterTapped: @escaping Observer<Void>,
        onForgotPasswordTapped: @escaping Observer<Void>,
        onLoginError: @escaping Observer<AuthorizationFailure>,
    ) {
        self.environmentViewModel = environmentViewModel
        self.onSelectEnvironmentTapped = onSelectEnvironmentTapped
        self.useCase = useCase
        self.onLoginSuccess = onLoginSuccess
        self.onLoginError = onLoginError
        self.onRegisterTapped = onRegisterTapped
        self.onForgotPasswordTapped = onForgotPasswordTapped
    }

    public func selectEnvironment() {
        onSelectEnvironmentTapped(())
    }

    public func register() {
        onRegisterTapped(())
    }

    public func forgotPassword() {
        onForgotPasswordTapped(())
    }

    public func updateEnvironment(_ environmentViewModel: EnvironmentViewModel) {
        self.environmentViewModel = environmentViewModel
    }

    public func updateEmail(_ email: String) {
        self.email = email
        emailError = nil
    }

    public func updatePassword(_ password: String) {
        self.password = password
        passwordError = nil
    }

    public func login() async {
        isLoading = true
        do throws(LoginError) {
            try await useCase.login(
                email: email,
                username: email,
                password: password
            )
            setEmailIsValid()
            setPasswordValid()
            isLoading = false
            onLoginSuccess(())
        } catch let error {
            isLoading = false
            switch error {
            case .invalidUsername:
                setEmailRequired()
            case .invalidEmail:
                setEmailIsNotValidFormat()
            case .invalidPassword:
                setPasswordIsNotValid()
            case .authorizationFailed(let error):
                onLoginError(error)
            }
        }
    }
}

extension LoginScreenV2ViewModel {
    private func setEmailRequired() {
        emailError = "Common.tf.error.required".localized
    }

    private func setEmailIsNotValidFormat() {
        emailError = "Common.tf.email.error.notValid".localized
    }

    private func setPasswordIsNotValid() {
        passwordError = "Common.tf.error.required".localized
    }

    private func setEmailIsValid() {
        emailError = nil
    }

    private func setPasswordValid() {
        passwordError = nil
    }
}
