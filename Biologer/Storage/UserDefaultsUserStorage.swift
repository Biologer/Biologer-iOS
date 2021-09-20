//
//  UserDefaultsUserStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.21..
//

import Foundation

public final class UserDefaultsUserStorage: UserStorage {
    
    let userKey = "user"
    
    func getUser() -> User? {
        let userDefaults = UserDefaults.standard
        do {
            return try userDefaults.getObject(forKey: userKey, castTo: User.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func save(user: User) {
        let userDefaults = UserDefaults.standard
        do {
            try userDefaults.setObject(user, forKey: userKey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func delete() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: userKey)
    }
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}
