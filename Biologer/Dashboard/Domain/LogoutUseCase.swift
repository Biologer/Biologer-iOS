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

    init(
        tokenStorage: TokenStorage,
        userStorage: UserStorage,
        taxonPaginationInfoStorage: TaxonsPaginationInfoStorage,
        localDataDeleting: LogoutLocalDataDeleting
    ) {
        self.tokenStorage = tokenStorage
        self.userStorage = userStorage
        self.taxonPaginationInfoStorage = taxonPaginationInfoStorage
        self.localDataDeleting = localDataDeleting
    }

    func logout() {
        tokenStorage.delete()
        userStorage.delete()
        taxonPaginationInfoStorage.delete()
        localDataDeleting.deleteLocalData()
    }
}
