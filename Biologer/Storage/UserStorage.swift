//
//  UserStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.21..
//

import Foundation

public protocol UserStorage {
    func getUser() -> User?
    func save(user: User)
    func delete()
    func deleteAllForUser()
}
