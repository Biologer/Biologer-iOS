import XCTest
@testable import Biologer

final class LoginUserUseCaseTests: XCTestCase {
    private var repository: LoginUserRepositorySpy!
    private var sut: DefaultLoginUserUseCase!

    override func setUp() {
        super.setUp()
        repository = LoginUserRepositorySpy()
        sut = DefaultLoginUserUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_login_rejectsBlankUsernameWithoutCallingRepository() async {
        await assertLoginError(.invalidUsername, email: " ", username: " ", password: "Password1")
        XCTAssertEqual(repository.callCount, 0)
    }

    func test_login_rejectsMalformedEmailWithoutCallingRepository() async {
        await assertLoginError(.invalidEmail, email: "invalid", username: "invalid", password: "Password1")
        XCTAssertEqual(repository.callCount, 0)
    }

    func test_login_rejectsBlankPasswordWithoutCallingRepository() async {
        await assertLoginError(.invalidPassword, email: "user@example.com", username: "user@example.com", password: " ")
        XCTAssertEqual(repository.callCount, 0)
    }

    func test_login_delegatesValidCredentialsToRepository() async throws {
        try await sut.login(
            email: "user@example.com",
            username: "user@example.com",
            password: "Password1"
        )

        XCTAssertEqual(repository.callCount, 1)
        XCTAssertEqual(repository.receivedEmail, "user@example.com")
        XCTAssertEqual(repository.receivedPassword, "Password1")
    }

    func test_login_mapsRepositoryFailureToLoginError() async {
        let failure = AuthorizationFailure(summary: "Login failed", message: "Wrong credentials")
        repository.result = .failure(failure)

        do {
            try await sut.login(
                email: "user@example.com",
                username: "user@example.com",
                password: "Password1"
            )
            XCTFail("Expected login to throw.")
        } catch let error {
            guard case .authorizationFailed(let receivedFailure) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertEqual(receivedFailure, failure)
        }
    }

    private func assertLoginError(
        _ expectedError: LoginError,
        email: String,
        username: String,
        password: String
    ) async {
        do {
            try await sut.login(email: email, username: username, password: password)
            XCTFail("Expected login to throw.")
        } catch let error {
            switch (error, expectedError) {
            case (.invalidUsername, .invalidUsername),
                 (.invalidEmail, .invalidEmail),
                 (.invalidPassword, .invalidPassword):
                break
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}

private final class LoginUserRepositorySpy: LoginUserRepository {
    var result: Result<Void, AuthorizationFailure> = .success(())
    private(set) var callCount = 0
    private(set) var receivedEmail: String?
    private(set) var receivedPassword: String?

    func login(email: String, password: String) async throws(AuthorizationFailure) {
        callCount += 1
        receivedEmail = email
        receivedPassword = password
        try result.get()
    }
}
