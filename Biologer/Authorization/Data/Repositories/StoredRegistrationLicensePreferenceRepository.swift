import Foundation

final class StoredRegistrationLicensePreferenceRepository: RegistrationLicensePreferenceRepository {
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage

    init(dataLicenseStorage: LicenseStorage, imageLicenseStorage: LicenseStorage) {
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
    }

    func save(_ preference: RegistrationLicensePreference) {
        switch preference.kind {
        case .data:
            guard let license = CheckMarkItemMapper.getDataLicense().first(where: { $0.id == preference.id }) else {
                return
            }
            dataLicenseStorage.saveLicense(license: license)
        case .image:
            guard let license = CheckMarkItemMapper.getImageLicense().first(where: { $0.id == preference.id }) else {
                return
            }
            imageLicenseStorage.saveLicense(license: license)
        }
    }
}
