//
//  FieldsValidator.swift
//  Biologer
//
//  Created by Nikola Popovic on 6. 7. 2026..
//

import Foundation

public class FieldsValidator {
    
    public static func isValid(email: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: email)
    }
    
    public static func isEmpty(value: String) -> Bool {
        value.isEmpty
    }
}
