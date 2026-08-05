import Foundation

protocol UserAccountUseCase {
    func loadCurrentUser() async throws(APIError) -> User
    func deleteCurrentUser(deleteObservations: Bool) async throws(APIError)
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

    func loadCurrentUser() async throws(APIError) -> User {
        let user = try await accountRepository.loadCurrentUser()
        userStorage.save(user: user)
        return user
    }

    func deleteCurrentUser(deleteObservations: Bool) async throws(APIError) {
        guard let userID = userStorage.getUser()?.id else {
            throw APIError(description: ErrorConstant.accountDeletionFailed)
        }

        try await accountRepository.deleteCurrentUser(
            userID: userID,
            deleteObservations: deleteObservations
        )
    }
}
