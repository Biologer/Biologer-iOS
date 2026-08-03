import XCTest
@testable import Biologer

final class FindingLocationUseCasesTests: XCTestCase {
    func test_observeCurrentLocationForwardsUpdatesAndStop() {
        let expected = makeLocation(altitude: 120)
        let repository = FindingCurrentLocationRepositorySpy()
        let sut = DefaultObserveCurrentFindingLocationUseCase(repository: repository)
        var receivedLocation: FindingEditorLocation?

        sut.start(
            onLocation: { receivedLocation = $0 },
            onError: { _ in XCTFail("Unexpected location error") }
        )
        repository.send(expected)
        sut.stop()

        XCTAssertEqual(receivedLocation, expected)
        XCTAssertEqual(repository.startCallCount, 1)
        XCTAssertEqual(repository.stopCallCount, 1)
    }

    func test_resolveLocationUsesRemoteAltitude() async {
        let initial = makeLocation(altitude: 12)
        let repository = FindingAltitudeRepositoryStub(result: .success(345))
        let sut = DefaultResolveFindingLocationUseCase(
            altitudeRepository: repository
        )

        let result = await sut.execute(initial)

        XCTAssertEqual(result.altitude, 345)
        XCTAssertEqual(result.latitude, initial.latitude)
        XCTAssertEqual(result.longitude, initial.longitude)
        XCTAssertEqual(repository.receivedCoordinates.count, 1)
    }

    func test_resolveLocationKeepsExistingAltitudeWhenRemoteLookupFails() async {
        let initial = makeLocation(altitude: 12)
        let repository = FindingAltitudeRepositoryStub(
            result: .failure(FindingLocationUseCaseTestError.altitudeUnavailable)
        )
        let sut = DefaultResolveFindingLocationUseCase(
            altitudeRepository: repository
        )

        let result = await sut.execute(initial)

        XCTAssertEqual(result, initial)
    }

    private func makeLocation(altitude: Double) -> FindingEditorLocation {
        FindingEditorLocation(
            latitude: 44.78657,
            longitude: 20.44892,
            altitude: altitude,
            accuracy: 5
        )
    }
}

private enum FindingLocationUseCaseTestError: Error {
    case altitudeUnavailable
}

private final class FindingCurrentLocationRepositorySpy:
    FindingCurrentLocationRepository {
    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0
    private var onLocation: ((FindingEditorLocation) -> Void)?

    func start(
        onLocation: @escaping (FindingEditorLocation) -> Void,
        onError: @escaping (FindingLocationRepositoryError) -> Void
    ) {
        startCallCount += 1
        self.onLocation = onLocation
    }

    func stop() {
        stopCallCount += 1
    }

    func send(_ location: FindingEditorLocation) {
        onLocation?(location)
    }
}

private final class FindingAltitudeRepositoryStub: FindingAltitudeRepository {
    let result: Result<Double, Error>
    private(set) var receivedCoordinates: [(latitude: Double, longitude: Double)] = []

    init(result: Result<Double, Error>) {
        self.result = result
    }

    func altitude(latitude: Double, longitude: Double) async throws -> Double {
        receivedCoordinates.append((latitude, longitude))
        return try result.get()
    }
}
