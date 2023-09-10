//
//  RegisterStepTwoScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class RegisterStepTwoScreenViewModel: RegisterStepTwoScreenLoader {
    @Published var emailTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = EmailTextFieldViewModel()
    @Published var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = RegisterPasswordTextFieldViewModel()
    @Published var repeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = RepeatPasswordTextFieldViewModel()
    var buttonTitle = "Register.two.btn.next".localized
    
    private let user: RegisterUser
    private let onNextTapped: Observer<RegisterUser>
    private let emailValidator: StringValidator
    private let passwordValidator: StringValidator
    
    init(user: RegisterUser,
         emailValidator: StringValidator,
         passwordValidator: StringValidator,
         onNextTapped: @escaping Observer<RegisterUser>) {
        self.onNextTapped = onNextTapped
        self.user = user
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
    }
    
    // MARK: - Public Functions

    func nextButtonTapped() {
        validateFields()
    }
    
    // MARK: - Private Functions
    
    private func validateFields() {
        if emailTextFieldViewModel.text.isEmpty {
            setEmailRequired()
            return
        }

        if !emailValidator.isValid(text: emailTextFieldViewModel.text) {
            setEmailIsNotValid()
            return
        }

        user.email = emailTextFieldViewModel.text
        setEmailValid()

        if passwordTextFieldViewModel.text.isEmpty {
            setPasswordIsRequired()
            return
        }

        if !passwordValidator.isValid(text: passwordTextFieldViewModel.text) {
            setPasswordIsNotValid()
            return
        }

        user.password = passwordTextFieldViewModel.text
        setPasswordValid()

        if repeatPasswordTextFieldViewModel.text != passwordTextFieldViewModel.text {
            setPasswordDoesntMatches()
            return
        }
        setRepeatPasswordValid()
        onNextTapped((user))
    }
}

extension RegisterStepTwoScreenViewModel {
    private func setEmailRequired() {
        emailTextFieldViewModel.errorText = "Common.tf.error.required".localized
        emailTextFieldViewModel.type = .failure
    }
    
    private func setEmailIsNotValid() {
        emailTextFieldViewModel.errorText = "Common.tf.email.error.notValid" .localized
        emailTextFieldViewModel.type = .failure
    }
    
    private func setPasswordIsRequired() {
        passwordTextFieldViewModel.errorText = "Common.tf.error.required".localized
        passwordTextFieldViewModel.type = .failure
    }
    
    private func setPasswordIsNotValid() {
        passwordTextFieldViewModel.errorText = "Common.tf.password.error.notValid".localized
        passwordTextFieldViewModel.type = .failure
    }
    
    private func setPasswordDoesntMatches() {
        repeatPasswordTextFieldViewModel.errorText = "Register.two.tf.repeatPassword.error".localized
        repeatPasswordTextFieldViewModel.type = .failure
    }
    
    private func setEmailValid() {
        emailTextFieldViewModel.errorText = ""
        emailTextFieldViewModel.type = .success
    }
    
    private func setPasswordValid() {
        passwordTextFieldViewModel.errorText = ""
        passwordTextFieldViewModel.type = .success
    }
    
    private func setRepeatPasswordValid() {
        repeatPasswordTextFieldViewModel.errorText = ""
        repeatPasswordTextFieldViewModel.type = .success
    }
}

extension RegisterStepTwoScreenLoader {
    public func toggleIsCodeEntryPassword() {
        passwordTextFieldViewModel.isCodeEntry.toggle()
    }
    
    public func toggleIsCodeEntryRepeatPassword() {
        repeatPasswordTextFieldViewModel.isCodeEntry.toggle()
    }
}
