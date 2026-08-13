import Foundation

struct SettingsAccountContext {
    let email: String
    let username: String
    let environment: String
}

@MainActor
final class SettingsAccountViewModel: ObservableObject {
    let context: SettingsAccountContext
    @Published var shouldDeleteObservations = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let accountUseCase: UserAccountUseCase
    private let logoutUseCase: LogoutUseCase

    init(
        context: SettingsAccountContext,
        accountUseCase: UserAccountUseCase,
        logoutUseCase: LogoutUseCase
    ) {
        self.context = context
        self.accountUseCase = accountUseCase
        self.logoutUseCase = logoutUseCase
    }

    func logout() async {
        await logoutUseCase.logout()
    }

    func deleteAccount() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await accountUseCase.deleteCurrentUser(
                deleteObservations: shouldDeleteObservations
            )
            await logoutUseCase.logout()
        } catch {
            errorMessage = error.message
        }
    }

    func dismissError() {
        errorMessage = nil
    }
}
