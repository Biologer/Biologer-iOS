import XCTest
@testable import Biologer

final class RefreshTokenMechanismTests: XCTestCase {
    func test_givenConcurrentRequestsForSameSession_whenRefreshing_thenOnlyOneRefreshRuns() async throws {
        // Given
        let refresher = BlockingRefresher(result: "new-access")
        let sut = TokenRefreshCoordinator(refresher: refresher)
        let session = TokenSnapshot(accessToken: "expired", refreshToken: "refresh")

        // When
        let first = Task { try await sut.refreshAccessToken(for: session) }
        await refresher.waitUntilCalled()
        let second = Task { try await sut.refreshAccessToken(for: session) }

        let callCount = await refresher.callCount
        XCTAssertEqual(callCount, 1)
        await refresher.resume()

        let firstResult = try await first.value
        let secondResult = try await second.value
        // Then
        XCTAssertEqual(firstResult, "new-access")
        XCTAssertEqual(secondResult, "new-access")
    }

    func test_givenDifferentSessions_whenRefreshingConcurrently_thenEachSessionRefreshesIndependently() async throws {
        // Given
        let refresher = CountingRefresher()
        let sut = TokenRefreshCoordinator(refresher: refresher)
        let firstSession = TokenSnapshot(accessToken: "a", refreshToken: "ra")
        let secondSession = TokenSnapshot(accessToken: "b", refreshToken: "rb")

        // When
        let first = Task { try await sut.refreshAccessToken(for: firstSession) }
        let second = Task { try await sut.refreshAccessToken(for: secondSession) }
        let firstResult = try await first.value
        let secondResult = try await second.value
        let callCount = await refresher.callCount
        // Then
        XCTAssertEqual(firstResult, "access-ra")
        XCTAssertEqual(secondResult, "access-rb")
        XCTAssertEqual(callCount, 2)
    }

    func test_givenCompletedRefreshForSession_whenRefreshingAgain_thenCachedAccessTokenIsReturned() async throws {
        // Given
        let refresher = CountingRefresher()
        let sut = TokenRefreshCoordinator(refresher: refresher)
        let session = TokenSnapshot(accessToken: "a", refreshToken: "r")

        // When
        let firstResult = try await sut.refreshAccessToken(for: session)
        let secondResult = try await sut.refreshAccessToken(for: session)
        let callCount = await refresher.callCount
        // Then
        XCTAssertEqual(firstResult, "access-r")
        XCTAssertEqual(secondResult, "access-r")
        XCTAssertEqual(callCount, 1)
    }

    func test_givenFailedRefresh_whenRetryingLater_thenNewRefreshCanRun() async {
        // Given
        let refresher = FailingThenSucceedingRefresher()
        let sut = TokenRefreshCoordinator(refresher: refresher)
        let session = TokenSnapshot(accessToken: "a", refreshToken: "r")

        do {
            // When
            _ = try await sut.refreshAccessToken(for: session)
            XCTFail("Expected refresh to fail")
        } catch {
            XCTAssertEqual(error as? TestRefreshError, .failed)
        }

        // When
        let result = try? await sut.refreshAccessToken(for: session)
        let callCount = await refresher.callCount
        // Then
        XCTAssertEqual(result, "new")
        XCTAssertEqual(callCount, 2)
    }

