import Foundation

protocol UserAccountUseCase {
    func loadCurrentUser() async throws(SettingsDataFailure) -> User
    func deleteCurrentUser(deleteObservations: Bool) async throws(SettingsDataFailure)
}

final class DefaultUserAccountUseCase: UserAccountUseCase {
    private let accountRepository: AccountRepository
    private let userStorage: UserStorage

    init(
        accountRepository: AccountRepository,
        userStorage: UserStorage
    ) {
        self.accountRepository = accountRepository
        self.userStorage = userStorage
    }

    func loadCurrentUser() async throws(SettingsDataFailure) -> User {
        let user = try await accountRepository.loadCurrentUser()
        userStorage.save(user: user)
        return user
    }

    func deleteCurrentUser(deleteObservations: Bool) async throws(SettingsDataFailure) {
        guard let userID = userStorage.getUser()?.id else {
            throw SettingsDataFailure(
                message: "API.lb.accountDeletionFailed".localized
            )
        }

        try await accountRepository.deleteCurrentUser(
            userID: userID,
            deleteObservations: deleteObservations
        )
    }
}
