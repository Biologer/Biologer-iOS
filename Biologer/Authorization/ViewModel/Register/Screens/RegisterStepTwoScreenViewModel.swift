//
//  RegisterStepTwoScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class RegisterStepTwoScreenViewModel: RegisterStepTwoScreenLoader {
    @Published var emailTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = EmailTextFieldViewModel()
    @Published var passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = RegisterPasswordTextFieldViewModel()
    @Published var repeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = RepeatPasswordTextFieldViewModel()
    var buttonTitle = "Next"
    
    private let user: User
    private let onNextTapped: Observer<User>
    
    init(user: User, onNextTapped: @escaping Observer<User>) {
        self.onNextTapped = onNextTapped
        self.user = user
    }

    func nextButtonTapped() {
        validateFields()
    }
    
    private func validateFields() {
//        if emailTextFieldViewModel.text.isEmpty {
//            setEmailRequired()
//            return
//        }
//
//        if !isEmailValid(email: emailTextFieldViewModel.text) {
//            setEmailIsNotValid()
//            return
//        }
//        setEmailValid()
//        
//        if passwordTextFieldViewModel.text.isEmpty {
//            setPasswordIsRequired()
//            return
//        }
//
//        if !isPasswordValid(password: passwordTextFieldViewModel.text) {
//            setPasswordIsNotValid()
//            return
//        }
//
//        setPasswordValid()
//
//        if repeatPasswordTextFieldViewModel.text != passwordTextFieldViewModel.text {
//            setPasswordDoesntMatches()
//            return
//        }
//        setRepeatPasswordValid()
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
        emailTextFieldViewModel.errorText = "Field is required"
        emailTextFieldViewModel.type = .failure
    }
    
    private func setEmailIsNotValid() {
        emailTextFieldViewModel.errorText = "Email is not in valid format"
        emailTextFieldViewModel.type = .failure
    }
    
    private func setPasswordIsRequired() {
        passwordTextFieldViewModel.errorText = "Field is required"
        passwordTextFieldViewModel.type = .failure
    }
    
    private func setPasswordIsNotValid() {
        passwordTextFieldViewModel.errorText = "Password must contain an uppercase letter, a number, and be at least 8 characters long"
        passwordTextFieldViewModel.type = .failure
    }
    
    private func setPasswordDoesntMatches() {
        repeatPasswordTextFieldViewModel.errorText = "Password doesn't matches"
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
