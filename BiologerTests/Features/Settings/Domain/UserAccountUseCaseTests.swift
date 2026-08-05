import XCTest
@testable import Biologer

final class UserAccountUseCaseTests: XCTestCase {
    private var accountRepository: AccountRepositorySpy!
    private var userStorage: UserStorageSpy!
    private var sut: DefaultUserAccountUseCase!

    override func setUp() {
        super.setUp()
        accountRepository = AccountRepositorySpy()
        userStorage = UserStorageSpy()
        sut = DefaultUserAccountUseCase(
            accountRepository: accountRepository,
            userStorage: userStorage
        )
    }

    override func tearDown() {
        sut = nil
        userStorage = nil
        accountRepository = nil
        super.tearDown()
    }

    func test_loadCurrentUser_whenRepositorySucceeds_storesAndReturnsUser() async throws {
        // Given
        let expectedUser = makeUser(id: 42)
        accountRepository.userResult = .success(expectedUser)

        // When
        let user = try await sut.loadCurrentUser()

        // Then
        XCTAssertTrue(user === expectedUser)
        XCTAssertTrue(userStorage.savedUser === expectedUser)
    }

    func test_loadCurrentUser_whenRepositoryFails_propagatesErrorWithoutStoringUser() async {
        // Given
        let expectedError = APIError(description: "Profile failed")
        accountRepository.userResult = .failure(expectedError)

        // When
        do {
            _ = try await sut.loadCurrentUser()
            XCTFail("Expected loadCurrentUser to throw.")
        } catch {
            // Then
            XCTAssertTrue(error === expectedError)
            XCTAssertNil(userStorage.savedUser)
        }
    }

    func test_deleteCurrentUser_whenUserExists_delegatesDeletionToRepository() async throws {
        // Given
        userStorage.user = makeUser(id: 42)

        // When
        try await sut.deleteCurrentUser(deleteObservations: true)

        // Then
        XCTAssertEqual(accountRepository.deletedUserID, 42)
        XCTAssertEqual(accountRepository.deletedObservations, true)
    }

    func test_deleteCurrentUser_whenUserIsMissing_throwsAccountDeletionError() async {
        // Given
        userStorage.user = nil

        // When
        do {
            try await sut.deleteCurrentUser(deleteObservations: false)
            XCTFail("Expected deleteCurrentUser to throw.")
        } catch {
            // Then
            XCTAssertEqual(error.description, ErrorConstant.accountDeletionFailed)
        }
    }

    private func makeUser(id: Int) -> User {
        User(
            id: id,
            firstName: "Nikola",
            lastName: "Popovic",
            email: "nikola@example.com",
            fullName: "Nikola Popovic",
            isVerified: true,
            settings: User.Settings(
                dataLicense: 10,
                imageLicense: 20,
                language: "sr-Latn"
            )
        )
    }
}

private final class AccountRepositorySpy: AccountRepository {
    var userResult: Result<User, APIError> = .failure(
        APIError(description: "Missing user result")
    )
    var deletionResult: Result<Void, APIError> = .success(())
    private(set) var deletedUserID: Int?
    private(set) var deletedObservations: Bool?

    func loadCurrentUser() async throws(APIError) -> User {
        try userResult.get()
    }

    func deleteCurrentUser(
        userID: Int,
        deleteObservations: Bool
    ) async throws(APIError) {
        deletedUserID = userID
        deletedObservations = deleteObservations
        try deletionResult.get()
    }
}

private final class UserStorageSpy: UserStorage {
    var user: User?
    private(set) var savedUser: User?

    func getUser() -> User? {
        user
    }

    func save(user: User) {
        savedUser = user
        self.user = user
    }

    func delete() {
        user = nil
    }

}
