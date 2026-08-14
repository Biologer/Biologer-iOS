import Foundation
import XCTest
@testable import Biologer

final class PersistenceMigrationTests: XCTestCase {
    func test_licenseRead_givenLegacyPayload_migratesStableIDAndKeepsLegacyPayload() throws {
        let context = try makeLicenseContext()
        defer { context.defaults.removePersistentDomain(forName: context.suiteName) }
        context.defaults.set(
            try XCTUnwrap(
                """
                {
                  "id": 30,
                  "title": "Old localized title",
                  "placeholder": "Old localized details",
                  "type": "data",
                  "isSelected": true
                }
                """.data(using: .utf8)
            ),
            forKey: context.keys.legacyData
        )

        let id = context.storage.selectedLicenseID(for: .data)

        XCTAssertEqual(id, 30)
        XCTAssertEqual(context.defaults.object(forKey: context.keys.dataID) as? Int, 30)
        XCTAssertNotNil(context.defaults.data(forKey: context.keys.legacyData))
    }

    func test_licenseRead_givenV2AndConflictingLegacy_prefersV2ID() throws {
        let context = try makeLicenseContext()
        defer { context.defaults.removePersistentDomain(forName: context.suiteName) }
        context.defaults.set(20, forKey: context.keys.imageID)
        context.defaults.set(
            try XCTUnwrap("{\"id\":40}".data(using: .utf8)),
            forKey: context.keys.legacyImage
        )

        XCTAssertEqual(context.storage.selectedLicenseID(for: .image), 20)
    }

    func test_licenseSave_writesV2IDAndRollbackCompatibleLegacyPayload() throws {
        let context = try makeLicenseContext()
        defer { context.defaults.removePersistentDomain(forName: context.suiteName) }

        context.storage.saveSelectedLicenseID(40, for: .image)

        XCTAssertEqual(context.defaults.object(forKey: context.keys.imageID) as? Int, 40)
        let legacyData = try XCTUnwrap(
            context.defaults.data(forKey: context.keys.legacyImage)
        )
        let legacy = try JSONDecoder().decode(LegacyLicenseID.self, from: legacyData)
        XCTAssertEqual(legacy.id, 40)
    }

    func test_environmentRead_givenLegacyPayload_migratesIDAndUsesCurrentConfiguration() throws {
        let dataStore = EnvironmentSecureDataStoreSpy()
        let keys = makeEnvironmentKeys()
        dataStore.values[keys.legacyEnvironment] = try XCTUnwrap(
            """
            {
              "clientId": "outdated-client",
              "clientSecret": "outdated-secret",
              "host": "\(APIConstants.croatiaHost)",
              "path": "/outdated"
            }
            """.data(using: .utf8)
        )
        let configurations = DefaultEnvironmentConfigurationProvider()
        let storage = KeychainEnvironmentSelectionStorage(
            configurationProvider: configurations,
            dataStore: dataStore,
            keys: keys
        )
        let sut = DefaultCurrentEnvironmentProvider(
            selectionStorage: storage,
            configurationProvider: configurations
        )

        let environment = sut.currentEnvironment()

        XCTAssertEqual(environment, configurations.configuration(for: .croatia))
        let idData = try XCTUnwrap(dataStore.values[keys.environmentID])
        XCTAssertEqual(try JSONDecoder().decode(EnvironmentID.self, from: idData), .croatia)
        XCTAssertNotNil(dataStore.values[keys.legacyEnvironment])
    }

