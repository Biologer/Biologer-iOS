//
//  User.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class RegisterUser {
    public var username: String = ""
    public var lastname: String = ""
    public var insitution: String = ""
    public var email: String = ""
    public var password: String = ""
    public var dataLicense: CheckMarkItem = CheckMarkItem(id: 1, title: "", placeholder: "", type: .data, isSelected: false)
    public var imageLicense: CheckMarkItem = CheckMarkItem(id: 1, title: "", placeholder: "", type: .image, isSelected: false)
}
