import XCTest
@testable import Biologer

final class UserAccountUseCaseTests: XCTestCase {
    private var profileService: ProfileServiceSpy!
    private var userStorage: UserStorageSpy!
    private var sut: DefaultUserAccountUseCase!

    override func setUp() {
        super.setUp()
        profileService = ProfileServiceSpy()
        userStorage = UserStorageSpy()
        sut = DefaultUserAccountUseCase(
            profileService: profileService,
            userStorage: userStorage
        )
    }

    override func tearDown() {
        sut = nil
        userStorage = nil
        profileService = nil
        super.tearDown()
    }

    func test_loadCurrentUser_mapsAndStoresProfileResponse() async throws {
        profileService.profileResult = .success(makeProfileResponse())

        let user = try await sut.loadCurrentUser()

        XCTAssertEqual(user.id, 42)
        XCTAssertEqual(user.firstName, "Nikola")
        XCTAssertEqual(user.lastName, "Popovic")
        XCTAssertEqual(user.email, "nikola@example.com")
        XCTAssertEqual(user.fullName, "Nikola Popovic")
        XCTAssertTrue(user.isVerified)
        XCTAssertEqual(user.settings.dataLicense, 10)
        XCTAssertEqual(user.settings.imageLicense, 20)
        XCTAssertEqual(user.settings.language, "sr-Latn")
        XCTAssertTrue(user === userStorage.savedUser)
    }

    func test_loadCurrentUser_propagatesProfileError() async {
        let expectedError = APIError(description: "Profile failed")
        profileService.profileResult = .failure(expectedError)

        do {
            _ = try await sut.loadCurrentUser()
            XCTFail("Expected loadCurrentUser to throw.")
        } catch {
            XCTAssertTrue(error === expectedError)
            XCTAssertNil(userStorage.savedUser)
        }
    }

    func test_deleteCurrentUser_delegatesToProfileService() async throws {
        userStorage.user = makeUser(id: 42)

        try await sut.deleteCurrentUser(deleteObservations: true)

        XCTAssertEqual(profileService.deletedUserID, 42)
        XCTAssertEqual(profileService.deletedObservations, true)
    }

    func test_deleteCurrentUser_throwsWhenUserIsMissing() async {
        do {
            try await sut.deleteCurrentUser(deleteObservations: false)
            XCTFail("Expected deleteCurrentUser to throw.")
        } catch {
            XCTAssertEqual(error.description, ErrorConstant.accountDeletionFailed)
        }
    }

    private func makeProfileResponse() -> UserDataResponse {
        UserDataResponse(
            data: UserDataResponse.UserResponse(
                id: 42,
                first_name: "Nikola",
                last_name: "Popovic",
                email: "nikola@example.com",
                full_name: "Nikola Popovic",
                is_verified: true,
                settings: UserDataResponse.UserResponse.Settings(
                    data_license: 10,
                    image_license: 20,
                    language: "sr-Latn"
                )
            )
        )
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

private final class ProfileServiceSpy: ProfileService {
    var profileResult: ProfileResult = .failure(APIError(description: "Missing profile result"))
    var deletionResult: DeletionResult = .success(())
    var deletedUserID: Int?
    var deletedObservations: Bool?

    func getMyProfile(completion: @escaping (ProfileResult) -> Void) {
        completion(profileResult)
    }

    func deleteUser(
        userID: Int,
        deleteObservations: Bool,
        completion: @escaping (DeletionResult) -> Void
    ) {
        deletedUserID = userID
        deletedObservations = deleteObservations
        completion(deletionResult)
    }
}

private final class UserStorageSpy: UserStorage {
    var user: User?
    var savedUser: User?
    private(set) var didDelete = false
    private(set) var didDeleteAllForUser = false

    func getUser() -> User? {
        user
    }

    func save(user: User) {
        savedUser = user
        self.user = user
    }

    func delete() {
        didDelete = true
        user = nil
    }

    func deleteAllForUser() {
        didDeleteAllForUser = true
        user = nil
    }
}
