//
//  UserDefaultsSettingsStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 21.11.21..
//

import Foundation

public final class UserDefaultsSettingsStorage: SettingsStorage {
    
    let settingsKey = "settings.key"
    
    public func getSettings() -> Settings? {
        let userDefaults = UserDefaults.standard
        do {
            return try userDefaults.getObject(forKey: settingsKey, castTo: Settings.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func saveSettings(settings: Settings) {
        let userDefaults = UserDefaults.standard
        do {
            try userDefaults.setObject(settings, forKey: settingsKey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func delete() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: settingsKey)
    }
}
