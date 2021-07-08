//
//  DataLicense.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public enum LicenseType {
    case data
    case image
}

public final class DataLicense: ObservableObject {
    var id: Int
    var title: String
    var placeholder: String
    var licenseType: LicenseType
    
    init(id: Int,
         title: String,
         placeholder: String,
         licenseType: LicenseType) {
        self.id = id
        self.title = title
        self.placeholder = placeholder
        self.licenseType = licenseType
    }
}
