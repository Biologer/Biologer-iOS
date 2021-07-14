//
//  EnvironmentStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import Foundation

public protocol EnvironmentStorage {
    func getEnvironment() -> Environment?
    func saveEnvironment(env: Environment)
    func delete()
}