    func test_givenRotatedRefreshResponse_whenRefreshing_thenNewTokensAreStored() async throws {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "old", refreshToken: "old-refresh"))
        let client = APIClientStub { _ in
            RefreshTokenResponse(accessToken: "new", refreshToken: "new-refresh")
        }
        let sut = RemoteAccessTokenRefresher(
            client: client,
            environmentStorage: TestEnvironmentStorage(),
            tokenStorage: storage
        )

        // When
        let result = try await sut.refreshAccessToken(
            for: TokenSnapshot(accessToken: "old", refreshToken: "old-refresh")
        )

        // Then
        XCTAssertEqual(result, "new")
        XCTAssertEqual(storage.getToken()?.accessToken, "new")
        XCTAssertEqual(storage.getToken()?.refreshToken, "new-refresh")
    }

    func test_givenRefreshResponseWithoutRefreshToken_whenRefreshing_thenExistingRefreshTokenIsKept() async throws {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "old", refreshToken: "refresh"))
        let client = APIClientStub { _ in
            RefreshTokenResponse(accessToken: "new", refreshToken: nil)
        }
        let sut = RemoteAccessTokenRefresher(
            client: client,
            environmentStorage: TestEnvironmentStorage(),
            tokenStorage: storage
        )

        // When
        _ = try await sut.refreshAccessToken(
            for: TokenSnapshot(accessToken: "old", refreshToken: "refresh")
        )

        // Then
        XCTAssertEqual(storage.getToken()?.refreshToken, "refresh")
    }

    func test_givenEmptyAccessTokenInRefreshResponse_whenRefreshing_thenDecodingFails() async {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "old", refreshToken: "refresh"))
        let client = APIClientStub { _ in
            RefreshTokenResponse(accessToken: "", refreshToken: nil)
        }
        let sut = RemoteAccessTokenRefresher(
            client: client,
            environmentStorage: TestEnvironmentStorage(),
            tokenStorage: storage
        )

        // When / Then
        do {
            _ = try await sut.refreshAccessToken(
                for: TokenSnapshot(accessToken: "old", refreshToken: "refresh")
            )
            XCTFail("Expected decoding failure")
        } catch let error as APIClientError {
            XCTAssertEqual(error, .decodingFailed("The refresh response contains an empty access token."))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_givenInvalidGrantRefreshError_whenRefreshing_thenSessionExpires() async {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "old", refreshToken: "refresh"))
        let client = APIClientStub { _ in
            throw APIClientError.badRequest(
                APIErrorPayload(
                    message: nil,
                    error: "invalid_grant",
                    errorDescription: nil,
                    status: nil,
                    errors: nil
                )
            )
        }
        let sut = RemoteAccessTokenRefresher(
            client: client,
            environmentStorage: TestEnvironmentStorage(),
            tokenStorage: storage
        )

        // When / Then
        do {
            _ = try await sut.refreshAccessToken(
                for: TokenSnapshot(accessToken: "old", refreshToken: "refresh")
            )
            XCTFail("Expected expired session")
        } catch let error as AccessTokenRefreshError {
            guard case .sessionExpired = error else {
                return XCTFail("Unexpected refresh error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_givenOtherBadRequestDuringRefresh_whenRefreshing_thenOriginalAPIErrorIsKept() async {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "old", refreshToken: "refresh"))
        let expectedError = APIClientError.badRequest(
            APIErrorPayload(
                message: "Invalid scope",
                error: "invalid_scope",
                errorDescription: nil,
                status: nil,
                errors: nil
            )
        )
        let client = APIClientStub { _ in throw expectedError }
        let sut = RemoteAccessTokenRefresher(
            client: client,
            environmentStorage: TestEnvironmentStorage(),
            tokenStorage: storage
        )

        // When / Then
        do {
            _ = try await sut.refreshAccessToken(
                for: TokenSnapshot(accessToken: "old", refreshToken: "refresh")
            )
            XCTFail("Expected original API error")
        } catch let error as APIClientError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_givenSessionChangeDuringRefresh_whenRefreshCompletes_thenOldTokenIsNotStored() async {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "old", refreshToken: "refresh"))
        let client = BlockingAPIClient(response: RefreshTokenResponse(accessToken: "new", refreshToken: "rotated"))
        let sut = RemoteAccessTokenRefresher(
            client: client,
            environmentStorage: TestEnvironmentStorage(),
            tokenStorage: storage
        )
        let session = TokenSnapshot(accessToken: "old", refreshToken: "refresh")
        // When
        let task = Task { try await sut.refreshAccessToken(for: session) }

        await client.waitUntilCalled()
        storage.saveToken(token: Token(accessToken: "different", refreshToken: "different-refresh"))
        client.resume()

        do {
            _ = try await task.value
            XCTFail("Expected session change")
        } catch let error as AccessTokenRefreshError {
            guard case .sessionChanged = error else {
                return XCTFail("Unexpected refresh error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        // Then
        XCTAssertEqual(storage.getToken()?.accessToken, "different")
    }

    func test_givenValidAccessToken_whenRequestSucceeds_thenRequestUsesStoredTokenWithoutRefreshing() async throws {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "access", refreshToken: "refresh"))
        let client = RecordingAPIClient(results: [.success(TestResponse(value: "ok"))])
        let refresher = CountingRefresher()
        let sut = AuthenticatedAPIClientDecorator(decoratee: client, tokenStorage: storage, tokenRefresher: refresher)

        // When
        let response: TestResponse = try await sut.send(TestEndpoint())

        // Then
        XCTAssertEqual(response.value, "ok")
        XCTAssertEqual(client.accessTokens, ["access"])
        let callCount = await refresher.callCount
        XCTAssertEqual(callCount, 0)
    }

    func test_given401Response_whenRefreshSucceeds_thenOriginalRequestIsRetriedOnce() async throws {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "expired", refreshToken: "refresh"))
        let client = RecordingAPIClient(results: [
            .failure(APIClientError.unauthorized(nil)),
            .success(TestResponse(value: "ok"))
        ])
        let refresher = SavingRefresher(storage: storage, accessToken: "new")
        let sut = AuthenticatedAPIClientDecorator(decoratee: client, tokenStorage: storage, tokenRefresher: refresher)

        // When
        let response: TestResponse = try await sut.send(TestEndpoint())

        // Then
        XCTAssertEqual(response.value, "ok")
        XCTAssertEqual(client.accessTokens, ["expired", "new"])
        XCTAssertEqual(refresher.callCount, 1)
    }

    func test_given401OnOriginalAndRetry_whenRetryFails_thenSessionExpiresOnce() async throws {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "expired", refreshToken: "refresh"))
        let client = RecordingAPIClient(results: [
            .failure(APIClientError.unauthorized(nil)),
            .failure(APIClientError.unauthorized(nil))
        ])
        let refresher = SavingRefresher(storage: storage, accessToken: "new")
        let expiration = ExpirationRecorder()
        let sut = AuthenticatedAPIClientDecorator(
            decoratee: client,
            tokenStorage: storage,
            tokenRefresher: refresher,
            onSessionExpired: { expiration.record() }
        )

        // When / Then
        do {
            let _: TestResponse = try await sut.send(TestEndpoint())
            XCTFail("Expected unauthorized error")
        } catch let error as APIClientError {
            XCTAssertEqual(error, .unauthorized(nil))
        }

        XCTAssertNil(storage.getToken())
        XCTAssertEqual(expiration.count, 1)
    }

    func test_givenRejectedRefresh_whenRequestFails_thenSessionExpiresOnce() async throws {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "expired", refreshToken: "refresh"))
        let client = RecordingAPIClient(results: [.failure(APIClientError.unauthorized(nil))])
        let refresher = FailingRefresher(error: AccessTokenRefreshError.sessionExpired(nil))
        let expiration = ExpirationRecorder()
        let sut = AuthenticatedAPIClientDecorator(
            decoratee: client,
            tokenStorage: storage,
            tokenRefresher: refresher,
            onSessionExpired: { expiration.record() }
        )

        // When / Then
        do {
            let _: TestResponse = try await sut.send(TestEndpoint())
            XCTFail("Expected unauthorized error")
        } catch let error as APIClientError {
            XCTAssertEqual(error, .unauthorized(nil))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertNil(storage.getToken())
        XCTAssertEqual(expiration.count, 1)
    }

    func test_givenNetworkFailureDuringRefresh_whenRequestFails_thenSessionIsKept() async throws {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "expired", refreshToken: "refresh"))
        let client = RecordingAPIClient(results: [.failure(APIClientError.unauthorized(nil))])
        let refresher = FailingRefresher(error: APIClientError.requestFailed(message: "offline", code: nil))
        let expiration = ExpirationRecorder()
        let sut = AuthenticatedAPIClientDecorator(
            decoratee: client,
            tokenStorage: storage,
            tokenRefresher: refresher,
            onSessionExpired: { expiration.record() }
        )

        // When / Then
        do {
            let _: TestResponse = try await sut.send(TestEndpoint())
            XCTFail("Expected network error")
        } catch let error as APIClientError {
            XCTAssertEqual(error, .requestFailed(message: "offline", code: nil))
        }

        XCTAssertNotNil(storage.getToken())
        XCTAssertEqual(expiration.count, 0)
    }

    func test_givenEmptyStoredAccessToken_whenRequestStarts_thenSessionExpiresWithoutRefresh() async {
        // Given
        let storage = TestTokenStorage(token: Token(accessToken: "", refreshToken: "refresh"))
        let client = RecordingAPIClient(results: [])
        let refresher = CountingRefresher()
        let expiration = ExpirationRecorder()
        let sut = AuthenticatedAPIClientDecorator(
            decoratee: client,
            tokenStorage: storage,
            tokenRefresher: refresher,
            onSessionExpired: { expiration.record() }
        )

        // When / Then
        do {
            let _: TestResponse = try await sut.send(TestEndpoint())
            XCTFail("Expected unauthorized error")
        } catch let error as APIClientError {
            XCTAssertEqual(error, .unauthorized(nil))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertNil(storage.getToken())
        let callCount = await refresher.callCount
        XCTAssertEqual(callCount, 0)
        XCTAssertEqual(expiration.count, 1)
    }
}

