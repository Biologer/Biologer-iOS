//
//  LoginScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import Foundation
import Combine

public final class LoginScreenViewModel: LoginScreenLoader {
    public var environmentPlaceholder: String = "Select Environment"
    public let logoImage: String
    public var labelsViewModel: LoginLabelsViewModel
    @Published public var environmentViewModel: EnvironmentViewModel
    @Published public var userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol
    @Published public var passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol
    
    private let service: LoginUserService
    private let onSelectEnvironmentTapped: Observer<EnvironmentViewModel>
    private let onLoginSuccess: Observer<Token>
    private let onLoginError: Observer<APIError>
    private let onRegisterTapped: Observer<Void>
    private let onForgotPasswordTapped: Observer<Void>
    private let onLoading: Observer<Bool>
    private var email: String = ""
    private var password: String = ""
    
    init(logoImage: String,
         labelsViewModel: LoginLabelsViewModel,
         environmentViewModel: EnvironmentViewModel,
         userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol,
         passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol,
         service: LoginUserService,
         onSelectEnvironmentTapped: @escaping Observer<EnvironmentViewModel>,
         onLoginSuccess: @escaping Observer<Token>,
         onLoginError: @escaping Observer<APIError>,
         onRegisterTapped: @escaping Observer<Void>,
         onForgotPasswordTapped: @escaping Observer<Void>,
         onLoading: @escaping Observer<Bool>
         ) {
        self.logoImage = logoImage
        self.labelsViewModel = labelsViewModel
        self.environmentViewModel = environmentViewModel
        self.userNameTextFieldViewModel = userNameTextFieldViewModel
        self.passwordTextFieldViewModel = passwordTextFieldViewModel
        self.onSelectEnvironmentTapped = onSelectEnvironmentTapped
        self.service = service
        self.onLoginSuccess = onLoginSuccess
        self.onLoginError = onLoginError
        self.onRegisterTapped = onRegisterTapped
        self.onForgotPasswordTapped = onForgotPasswordTapped
        self.onLoading = onLoading
    }
    
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
    
    private func validateFields() {
        if userNameTextFieldViewModel.text.isEmpty {
            setEmailRequired()
           return
        }
        
        if !isEmailValid(email: userNameTextFieldViewModel.text) {
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
                print("Response login: \(response)")
                let token = Token(accessToken: response.access_token, refreshToken: response.refresh_token)
                self?.onLoginSuccess((token))
            case .failure(let error):
                print("Error login: \(error.description)")
                self?.onLoginError((error))
            }
        }
    }
    
    private func isEmailValid(email: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: email)
    }
}

extension LoginScreenViewModel: EnvironmentScreenViewModelProtocol {
    public func getEnvironment(environmentViewModel: EnvironmentViewModel) {
        print("ENV SLECTED: \(environmentViewModel.title)")
        self.environmentViewModel = environmentViewModel
    }
}

extension LoginScreenViewModel {
    private func setEmailRequired() {
        userNameTextFieldViewModel.errorText = "Field is required"
        userNameTextFieldViewModel.type = .failure
    }
    
    private func setEmailIsNotValidFormat() {
        userNameTextFieldViewModel.errorText = "Email is not in valid format"
        userNameTextFieldViewModel.type = .failure
    }

    
    private func setPasswordIsNotValid() {
        passwordTextFieldViewModel.errorText = "Field is required"
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
