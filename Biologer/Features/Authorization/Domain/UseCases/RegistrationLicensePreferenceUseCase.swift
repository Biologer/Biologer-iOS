import Foundation

protocol RegistrationLicensePreferenceUseCase {
    func saveLicense(_ preference: RegistrationLicensePreference)
}

final class DefaultRegistrationLicensePreferenceUseCase: RegistrationLicensePreferenceUseCase {
    private let repository: RegistrationLicensePreferenceRepository

    init(repository: RegistrationLicensePreferenceRepository) {
        self.repository = repository
    }

    func saveLicense(_ preference: RegistrationLicensePreference) {
        repository.save(preference)
    }
}