private struct TestResponse: Decodable, Equatable {
    let value: String
}

private struct TestEndpoint: APIEndpoint {
    typealias Response = TestResponse
    let host = "example.com"
    let path = "/test"
}

private final class TestTokenStorage: TokenStorage, @unchecked Sendable {
    private let lock = NSLock()
    private var token: Token?

    init(token: Token? = nil) { self.token = token }
    func getToken() -> Token? { lock.withLock { token } }
    func saveToken(token: Token) { lock.withLock { self.token = token } }
    func delete() { lock.withLock { token = nil } }
}

private final class TestEnvironmentStorage: EnvironmentStorage {
    func getEnvironment() -> Environment? {
        Environment(host: "example.com", path: "", clientSecret: "secret", cliendId: "client")
    }
    func saveEnvironment(env: Environment) {}
}

private final class APIClientStub: APIClientProtocol, @unchecked Sendable {
    let handler: (Any) async throws -> Any
    init(handler: @escaping (Any) async throws -> Any) { self.handler = handler }
    func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.Response {
        try await handler(endpoint) as! E.Response
    }
}

private final class BlockingAPIClient: APIClientProtocol, @unchecked Sendable {
    private let response: Any
    private var continuation: CheckedContinuation<Void, Never>?
    private var called = false

    init(response: Any) { self.response = response }
    func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.Response {
        called = true
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.continuation = continuation
        }
        return response as! E.Response
    }
    func waitUntilCalled() async {
        while !called { await Task.yield() }
    }
    func resume() { continuation?.resume() }
}

