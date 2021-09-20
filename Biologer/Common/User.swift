//
//  User.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.21..
//

import Foundation

public final class User: Codable {
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let email: String
    public let fullName: String
    public let settings: Settings
    
    public final class Settings: Codable {
        let dataLicense: Int
        let imageLicense: Int
        let language: String

        init(dataLicense: Int,
             imageLicense: Int,
             language: String) {
            self.dataLicense = dataLicense
            self.imageLicense = imageLicense
            self.language = language
        }
    }
    
    init(id: Int,
         firstName: String,
         lastName: String,
         email: String,
         fullName: String,
         settings: Settings) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.fullName = fullName
        self.settings = settings
    }
}
