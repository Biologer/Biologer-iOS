//
//  TokenStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.7.21..
//

import Foundation

public protocol TokenStorage {
    func getToken() -> Token?
    func saveToken(token: Token)
    func delete()
}
