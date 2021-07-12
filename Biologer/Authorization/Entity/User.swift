//
//  User.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class User {
    public var username: String = ""
    public var lastname: String = ""
    public var insitution: String = ""
    public var email: String = ""
    public var password: String = ""
    public var dataLicense: DataLicense = DataLicense(id: 1, title: "", placeholder: "", licenseType: .data, isSelected: false)
    public var imageLicense: DataLicense = DataLicense(id: 1, title: "", placeholder: "", licenseType: .image, isSelected: false)
}
