import Foundation
import SwiftKeychainWrapper

struct EnvironmentSelectionStorageKeys {
    let environmentID: String
    let legacyEnvironment: String

    static let production = EnvironmentSelectionStorageKeys(
        environmentID: "environment.id.v2",
        legacyEnvironment: "key.environmentKey"
    )
}

protocol EnvironmentSecureDataStore {
    func data(forKey key: String) -> Data?
    func set(
        _ data: Data,
        forKey key: String
    ) throws(EnvironmentSelectionStorageError)
}

struct KeychainEnvironmentSecureDataStore: EnvironmentSecureDataStore {
    func data(forKey key: String) -> Data? {
        KeychainWrapper.standard.data(forKey: key)
    }

    func set(
        _ data: Data,
        forKey key: String
    ) throws(EnvironmentSelectionStorageError) {
        guard KeychainWrapper.standard.set(data, forKey: key) else {
            throw .unableToSave
        }
    }
}

final class KeychainEnvironmentSelectionStorage: EnvironmentSelectionStorage {
    private struct LegacyEnvironment: Codable {
        let clientId: String
        let clientSecret: String
        let host: String
        let path: String
    }

    private let configurationProvider: EnvironmentConfigurationProviding
    private let dataStore: EnvironmentSecureDataStore
    private let keys: EnvironmentSelectionStorageKeys

    convenience init() {
        self.init(
            configurationProvider: DefaultEnvironmentConfigurationProvider(),
            dataStore: KeychainEnvironmentSecureDataStore(),
            keys: .production
        )
    }

    init(
        configurationProvider: EnvironmentConfigurationProviding,
        dataStore: EnvironmentSecureDataStore,
        keys: EnvironmentSelectionStorageKeys
    ) {
        self.configurationProvider = configurationProvider
        self.dataStore = dataStore
        self.keys = keys
    }

    func selectedEnvironmentID() -> EnvironmentID? {
        if let id = storedEnvironmentID() {
            return id
        }

        guard
            let data = dataStore.data(forKey: keys.legacyEnvironment),
            let legacy = try? JSONDecoder().decode(LegacyEnvironment.self, from: data),
            let id = configurationProvider.id(matchingHost: legacy.host)
        else {
            return nil
        }

        // Preserve the valid selection even if the opportunistic migration cannot be written.
        try? saveEnvironmentID(id)
        return id
    }

    func saveEnvironmentID(
        _ id: EnvironmentID
    ) throws(EnvironmentSelectionStorageError) {
        guard let idData = try? JSONEncoder().encode(id) else {
            throw .unableToEncode
        }
        try dataStore.set(idData, forKey: keys.environmentID)

        // Keep the old payload synchronized during the rollback compatibility window.
        let environment = configurationProvider.configuration(for: id)
        let legacy = LegacyEnvironment(
            clientId: environment.clientId,
            clientSecret: environment.clientSecret,
            host: environment.host,
            path: environment.path
        )
        if let legacyData = try? JSONEncoder().encode(legacy) {
            // The v2 ID is authoritative; rollback data is best-effort only.
            try? dataStore.set(legacyData, forKey: keys.legacyEnvironment)
        }
    }

    private func storedEnvironmentID() -> EnvironmentID? {
        guard let data = dataStore.data(forKey: keys.environmentID) else {
            return nil
        }
        return try? JSONDecoder().decode(EnvironmentID.self, from: data)
    }
}
