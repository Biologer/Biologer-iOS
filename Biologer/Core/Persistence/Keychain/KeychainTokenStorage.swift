//
//  KeychainTokenStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.7.21..
//

import Foundation
import SwiftKeychainWrapper

public final class KeychainTokenStorage: TokenStorage {
    
    private let tokenKey = "key.tokenKey"
    
    public func getToken() -> AuthToken? {
        do {
            return try KeychainWrapper.standard.getObject(forKey: tokenKey, castTo: AuthToken.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func saveToken(token: AuthToken) {
        do {
            try KeychainWrapper.standard.setObject(token, forKey: tokenKey)
        } catch {
            print("Error with saving env object:\(error.localizedDescription)")
        }
    }
    
    public func delete() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}




