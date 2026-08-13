import XCTest
@testable import Biologer

final class LogoutUseCaseTests: XCTestCase {
    func test_sessionStore_startsUnauthenticatedWithoutPersistedToken() async {
        let tokenStorage = TokenStorageSpy()

        let sut = DefaultSessionStore(tokenStorage: tokenStorage)
        let state = await sut.currentState()

        XCTAssertEqual(state, .unauthenticated)
    }

    func test_sessionStore_startsAuthenticatedWithPersistedToken() async {
        let tokenStorage = TokenStorageSpy()
        tokenStorage.token = AuthToken(accessToken: "access", refreshToken: "refresh")

        let sut = DefaultSessionStore(tokenStorage: tokenStorage)
        let state = await sut.currentState()

        XCTAssertEqual(state, .authenticated)
    }

    func test_sessionStore_marksUnauthenticatedAfterSessionExpiration() async {
        let tokenStorage = TokenStorageSpy()
        tokenStorage.token = AuthToken(accessToken: "access", refreshToken: "refresh")
        let sut = DefaultSessionStore(tokenStorage: tokenStorage)

        await sut.markUnauthenticated()
        let state = await sut.currentState()

        XCTAssertEqual(state, .unauthenticated)
    }

    func test_sessionStore_observationEmitsInitialStateAndChanges() async {
        let tokenStorage = TokenStorageSpy()
        let sut = DefaultSessionStore(tokenStorage: tokenStorage)
        var iterator = await sut.observeState().makeAsyncIterator()

        let initialState = await iterator.next()
        await sut.markAuthenticated()
        let authenticatedState = await iterator.next()

        XCTAssertEqual(initialState, .unauthenticated)
        XCTAssertEqual(authenticatedState, .authenticated)
    }

    func test_logout_clearsSessionAndLocalData() async {
        let tokenStorage = TokenStorageSpy()
        let userStorage = LogoutUserStorageSpy()
        let localDataDeleting = LogoutLocalDataDeletingSpy()
        let sut = DefaultLogoutUseCase(
            tokenStorage: tokenStorage,
            userStorage: userStorage,
            localDataDeleting: localDataDeleting
        )

        await sut.logout()

        XCTAssertTrue(tokenStorage.didDelete)
        XCTAssertTrue(userStorage.didDelete)
        XCTAssertTrue(localDataDeleting.didDeleteLocalData)
    }
}

private final class TokenStorageSpy: TokenStorage {
    var token: AuthToken?
    private(set) var didDelete = false

    func getToken() -> AuthToken? {
        token
    }

    func saveToken(token: AuthToken) {}

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
