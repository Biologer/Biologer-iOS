import Foundation

protocol UserAccountUseCase {
    func loadCurrentUser() async throws(APIError) -> User
    func deleteCurrentUser(deleteObservations: Bool) async throws(APIError) -> Void
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
        let response = try await accountRepository.loadCurrentUser()
        let user = User(response.data)
        userStorage.save(user: user)
        return user
    }

    func deleteCurrentUser(deleteObservations: Bool) async throws(APIError) -> Void {
        guard let userID = userStorage.getUser()?.id else {
            throw APIError(description: ErrorConstant.accountDeletionFailed)
        }

        try await accountRepository.deleteCurrentUser(
            userID: userID,
            deleteObservations: deleteObservations
        )
    }
}

private extension User {
    convenience init(_ response: UserDataResponse.UserResponse) {
        self.init(
            id: response.id,
            firstName: response.first_name,
            lastName: response.last_name,
            email: response.email,
            fullName: response.full_name,
            isVerified: response.is_verified,
            settings: Settings(
                dataLicense: response.settings.data_license,
                imageLicense: response.settings.image_license,
                language: response.settings.language
            )
        )
    }
}
