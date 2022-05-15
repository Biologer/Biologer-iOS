//
//  SettingsStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 21.11.21..
//

import Foundation

public protocol SettingsStorage {
    func getSettings() -> Settings?
    func saveSettings(settings: Settings)
    func delete()
}
