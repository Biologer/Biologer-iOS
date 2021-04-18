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
    public var labelsViewModel: LoginLabelsViewModel
    public var environmentViewModel: EnvironmentViewModelProtocol
    public var userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol
    public var passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol
    
    private let onSelectEnvironmentTapped: Observer<Void>
    private let onLoginTapped: Observer<Void>
    private let onRegisterTapped: Observer<Void>
    private let onForgotPasswordTapped: Observer<Void>
    
    init(logoImage: String,
         labelsViewModel: LoginLabelsViewModel,
         environmentViewModel: EnvironmentViewModelProtocol,
         userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol,
         passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol,
         onSelectEnvironmentTapped: @escaping Observer<Void>,
         onLoginTapped: @escaping Observer<Void>,
         onRegisterTapped: @escaping Observer<Void>,
         onForgotPasswordTapped: @escaping Observer<Void>
         ) {
        self.logoImage = logoImage
        self.labelsViewModel = labelsViewModel
        self.environmentViewModel = environmentViewModel
        self.userNameTextFieldViewModel = userNameTextFieldViewModel
        self.passwordTextFieldViewModel = passwordTextFieldViewModel
        self.onSelectEnvironmentTapped = onSelectEnvironmentTapped
        self.onLoginTapped = onLoginTapped
        self.onRegisterTapped = onRegisterTapped
        self.onForgotPasswordTapped = onForgotPasswordTapped
    }
    
    public func selectEnvironment() {
        onSelectEnvironmentTapped(())
    }
    
    public func login() {
        onLoginTapped(())
    }
    
    public func register() {
        onRegisterTapped(())
    }
    
    public func forgotPassword() {
        onForgotPasswordTapped(())
    }
}

