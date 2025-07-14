//
//  KeychainTaxonsPaginationInfoStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 7.11.21..
//

import Foundation

public final class UserDefaultsTaxonsPaginationInfoStorage: TaxonsPaginationInfoStorage {
    
    private let paginationInfoKey = "key.paginationInfoKey"
    private let lastReadFromFileKey = "key.lastReadFromFile"
    
    public func getLastReadFromFile() -> Int64? {
        let userDefaults = UserDefaults.standard
        do {
            return try userDefaults.getObject(forKey: lastReadFromFileKey, castTo: Int64.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func saveLastReadFromFile(_ date: Int64) {
        let userDefaults = UserDefaults.standard
        do {
            try userDefaults.setObject(date, forKey: lastReadFromFileKey)
            userDefaults.synchronize()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func getPaginationInfo() -> TaxonsPaginationInfo? {
        let userDefaults = UserDefaults.standard
        do {
            return try userDefaults.getObject(forKey: paginationInfoKey, castTo: TaxonsPaginationInfo.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func savePagination(paginationInfo: TaxonsPaginationInfo) {
        let userDefaults = UserDefaults.standard
        do {
            try userDefaults.setObject(paginationInfo, forKey: paginationInfoKey)
            userDefaults.synchronize()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func delete() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: paginationInfoKey)
        defaults.removeObject(forKey: lastReadFromFileKey)
        defaults.synchronize()
    }
}