private final class RecordingAPIClient: APIClientProtocol, @unchecked Sendable {
    enum Result { case success(TestResponse); case failure(APIClientError) }
    private var results: [Result]
    private(set) var accessTokens: [String] = []
    init(results: [Result]) { self.results = results }

    func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.Response {
        let mirror = Mirror(reflecting: endpoint)
        if let token = mirror.children.first(where: { $0.label == "accessToken" })?.value as? String {
            accessTokens.append(token)
        }
        guard !results.isEmpty else { fatalError("Missing scripted result") }
        switch results.removeFirst() {
        case .success(let response): return response as! E.Response
        case .failure(let error): throw error
        }
    }
}

private actor BlockingRefresher: AccessTokenRefreshing {
    private let result: String
    private var continuation: CheckedContinuation<String, Error>?
    private(set) var callCount = 0

    init(result: String) { self.result = result }
    func refreshAccessToken(for session: TokenSnapshot) async throws -> String {
        callCount += 1
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }
    func waitUntilCalled() async {
        while callCount == 0 { await Task.yield() }
    }
    func resume() { continuation?.resume(returning: result) }
}

private actor CountingRefresher: AccessTokenRefreshing {
    private(set) var callCount = 0
    func refreshAccessToken(for session: TokenSnapshot) async throws -> String {
        callCount += 1
        return "access-\(session.refreshToken)"
    }
}

private enum TestRefreshError: Error, Equatable { case failed }

private actor FailingThenSucceedingRefresher: AccessTokenRefreshing {
    private(set) var callCount = 0
    func refreshAccessToken(for session: TokenSnapshot) async throws -> String {
        callCount += 1
        if callCount == 1 { throw TestRefreshError.failed }
        return "new"
    }
}

private final class SavingRefresher: AccessTokenRefreshing {
    private let storage: TokenStorage
    let accessToken: String
    private(set) var callCount = 0
    init(storage: TokenStorage, accessToken: String) { self.storage = storage; self.accessToken = accessToken }
    func refreshAccessToken(for session: TokenSnapshot) async throws -> String {
        callCount += 1
        storage.saveToken(token: Token(accessToken: accessToken, refreshToken: session.refreshToken))
        return accessToken
    }
}

private final class FailingRefresher: AccessTokenRefreshing {
    let error: Error
    init(error: Error) { self.error = error }
    func refreshAccessToken(for session: TokenSnapshot) async throws -> String { throw error }
}

private final class ExpirationRecorder: @unchecked Sendable {
    private(set) var count = 0
    func record() { count += 1 }
}

private extension NSLock {
    func withLock<T>(_ operation: () -> T) -> T {
        lock(); defer { unlock() }
        return operation()
    }
}
