//
//  RegistrationCredentialsViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import Foundation

@MainActor
public final class RegistrationCredentialsViewModel: ObservableObject {
    @Published private(set) var email: String
    @Published private(set) var password: String
    @Published private(set) var repeatedPassword: String
    @Published private(set) var emailError: String?
    @Published private(set) var passwordError: String?
    @Published private(set) var repeatedPasswordError: String?

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
        email = user.email
        password = user.password
        repeatedPassword = user.password
    }

    func nextButtonTapped() {
        validateFields()
    }

    func updateEmail(_ email: String) {
        self.email = email
        emailError = nil
    }

    func updatePassword(_ password: String) {
        self.password = password
        passwordError = nil
    }

    func updateRepeatedPassword(_ password: String) {
        repeatedPassword = password
        repeatedPasswordError = nil
    }

    private func validateFields() {
        do throws(RegisterUserValidationError) {
            let credentials = try validator.validateCredentials(
                email: email,
                password: password,
                repeatedPassword: repeatedPassword
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
        emailError = "Common.tf.error.required".localized
    }

    private func setEmailIsNotValid() {
        emailError = "Common.tf.email.error.notValid".localized
    }

    private func setPasswordIsRequired() {
        passwordError = "Common.tf.error.required".localized
    }

    private func setPasswordIsNotValid() {
        passwordError = "Common.tf.password.error.notValid".localized
    }

    private func setPasswordDoesntMatches() {
        repeatedPasswordError = "Register.two.tf.repeatPassword.error".localized
    }

    private func setEmailValid() {
        emailError = nil
    }

    private func setPasswordValid() {
        passwordError = nil
    }

    private func setRepeatPasswordValid() {
        repeatedPasswordError = nil
    }
}
