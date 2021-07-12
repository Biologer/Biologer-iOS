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

public struct DataLicense {
    var id: Int
    var title: String
    var placeholder: String
    var licenseType: LicenseType
    var isSelected: Bool
    
//    init(id: Int,
//         title: String,
//         placeholder: String,
//         licenseType: LicenseType) {
//        self.id = id
//        self.title = title
//        self.placeholder = placeholder
//        self.licenseType = licenseType
//    }
    
    public mutating func changeIsSelected(value: Bool) {
        isSelected = value
    }
}
