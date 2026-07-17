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
    @Published public var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol
    @Published public var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol

    private let useCase: LoginUserUseCase
    private let onSelectEnvironmentTapped: Observer<Void>
    private let onLoginSuccess: Observer<Void>
    private let onLoginError: Observer<APIError>
    private let onRegisterTapped: Observer<Void>
    private let onForgotPasswordTapped: Observer<Void>

    init(
        environmentViewModel: EnvironmentViewModel,
        useCase: LoginUserUseCase,
        onSelectEnvironmentTapped: @escaping Observer<Void>,
        onLoginSuccess: @escaping Observer<Void>,
        onRegisterTapped: @escaping Observer<Void>,
        onForgotPasswordTapped: @escaping Observer<Void>,
        onLoginError: @escaping Observer<APIError>,
    ) {
        self.environmentViewModel = environmentViewModel
        self.userNameTextFieldViewModel = UserNameTextFieldViewModel()
        self.passwordTextFieldViewModel = PasswordTextFieldViewModel()
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

    public func login() async {
        isLoading = true
        do throws(LoginError) {
            try await useCase.login(
                email: userNameTextFieldViewModel.text,
                username: userNameTextFieldViewModel.text,
                password: passwordTextFieldViewModel.text
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
            case .apiError(let error):
                onLoginError(error)
            }
        }
    }
}

extension LoginScreenV2ViewModel {
    private func setEmailRequired() {
        objectWillChange.send()
        userNameTextFieldViewModel.setInvalid(with: "Common.tf.error.required".localized)
    }

    private func setEmailIsNotValidFormat() {
        objectWillChange.send()
        userNameTextFieldViewModel.setInvalid(with: "Common.tf.email.error.notValid".localized)
    }

    private func setPasswordIsNotValid() {
        objectWillChange.send()
        passwordTextFieldViewModel.setInvalid(with: "Common.tf.error.required".localized)
    }

    private func setEmailIsValid() {
        objectWillChange.send()
        userNameTextFieldViewModel.setValid()
    }

    private func setPasswordValid() {
        objectWillChange.send()
        passwordTextFieldViewModel.setValid()
    }
}

extension LoginScreenV2ViewModel {
    public func toggleIsCodeEntryPassword() {
        objectWillChange.send()
        passwordTextFieldViewModel.isCodeEntry.toggle()
    }
}
