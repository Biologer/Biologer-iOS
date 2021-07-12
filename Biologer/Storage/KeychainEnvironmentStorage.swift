//
//  KeychainEnvironmentStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import Foundation
import SwiftKeychainWrapper

public final class KeychainEnvironmentStorage: EnvironmentStorage {
    
    private let environmentKey = "key.environmentKey"
    
    public func getEnvironment() -> EnvironmentViewModel? {
        
        do {
            return try KeychainWrapper.standard.getObject(forKey: environmentKey, castTo: EnvironmentViewModel.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func saveEnvironment(env: EnvironmentViewModel) {
        do {
            try KeychainWrapper.standard.setObject(env, forKey: environmentKey)
        } catch {
            print("Error with saving env object:\(error.localizedDescription)")
        }
    }
    
    public func delete() {
        KeychainWrapper.standard.removeObject(forKey: environmentKey)
    }
}

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

extension KeychainWrapper {
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