    func test_environmentRead_givenV2AndConflictingLegacy_prefersV2ID() throws {
        let dataStore = EnvironmentSecureDataStoreSpy()
        let keys = makeEnvironmentKeys()
        dataStore.values[keys.environmentID] = try JSONEncoder().encode(
            EnvironmentID.montenegro
        )
        dataStore.values[keys.legacyEnvironment] = try XCTUnwrap(
            """
            {
              "clientId": "",
              "clientSecret": "",
              "host": "\(APIConstants.serbiaHost)",
              "path": ""
            }
            """.data(using: .utf8)
        )
        let configurations = DefaultEnvironmentConfigurationProvider()
        let storage = KeychainEnvironmentSelectionStorage(
            configurationProvider: configurations,
            dataStore: dataStore,
            keys: keys
        )
        let sut = DefaultCurrentEnvironmentProvider(
            selectionStorage: storage,
            configurationProvider: configurations
        )

        XCTAssertEqual(sut.currentEnvironment()?.id, .montenegro)
    }

    func test_environmentRead_givenUnknownLegacyHost_returnsNilWithoutDefaultingToSerbia() throws {
        let dataStore = EnvironmentSecureDataStoreSpy()
        let keys = makeEnvironmentKeys()
        dataStore.values[keys.legacyEnvironment] = try XCTUnwrap(
            """
            {
              "clientId": "",
              "clientSecret": "",
              "host": "unknown.example.com",
              "path": ""
            }
            """.data(using: .utf8)
        )
        let sut = KeychainEnvironmentSelectionStorage(
            configurationProvider: DefaultEnvironmentConfigurationProvider(),
            dataStore: dataStore,
            keys: keys
        )

        XCTAssertNil(sut.selectedEnvironmentID())
        XCTAssertNil(dataStore.values[keys.environmentID])
    }

    func test_environmentSave_writesIDAndRollbackCompatibleLegacyPayload() throws {
        let dataStore = EnvironmentSecureDataStoreSpy()
        let keys = makeEnvironmentKeys()
        let configurations = DefaultEnvironmentConfigurationProvider()
        let sut = KeychainEnvironmentSelectionStorage(
            configurationProvider: configurations,
            dataStore: dataStore,
            keys: keys
        )

        try sut.saveEnvironmentID(.bosniaAndHerzegovina)

        let idData = try XCTUnwrap(dataStore.values[keys.environmentID])
        XCTAssertEqual(
            try JSONDecoder().decode(EnvironmentID.self, from: idData),
            .bosniaAndHerzegovina
        )
        let legacyData = try XCTUnwrap(dataStore.values[keys.legacyEnvironment])
        let legacy = try JSONDecoder().decode(LegacyEnvironmentHost.self, from: legacyData)
        XCTAssertEqual(legacy.host, APIConstants.bosnianAndHerzegovinHost)
    }

    private func makeLicenseContext() throws -> (
        suiteName: String,
        defaults: UserDefaults,
        keys: UserDefaultsLicensePreferenceKeys,
        storage: UserDefaultsLicensePreferenceStorage
    ) {
        let suiteName = "PersistenceMigrationTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        let keys = UserDefaultsLicensePreferenceKeys(
            dataID: "data.id.v2",
            imageID: "image.id.v2",
            legacyData: "data.legacy",
            legacyImage: "image.legacy"
        )
        return (
            suiteName,
            defaults,
            keys,
            UserDefaultsLicensePreferenceStorage(
                defaults: defaults,
                keys: keys,
                optionsProvider: DefaultLicenseOptionsProvider()
            )
        )
    }

    private func makeEnvironmentKeys() -> EnvironmentSelectionStorageKeys {
        EnvironmentSelectionStorageKeys(
            environmentID: "environment.id.test.v2",
            legacyEnvironment: "environment.legacy.test"
        )
    }
}

private struct LegacyLicenseID: Decodable {
    let id: Int
}

private struct LegacyEnvironmentHost: Decodable {
    let host: String
}

private final class EnvironmentSecureDataStoreSpy: EnvironmentSecureDataStore {
    var values: [String: Data] = [:]

    func data(forKey key: String) -> Data? {
        values[key]
    }

    func set(
        _ data: Data,
        forKey key: String
    ) throws(EnvironmentSelectionStorageError) {
        values[key] = data
    }
}
