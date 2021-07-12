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
    
    public func getEnvironment() -> String? {
        let environment = KeychainWrapper.standard.string(forKey: environmentKey)
        if let environment = environment {
            return environment
        } else {
            return ""
        }
    }
    
    public func saveEnvironment(env: String) {
        KeychainWrapper.standard.set(env, forKey: environmentKey)
    }
    
    public func delete() {
        KeychainWrapper.standard.removeObject(forKey: environmentKey)
    }
}
