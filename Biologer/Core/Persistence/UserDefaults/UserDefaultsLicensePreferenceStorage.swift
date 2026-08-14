import Foundation

struct UserDefaultsLicensePreferenceKeys {
    let dataID: String
    let imageID: String
    let legacyData: String
    let legacyImage: String

    static let production = UserDefaultsLicensePreferenceKeys(
        dataID: "license.data.id.v2",
        imageID: "license.image.id.v2",
        legacyData: "dataLicense.key",
        legacyImage: "imageLicense.key"
    )

    func idKey(for kind: LicenseKind) -> String {
        switch kind {
        case .data: dataID
        case .image: imageID
        }
    }

    func legacyKey(for kind: LicenseKind) -> String {
        switch kind {
        case .data: legacyData
        case .image: legacyImage
        }
    }
}

/// Persists only stable IDs while retaining read/write compatibility with legacy CheckMarkItem JSON.
final class UserDefaultsLicensePreferenceStorage: LicensePreferenceStorage {
    private struct LegacyLicenseID: Decodable {
        let id: Int
    }

    private struct LegacyLicense: Encodable {
        let id: Int
        let title: String
        let placeholder: String
        let type: LicenseKind
        let isSelected: Bool
    }

    private let defaults: UserDefaults
    private let keys: UserDefaultsLicensePreferenceKeys
    private let optionsProvider: LicenseOptionsProviding

    init(
        defaults: UserDefaults = .standard,
        keys: UserDefaultsLicensePreferenceKeys = .production,
        optionsProvider: LicenseOptionsProviding
    ) {
        self.defaults = defaults
        self.keys = keys
        self.optionsProvider = optionsProvider
    }

    func selectedLicenseID(for kind: LicenseKind) -> Int? {
        if let id = defaults.object(
            forKey: keys.idKey(for: kind)
        ) as? Int,
           optionsProvider.option(id: id, kind: kind) != nil {
            return id
        }

        // A missing or no-longer-supported v2 ID can still be recovered from
        // the rollback-compatible payload written by an older app version.
        guard let data = defaults.data(forKey: keys.legacyKey(for: kind)),
              let legacy = try? JSONDecoder().decode(
                  LegacyLicenseID.self,
                  from: data
              ),
              optionsProvider.option(id: legacy.id, kind: kind) != nil else {
            return nil
        }

        saveSelectedLicenseID(legacy.id, for: kind)
        return legacy.id
    }

    func saveSelectedLicenseID(_ id: Int, for kind: LicenseKind) {
        guard let option = optionsProvider.option(id: id, kind: kind) else {
            return
        }

        defaults.set(id, forKey: keys.idKey(for: kind))

        // Keep the old app format synchronized during the compatibility window.
        let legacy = LegacyLicense(
            id: option.id,
            title: option.title,
            placeholder: option.details,
            type: option.kind,
            isSelected: true
        )
        if let data = try? JSONEncoder().encode(legacy) {
            defaults.set(data, forKey: keys.legacyKey(for: kind))
        }
    }
}
