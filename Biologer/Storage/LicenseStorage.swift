//
//  LicenseStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.11.21..
//

import Foundation

public protocol LicenseStorage {
    func getLicense() -> CheckMarkItem?
    func saveLicense(license: CheckMarkItem)
    func delete()
}
