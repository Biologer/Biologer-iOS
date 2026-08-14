import Foundation

final class StoredRegistrationLicensePreferenceRepository: RegistrationLicensePreferenceRepository {
    private let storage: LicensePreferenceStorage

    init(storage: LicensePreferenceStorage) {
        self.storage = storage
    }

    func save(_ preference: RegistrationLicensePreference) {
        storage.saveSelectedLicenseID(preference.id, for: preference.kind)
    }
}
