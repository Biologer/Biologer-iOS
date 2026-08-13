import Foundation

protocol LogoutUseCase {
    func logout() async
}

protocol LogoutLocalDataDeleting {
    func deleteLocalData()
}

final class DefaultLogoutUseCase: LogoutUseCase {
    private let tokenStorage: TokenStorage
    private let userStorage: UserStorage
    private let localDataDeleting: LogoutLocalDataDeleting
    private let sessionStore: SessionStore?

    init(
        tokenStorage: TokenStorage,
        userStorage: UserStorage,
        localDataDeleting: LogoutLocalDataDeleting,
        sessionStore: SessionStore? = nil
    ) {
        self.tokenStorage = tokenStorage
        self.userStorage = userStorage
        self.localDataDeleting = localDataDeleting
        self.sessionStore = sessionStore
    }

    func logout() async {
        tokenStorage.delete()
        userStorage.delete()
        localDataDeleting.deleteLocalData()
        await sessionStore?.markUnauthenticated()
    }
}
