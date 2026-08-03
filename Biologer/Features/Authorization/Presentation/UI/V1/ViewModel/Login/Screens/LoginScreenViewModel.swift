//
//  LoginScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import Foundation
import Combine

public final class LoginScreenViewModel: LoginScreenLoader {
    public let logoImage: String
    @Published public var environmentViewModel: EnvironmentViewModel
    @Published public var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol
    @Published public var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol
    
    private let useCase: LoginUserUseCase
    private let onSelectEnvironmentTapped: Observer<EnvironmentViewModel>
    private let onLoginSuccess: Observer<Void>
    private let onLoginError: Observer<AuthorizationFailure>
    private let onRegisterTapped: Observer<Void>
    private let onForgotPasswordTapped: Observer<Void>
    private let onLoading: Observer<Bool>
    
    init(logoImage: String,
         environmentViewModel: EnvironmentViewModel,
         useCase: LoginUserUseCase,
         onSelectEnvironmentTapped: @escaping Observer<EnvironmentViewModel>,
         onLoginSuccess: @escaping Observer<Void>,
         onLoginError: @escaping Observer<AuthorizationFailure>,
         onRegisterTapped: @escaping Observer<Void>,
         onForgotPasswordTapped: @escaping Observer<Void>,
         onLoading: @escaping Observer<Bool>
         ) {
        self.logoImage = logoImage
        self.environmentViewModel = environmentViewModel
        self.userNameTextFieldViewModel = UserNameTextFieldViewModel()
        self.passwordTextFieldViewModel = PasswordTextFieldViewModel()
        self.onSelectEnvironmentTapped = onSelectEnvironmentTapped
        self.useCase = useCase
        self.onLoginSuccess = onLoginSuccess
        self.onLoginError = onLoginError
        self.onRegisterTapped = onRegisterTapped
        self.onForgotPasswordTapped = onForgotPasswordTapped
        self.onLoading = onLoading
    }
    
    public func selectEnvironment() {
        onSelectEnvironmentTapped((environmentViewModel))
    }
    
    public func register() {
        onRegisterTapped(())
    }
    
    public func forgotPassword() {
        onForgotPasswordTapped(())
    }
    
    public func login() async {
        await MainActor.run {
            onLoading((true))
        }
        let username = await MainActor.run {
            userNameTextFieldViewModel.text
        }
        let password = await MainActor.run {
            passwordTextFieldViewModel.text
        }
        do throws(LoginError) {
            try await useCase.login(
                email: username,
                username: username,
                password: password
            )
            await MainActor.run {
                setPasswordValid()
                onLoading((false))
                onLoginSuccess(())
            }
        } catch let error {
            await MainActor.run {
                onLoading((false))
                switch error {
                case .invalidUsername:
                    setEmailRequired()
                case .invalidEmail:
                    setEmailIsNotValidFormat()
                case .invalidPassword:
                    setPasswordIsNotValid()
                case .authorizationFailed(let error):
                    onLoginError((error))
                }
            }
        }
    }
}

extension LoginScreenViewModel: EnvironmentScreenViewModelProtocol {
    public func getEnvironment(environmentViewModel: EnvironmentViewModel) {
        self.environmentViewModel = environmentViewModel
    }
}

extension LoginScreenViewModel {
    private func setEmailRequired() {
        userNameTextFieldViewModel.errorText = "Common.tf.error.required".localized
        userNameTextFieldViewModel.type = .failure
    }
    
    private func setEmailIsNotValidFormat() {
        userNameTextFieldViewModel.errorText = "Common.tf.email.error.notValid".localized
        userNameTextFieldViewModel.type = .failure
    }

    
    private func setPasswordIsNotValid() {
        passwordTextFieldViewModel.errorText = "Common.tf.error.required".localized
        passwordTextFieldViewModel.type = .failure
    }
        
    private func setEmilIsValid() {
        userNameTextFieldViewModel.errorText = ""
        userNameTextFieldViewModel.type = .success
    }
    
    private func setPasswordValid() {
        passwordTextFieldViewModel.errorText = ""
        passwordTextFieldViewModel.type = .success
    }
}

extension LoginScreenLoader {
    public func toggleIsCodeEntryPassword() {
        passwordTextFieldViewModel.isCodeEntry.toggle()
    }
}
