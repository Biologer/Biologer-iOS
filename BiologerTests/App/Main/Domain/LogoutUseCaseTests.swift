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
        let localDataDeleting = LogoutLocalDataDeletingSpy()
        let sut = DefaultLogoutUseCase(
            tokenStorage: tokenStorage,
            userStorage: userStorage,
            localDataDeleting: localDataDeleting
        )

        sut.logout()

        XCTAssertTrue(tokenStorage.didDelete)
        XCTAssertTrue(userStorage.didDelete)
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

}

private final class LogoutLocalDataDeletingSpy: LogoutLocalDataDeleting {
    private(set) var didDeleteLocalData = false

    func deleteLocalData() {
        didDeleteLocalData = true
    }
}
