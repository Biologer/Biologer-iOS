//
//  SettingsStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 21.11.21..
//

public protocol SettingsStorage {
    func getSettings() -> Settings?
    func saveSettings(settings: Settings)
}
