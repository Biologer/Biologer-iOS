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
    
    init(user: RegisterUser, onNextTapped: @escaping Observer<RegisterUser>) {
        self.onNextTapped = onNextTapped
        self.user = user
    }

    func nextButtonTapped() {
        validateFields()
    }
    
    private func validateFields() {
        if emailTextFieldViewModel.text.isEmpty {
            setEmailRequired()
            return
        }

        if !isEmailValid(email: emailTextFieldViewModel.text) {
            setEmailIsNotValid()
            return
        }

        user.email = emailTextFieldViewModel.text
        setEmailValid()

        if passwordTextFieldViewModel.text.isEmpty {
            setPasswordIsRequired()
            return
        }

        if !isPasswordValid(password: passwordTextFieldViewModel.text) {
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
    
    private func isEmailValid(email: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: email)
    }
    
    public func isPasswordValid(password: String) -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
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
