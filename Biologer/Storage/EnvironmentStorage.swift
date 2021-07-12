//
//  EnvironmentStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import Foundation

public protocol EnvironmentStorage {
    func getEnvironment() -> String?
    func saveEnvironment(env: String)
    func delete()
}
