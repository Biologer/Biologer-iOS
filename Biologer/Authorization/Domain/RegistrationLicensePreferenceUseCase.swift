import Foundation

protocol RegistrationLicensePreferenceUseCase {
    func saveData(license: CheckMarkItem)
    func saveImage(license: CheckMarkItem)
}

final class DefaultRegistrationLicensePreferenceUseCase: RegistrationLicensePreferenceUseCase {
    private let dataLicenseStorage: LicenseStorage
    private let imageLicenseStorage: LicenseStorage

    init(
        dataLicenseStorage: LicenseStorage,
        imageLicenseStorage: LicenseStorage
    ) {
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
    }

    func saveData(license: CheckMarkItem) {
        dataLicenseStorage.saveLicense(license: license)
    }

    func saveImage(license: CheckMarkItem) {
        imageLicenseStorage.saveLicense(license: license)
    }
}
