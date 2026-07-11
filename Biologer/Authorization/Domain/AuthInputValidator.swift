//
//  AuthInputValidator.swift
//  Biologer
//
//  Created by Nikola Popovic on 6. 7. 2026..
//

import Foundation

public class AuthInputValidator {

    public static func isValid(email: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: email)
    }

    public static func isValid(password: String) -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }

    public static func isEmpty(value: String) -> Bool {
        value.isEmpty
    }

    public static func isNotEmpty(value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public static func passwordsMatch(password: String, repeatedPassword: String) -> Bool {
        password == repeatedPassword
    }
}
