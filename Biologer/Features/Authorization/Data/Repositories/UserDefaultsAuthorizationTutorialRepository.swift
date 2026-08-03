import Foundation

final class UserDefaultsAuthorizationTutorialRepository: AuthorizationTutorialRepository {
    private let defaults: UserDefaults
    private let key: String

    init(
        defaults: UserDefaults = .standard,
        key: String = UserDefaultsConstants.shouldPresentTutorialKey
    ) {
        self.defaults = defaults
        self.key = key
    }

    var wasPresented: Bool {
        defaults.bool(forKey: key)
    }

    func markPresented() {
        defaults.set(true, forKey: key)
    }
}
