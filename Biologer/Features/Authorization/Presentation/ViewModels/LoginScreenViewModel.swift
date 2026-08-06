//
//  LoginScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

enum LoginSubmissionResult: Equatable {
    case success
    case validationFailure
    case authorizationFailure(AuthorizationFailure)
}

@MainActor
public final class LoginScreenViewModel: ObservableObject {

    @Published public var isLoading: Bool = false
    @Published public var environmentViewModel: EnvironmentViewModel
    @Published public private(set) var email: String = ""
    @Published public private(set) var password: String = ""
    @Published public private(set) var emailError: String?
    @Published public private(set) var passwordError: String?

    private let useCase: LoginUserUseCase

    init(
        environmentViewModel: EnvironmentViewModel,
        useCase: LoginUserUseCase
    ) {
        self.environmentViewModel = environmentViewModel
        self.useCase = useCase
    }

    public func updateEnvironment(_ environmentViewModel: EnvironmentViewModel) {
        self.environmentViewModel = environmentViewModel
    }

    public func updateEmail(_ email: String) {
        self.email = email
        emailError = nil
    }

    public func updatePassword(_ password: String) {
        self.password = password
        passwordError = nil
    }

    func login() async -> LoginSubmissionResult {
        isLoading = true
        do throws(LoginError) {
            try await useCase.login(
                email: email,
                username: email,
                password: password
            )
            setEmailIsValid()
            setPasswordValid()
            isLoading = false
            return .success
        } catch let error {
            isLoading = false
            switch error {
            case .invalidUsername:
                setEmailRequired()
                return .validationFailure
            case .invalidEmail:
                setEmailIsNotValidFormat()
                return .validationFailure
            case .invalidPassword:
                setPasswordIsNotValid()
                return .validationFailure
            case .authorizationFailed(let error):
                return .authorizationFailure(error)
            }
        }
    }
}

extension LoginScreenViewModel {
    private func setEmailRequired() {
        emailError = "Common.tf.error.required".localized
    }

    private func setEmailIsNotValidFormat() {
        emailError = "Common.tf.email.error.notValid".localized
    }

    private func setPasswordIsNotValid() {
        passwordError = "Common.tf.error.required".localized
    }

    private func setEmailIsValid() {
        emailError = nil
    }

    private func setPasswordValid() {
        passwordError = nil
    }
}
