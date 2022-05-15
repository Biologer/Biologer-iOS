//
//  UserDefaultsDataLicenseStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.11.21..
//

import Foundation

public final class UserDefaultsDataLicenseStorage: LicenseStorage {
    
    private let key = "dataLicense.key"
    
    public func getLicense() -> CheckMarkItem? {
        let userDefaults = UserDefaults.standard
        do {
            return try userDefaults.getObject(forKey: key, castTo: CheckMarkItem.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func saveLicense(license: CheckMarkItem) {
        let userDefaults = UserDefaults.standard
        do {
            try userDefaults.setObject(license, forKey: key)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func delete() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
    }
}
