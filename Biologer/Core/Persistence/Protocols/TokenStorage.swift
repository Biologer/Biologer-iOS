//
//  TokenStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.7.21..
//

public protocol TokenStorage {
    func getToken() -> AuthToken?
    func saveToken(token: AuthToken)
    func delete()
}
