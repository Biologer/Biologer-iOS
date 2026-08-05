//
//  UserDefaultsUserStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.21..
//

import Foundation

public final class UserDefaultsUserStorage: UserStorage {
    private let userKey = "user"
    
    public func getUser() -> User? {
        let userDefaults = UserDefaults.standard
        do {
            return try userDefaults.getObject(forKey: userKey, castTo: User.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func save(user: User) {
        let userDefaults = UserDefaults.standard
        do {
            try userDefaults.setObject(user, forKey: userKey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func delete() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: userKey)
    }
}
