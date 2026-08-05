import Foundation

protocol LogoutUseCase {
    func logout()
}

protocol LogoutLocalDataDeleting {
    func deleteLocalData()
}

final class DefaultLogoutUseCase: LogoutUseCase {
    private let tokenStorage: TokenStorage
    private let userStorage: UserStorage
    private let taxonPaginationInfoStorage: TaxonsPaginationInfoStorage
    private let localDataDeleting: LogoutLocalDataDeleting
    private let sessionStore: SessionStore?

    init(
        tokenStorage: TokenStorage,
        userStorage: UserStorage,
        taxonPaginationInfoStorage: TaxonsPaginationInfoStorage,
        localDataDeleting: LogoutLocalDataDeleting,
        sessionStore: SessionStore? = nil
    ) {
        self.tokenStorage = tokenStorage
        self.userStorage = userStorage
        self.taxonPaginationInfoStorage = taxonPaginationInfoStorage
        self.localDataDeleting = localDataDeleting
        self.sessionStore = sessionStore
    }

    func logout() {
        tokenStorage.delete()
        userStorage.delete()
        taxonPaginationInfoStorage.delete()
        localDataDeleting.deleteLocalData()
        sessionStore?.markUnauthenticated()
    }
}
