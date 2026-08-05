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
    
    public func getEnvironment() -> Environment? {
        
        do {
            return try KeychainWrapper.standard.getObject(forKey: environmentKey, castTo: Environment.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func saveEnvironment(env: Environment) {
        do {
            try KeychainWrapper.standard.setObject(env, forKey: environmentKey)
        } catch {
            print("Error with saving env object:\(error.localizedDescription)")
        }
    }
}
