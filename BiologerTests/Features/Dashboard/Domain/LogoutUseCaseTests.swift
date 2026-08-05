import XCTest
@testable import Biologer

final class LogoutUseCaseTests: XCTestCase {
    func test_sessionStore_startsUnauthenticatedWithoutPersistedToken() {
        let tokenStorage = TokenStorageSpy()

        let sut = DefaultSessionStore(tokenStorage: tokenStorage)

        XCTAssertEqual(sut.state, .unauthenticated)
    }

    func test_sessionStore_startsAuthenticatedWithPersistedToken() {
        let tokenStorage = TokenStorageSpy()
        tokenStorage.token = Token(accessToken: "access", refreshToken: "refresh")

        let sut = DefaultSessionStore(tokenStorage: tokenStorage)

        XCTAssertEqual(sut.state, .authenticated)
    }

    func test_sessionStore_marksUnauthenticatedAfterSessionExpiration() {
        let tokenStorage = TokenStorageSpy()
        tokenStorage.token = Token(accessToken: "access", refreshToken: "refresh")
        let sut = DefaultSessionStore(tokenStorage: tokenStorage)

        sut.markUnauthenticated()

        XCTAssertEqual(sut.state, .unauthenticated)
    }

    func test_logout_clearsSessionAndLocalData() {
        let tokenStorage = TokenStorageSpy()
        let userStorage = LogoutUserStorageSpy()
        let paginationStorage = TaxonPaginationInfoStorageSpy()
        let localDataDeleting = LogoutLocalDataDeletingSpy()
        let sut = DefaultLogoutUseCase(
            tokenStorage: tokenStorage,
            userStorage: userStorage,
            taxonPaginationInfoStorage: paginationStorage,
            localDataDeleting: localDataDeleting
        )

        sut.logout()

        XCTAssertTrue(tokenStorage.didDelete)
        XCTAssertTrue(userStorage.didDelete)
        XCTAssertTrue(paginationStorage.didDelete)
        XCTAssertTrue(localDataDeleting.didDeleteLocalData)
    }
}

private final class TokenStorageSpy: TokenStorage {
    var token: Token?
    private(set) var didDelete = false

    func getToken() -> Token? {
        token
    }

    func saveToken(token: Token) {}

    func delete() {
        didDelete = true
        token = nil
    }
}

private final class LogoutUserStorageSpy: UserStorage {
    private(set) var didDelete = false

    func getUser() -> User? {
        nil
    }

    func save(user: User) {}

    func delete() {
        didDelete = true
    }

    func deleteAllForUser() {}
}

private final class TaxonPaginationInfoStorageSpy: TaxonsPaginationInfoStorage {
    private(set) var didDelete = false

    func getPaginationInfo() -> TaxonsPaginationInfo? {
        nil
    }

    func getLastReadFromFile() -> Int64? {
        nil
    }

    func savePagination(paginationInfo: TaxonsPaginationInfo) {}

    func saveLastReadFromFile(_ date: Int64) {}

    func delete() {
        didDelete = true
    }
}

private final class LogoutLocalDataDeletingSpy: LogoutLocalDataDeleting {
    private(set) var didDeleteLocalData = false

    func deleteLocalData() {
        didDeleteLocalData = true
    }
}
