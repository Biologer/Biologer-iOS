final class StoredFindingSubmissionAccessRepository: FindingSubmissionAccessRepository {
    private let userStorage: UserStorage

    init(userStorage: UserStorage) {
        self.userStorage = userStorage
    }

    func isUserVerified() -> Bool {
        userStorage.getUser()?.isVerified == true
    }
}
