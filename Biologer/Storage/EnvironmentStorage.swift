//
//  EnvironmentStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import Foundation

public protocol EnvironmentStorage {
    func getEnvironment() -> EnvironmentViewModel?
    func saveEnvironment(env: EnvironmentViewModel)
    func delete()
}
