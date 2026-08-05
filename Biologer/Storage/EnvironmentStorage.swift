//
//  EnvironmentStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

public protocol EnvironmentStorage {
    func getEnvironment() -> Environment?
    func saveEnvironment(env: Environment)
}
