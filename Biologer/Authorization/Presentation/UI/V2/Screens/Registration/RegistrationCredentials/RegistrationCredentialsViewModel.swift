//
//  RegistrationCredentialsViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import Foundation

@MainActor
public final class RegistrationCredentialsViewModel: ObservableObject {
    @Published
    var emailTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = EmailTextFieldViewModel()

    @Published
    var passwordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = RegisterPasswordTextFieldViewModel()

    @Published
    var repeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = RepeatPasswordTextFieldViewModel()

    private let user: RegistrationDraft

    private let validator: RegistrationCredentialsValidating
    private let onNextTapped: Observer<Void>

    init(
        user: RegistrationDraft,
        validator: RegistrationCredentialsValidating,
        onNextTapped: @escaping Observer<Void>
    ) {
        self.validator = validator
        self.onNextTapped = onNextTapped
        self.user = user
    }

    func nextButtonTapped() {
        validateFields()
    }

    private func validateFields() {
        do throws(RegisterUserValidationError) {
            let credentials = try validator.validateCredentials(
                email: emailTextFieldViewModel.text,
                password: passwordTextFieldViewModel.text,
                repeatedPassword: repeatPasswordTextFieldViewModel.text
            )
            user.email = credentials.email
            user.password = credentials.password
            setEmailValid()
            setPasswordValid()
            setRepeatPasswordValid()
            onNextTapped(())
        } catch {
            handle(error)
        }
    }

    private func handle(_ error: RegisterUserValidationError) {
        switch error {
        case .emptyEmail:
            setEmailRequired()
        case .invalidEmail:
            setEmailIsNotValid()
        case .emptyPassword:
            setPasswordIsRequired()
        case .invalidPassword:
            setPasswordIsNotValid()
        case .passwordsDoNotMatch:
            setPasswordDoesntMatches()
        default:
            break
        }
    }
}

extension RegistrationCredentialsViewModel {
    private func setEmailRequired() {
        objectWillChange.send()
        emailTextFieldViewModel.errorText = "Common.tf.error.required".localized
        emailTextFieldViewModel.type = .failure
    }

    private func setEmailIsNotValid() {
        objectWillChange.send()
        emailTextFieldViewModel.errorText = "Common.tf.email.error.notValid" .localized
        emailTextFieldViewModel.type = .failure
    }

    private func setPasswordIsRequired() {
        objectWillChange.send()
        passwordTextFieldViewModel.errorText = "Common.tf.error.required".localized
        passwordTextFieldViewModel.type = .failure
    }

    private func setPasswordIsNotValid() {
        objectWillChange.send()
        passwordTextFieldViewModel.errorText = "Common.tf.password.error.notValid".localized
        passwordTextFieldViewModel.type = .failure
    }

    private func setPasswordDoesntMatches() {
        objectWillChange.send()
        repeatPasswordTextFieldViewModel.errorText = "Register.two.tf.repeatPassword.error".localized
        repeatPasswordTextFieldViewModel.type = .failure
    }

    private func setEmailValid() {
        objectWillChange.send()
        emailTextFieldViewModel.errorText = ""
        emailTextFieldViewModel.type = .success
    }

    private func setPasswordValid() {
        objectWillChange.send()
        passwordTextFieldViewModel.errorText = ""
        passwordTextFieldViewModel.type = .success
    }

    private func setRepeatPasswordValid() {
        objectWillChange.send()
        repeatPasswordTextFieldViewModel.errorText = ""
        repeatPasswordTextFieldViewModel.type = .success
    }
}

extension RegistrationCredentialsViewModel {
    public func toggleIsCodeEntryPassword() {
        objectWillChange.send()
        passwordTextFieldViewModel.isCodeEntry.toggle()
    }

    public func toggleIsCodeEntryRepeatPassword() {
        objectWillChange.send()
        repeatPasswordTextFieldViewModel.isCodeEntry.toggle()
    }
}
