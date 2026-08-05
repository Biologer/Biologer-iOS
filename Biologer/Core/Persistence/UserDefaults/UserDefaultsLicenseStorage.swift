import Foundation

final class UserDefaultsLicenseStorage: LicenseStorage {
    private let key: String
    private let defaults: UserDefaults

    init(key: String, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    func getLicense() -> CheckMarkItem? {
        do {
            return try defaults.getObject(forKey: key, castTo: CheckMarkItem.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func saveLicense(license: CheckMarkItem) {
        do {
            try defaults.setObject(license, forKey: key)
        } catch {
            print(error.localizedDescription)
        }
    }
}
