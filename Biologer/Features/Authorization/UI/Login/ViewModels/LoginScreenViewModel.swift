//
//  LoginScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import Foundation
import Combine

public final class LoginScreenViewModel: LoginScreenLoader {
    public var environmentPlaceholder = "Login.env.placeholder".localized
    public let logoImage = "biologer_logo_icon"
    public var labelsViewModel = LoginLabelsViewModel()
    @Published public var environmentViewModel: EnvironmentViewModel
    @Published public var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = UserNameTextFieldViewModel()
    @Published public var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = PasswordTextFieldViewModel()
    
    private let service: LoginUserService
    private let emailValidator: StringValidator
    private let onSelectEnvironmentTapped: Observer<EnvironmentViewModel>
    private let onLoginSuccess: Observer<Token>
    private let onLoginError: Observer<APIError>
    private let onRegisterTapped: Observer<Void>
    private let onForgotPasswordTapped: Observer<Void>
    private let onLoading: Observer<Bool>
    private var email = ""
    private var password = ""
    
    init(environmentViewModel: EnvironmentViewModel,
         service: LoginUserService,
         emailValidator: StringValidator,
         onSelectEnvironmentTapped: @escaping Observer<EnvironmentViewModel>,
         onLoginSuccess: @escaping Observer<Token>,
         onLoginError: @escaping Observer<APIError>,
         onRegisterTapped: @escaping Observer<Void>,
         onForgotPasswordTapped: @escaping Observer<Void>,
         onLoading: @escaping Observer<Bool>
    ) {
        self.environmentViewModel = environmentViewModel
        self.onSelectEnvironmentTapped = onSelectEnvironmentTapped
        self.service = service
        self.emailValidator = emailValidator
        self.onLoginSuccess = onLoginSuccess
        self.onLoginError = onLoginError
        self.onRegisterTapped = onRegisterTapped
        self.onForgotPasswordTapped = onForgotPasswordTapped
        self.onLoading = onLoading
    }
    
    // MARK: - Public Functions
    
    public func selectEnvironment() {
        onSelectEnvironmentTapped((environmentViewModel))
    }
    
    public func login() {
        validateFields()
    }
    
    public func register() {
        onRegisterTapped(())
    }
    
    public func forgotPassword() {
        onForgotPasswordTapped(())
    }
    
    // MARK: - Private Functions
    
    private func validateFields() {
        if userNameTextFieldViewModel.text.isEmpty {
            setEmailRequired()
           return
        }
        
        if !emailValidator.isValid(text: userNameTextFieldViewModel.text) {
            setEmailIsNotValidFormat()
            return
        }
        
        setEmilIsValid()
        
        if passwordTextFieldViewModel.text.isEmpty {
            setPasswordIsNotValid()
            return
        }
        
        setPasswordValid()
        
        email = userNameTextFieldViewModel.text
        password = passwordTextFieldViewModel.text
        
        onLoading((true))
        service.login(email: email,
                           password: password) { [weak self] result in
            self?.onLoading((false))
            switch result {
            case .success(let response):
                let token = Token(accessToken: response.access_token, refreshToken: response.refresh_token)
                self?.onLoginSuccess((token))
            case .failure(let error):
                self?.onLoginError((error))
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
