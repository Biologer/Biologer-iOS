import Foundation

protocol RegistrationInputValidating {
    func validatePersonalInfo(
        firstName: String,
        lastName: String,
        institution: String
    ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo

    func validateCredentials(
        email: String,
        password: String,
        repeatedPassword: String
    ) throws(RegisterUserValidationError) -> RegistrationCredentials
}

final class DefaultRegistrationInputValidator: RegistrationInputValidating {
    func validatePersonalInfo(
        firstName: String,
        lastName: String,
        institution: String
    ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo {
        guard AuthInputValidator.isNotEmpty(value: firstName) else {
            throw .emptyUsername
        }

        guard AuthInputValidator.isNotEmpty(value: lastName) else {
            throw .emptyLastName
        }

        return RegistrationPersonalInfo(
            firstName: firstName,
            lastName: lastName,
            institution: institution
        )
    }

    func validateCredentials(
        email: String,
        password: String,
        repeatedPassword: String
    ) throws(RegisterUserValidationError) -> RegistrationCredentials {
        guard AuthInputValidator.isNotEmpty(value: email) else {
            throw .emptyEmail
        }

        guard AuthInputValidator.isValid(email: email) else {
            throw .invalidEmail
        }

        guard AuthInputValidator.isNotEmpty(value: password) else {
            throw .emptyPassword
        }

        guard AuthInputValidator.isValid(password: password) else {
            throw .invalidPassword
        }

        guard AuthInputValidator.passwordsMatch(password: password, repeatedPassword: repeatedPassword) else {
            throw .passwordsDoNotMatch
        }

        return RegistrationCredentials(email: email, password: password)
    }
}

struct RegistrationPersonalInfo: Equatable {
    let firstName: String
    let lastName: String
    let institution: String
}

struct RegistrationCredentials: Equatable {
    let email: String
    let password: String
}

enum RegisterUserValidationError: Error, Equatable {
    case emptyUsername
    case emptyLastName
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case invalidPassword
    case passwordsDoNotMatch
}
