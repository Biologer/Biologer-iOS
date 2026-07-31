import Foundation

struct SettingsAccountContext {
    let email: String
    let username: String
    let environment: String
}

final class SettingsAccountViewModel: ObservableObject {
    let context: SettingsAccountContext
    @Published var shouldDeleteObservations = false

    private let onLogout: Observer<Void>
    private let onDeleteAccount: Observer<Bool>

    init(
        context: SettingsAccountContext,
        onLogout: @escaping Observer<Void>,
        onDeleteAccount: @escaping Observer<Bool>
    ) {
        self.context = context
        self.onLogout = onLogout
        self.onDeleteAccount = onDeleteAccount
    }

    func logout() {
        onLogout(())
    }

    func deleteAccount() {
        onDeleteAccount(shouldDeleteObservations)
    }
}
