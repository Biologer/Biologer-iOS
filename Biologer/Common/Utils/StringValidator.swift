//
//  StringValidator.swift
//  Biologer
//
//  Created by Nikola Popovic on 9.9.23..
//

import Foundation

public protocol StringValidator {
    func isValid(text: String) -> Bool
}

public final class EmailValidator: StringValidator {
    public func isValid(text: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: text)
    }
}

public final class PasswordValidator: StringValidator {
    public func isValid(text: String) -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: text)
    }
}
