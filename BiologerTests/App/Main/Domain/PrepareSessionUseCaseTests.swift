import XCTest
@testable import Biologer

final class PrepareSessionUseCaseTests: XCTestCase {
    func test_execute_whenRemoteRequestsSucceed_loadsAccountAndSynchronizesObservations() async throws {
        // Given
        let accountUseCase = PrepareSessionAccountUseCaseSpy()
        let observationRepository = PrepareSessionObservationRepositorySpy()
        let sut = DefaultPrepareSessionUseCase(
            accountUseCase: accountUseCase,
            observationRepository: observationRepository,
            userStorage: PrepareSessionUserStorageSpy(user: nil)
        )

        // When
        try await sut.execute()

        // Then
        XCTAssertEqual(accountUseCase.loadCallCount, 1)
        XCTAssertEqual(observationRepository.synchronizeCallCount, 1)
        XCTAssertEqual(observationRepository.hasStoredCallCount, 0)
    }

    func test_execute_whenAccountRequestFailsAndCachedUserExists_synchronizesObservations() async throws {
        // Given
        let accountUseCase = PrepareSessionAccountUseCaseSpy()
        accountUseCase.loadError = APIError(description: "account")
        let observationRepository = PrepareSessionObservationRepositorySpy()
        let sut = DefaultPrepareSessionUseCase(
            accountUseCase: accountUseCase,
            observationRepository: observationRepository,
            userStorage: PrepareSessionUserStorageSpy(user: makeUser())
        )

        // When
        try await sut.execute()

        // Then
        XCTAssertEqual(accountUseCase.loadCallCount, 1)
        XCTAssertEqual(observationRepository.synchronizeCallCount, 1)
    }

    func test_execute_whenAccountRequestFailsAndCachedUserIsMissing_throwsAccountError() async {
        // Given
        let accountUseCase = PrepareSessionAccountUseCaseSpy()
        accountUseCase.loadError = APIError(description: "account")
        let observationRepository = PrepareSessionObservationRepositorySpy()
        let sut = DefaultPrepareSessionUseCase(
            accountUseCase: accountUseCase,
            observationRepository: observationRepository,
            userStorage: PrepareSessionUserStorageSpy(user: nil)
        )

        // When
        do {
            try await sut.execute()
            XCTFail("Expected account error.")
        } catch {
            // Then
            XCTAssertEqual(error.description, "account")
            XCTAssertEqual(observationRepository.synchronizeCallCount, 0)
        }
    }

    func test_execute_whenObservationRequestFailsAndStoredObservationsExist_completesSuccessfully() async throws {
        // Given
        let observationRepository = PrepareSessionObservationRepositorySpy()
        observationRepository.synchronizeError = APIError(description: "observations")
        observationRepository.hasStored = true
        let sut = DefaultPrepareSessionUseCase(
            accountUseCase: PrepareSessionAccountUseCaseSpy(),
            observationRepository: observationRepository,
            userStorage: PrepareSessionUserStorageSpy(user: nil)
        )

        // When
        try await sut.execute()

        // Then
        XCTAssertEqual(observationRepository.synchronizeCallCount, 1)
        XCTAssertEqual(observationRepository.hasStoredCallCount, 1)
    }

    func test_execute_whenObservationRequestFailsAndStoredObservationsAreMissing_throwsObservationError() async {
        // Given
        let observationRepository = PrepareSessionObservationRepositorySpy()
        observationRepository.synchronizeError = APIError(description: "observations")
        observationRepository.hasStored = false
        let sut = DefaultPrepareSessionUseCase(
            accountUseCase: PrepareSessionAccountUseCaseSpy(),
            observationRepository: observationRepository,
            userStorage: PrepareSessionUserStorageSpy(user: nil)
        )

        // When
        do {
            try await sut.execute()
            XCTFail("Expected observation error.")
        } catch {
            // Then
            XCTAssertEqual(error.description, "observations")
            XCTAssertEqual(observationRepository.hasStoredCallCount, 1)
        }
    }

    private func makeUser() -> User {
        User(
            id: 1,
            firstName: "",
            lastName: "",
            email: "",
            fullName: "",
            isVerified: true,
            settings: User.Settings(dataLicense: 1, imageLicense: 1, language: "en")
        )
    }
}

private final class PrepareSessionAccountUseCaseSpy: UserAccountUseCase {
    var loadError: APIError?
    private(set) var loadCallCount = 0

    func loadCurrentUser() async throws(APIError) -> User {
        loadCallCount += 1
        if let loadError { throw loadError }
        return User(
            id: 1,
            firstName: "",
            lastName: "",
            email: "",
            fullName: "",
            isVerified: true,
            settings: User.Settings(dataLicense: 1, imageLicense: 1, language: "en")
        )
    }

    func deleteCurrentUser(deleteObservations: Bool) async throws(APIError) {}
}

private final class PrepareSessionObservationRepositorySpy: ObservationRepository {
    var synchronizeError: APIError?
    var hasStored = false
    private(set) var synchronizeCallCount = 0
    private(set) var hasStoredCallCount = 0

    func getObservationTypes() async throws(APIError) -> ObservationDataResponse {
        fatalError("Not used by the session preparation use case.")
    }

    func synchronizeObservationTypes() async throws(APIError) {
        synchronizeCallCount += 1
        if let synchronizeError { throw synchronizeError }
    }

    func hasStoredObservationTypes() -> Bool {
        hasStoredCallCount += 1
        return hasStored
    }
}

private final class PrepareSessionUserStorageSpy: UserStorage {
    private var user: User?

    init(user: User?) {
        self.user = user
    }

    func getUser() -> User? { user }
    func save(user: User) { self.user = user }
    func delete() { user = nil }
    func deleteAllForUser() { user = nil }
}
