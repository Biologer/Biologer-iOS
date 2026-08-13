import XCTest
@testable import Biologer

@MainActor
final class FindingLocationUseCasesTests: XCTestCase {
    func test_observeCurrentLocationForwardsUpdatesAndStopsOnCancellation() async {
        let expected = makeLocation(altitude: 120)
        let repository = FindingCurrentLocationRepositorySpy()
        let sut = DefaultObserveCurrentFindingLocationUseCase(
            repository: repository
        )
        var receivedEvent: FindingCurrentLocationEvent?
        let observationTask = Task {
            let stream = await sut.execute()
            for await event in stream {
                receivedEvent = event
            }
        }
        await waitUntil { repository.startCallCount == 1 }

        repository.send(expected)
        await waitUntil { receivedEvent != nil }
        observationTask.cancel()
        await observationTask.value
        await waitUntil { repository.stopCallCount == 1 }

        XCTAssertEqual(receivedEvent, .location(expected))
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
            result: .failure(.altitudeUnavailable)
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

    private func waitUntil(
        _ condition: @escaping @MainActor () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<100 {
            if condition() { return }
            await Task.yield()
        }

        XCTFail("Condition was not satisfied.", file: file, line: line)
    }
}

@MainActor
private final class FindingCurrentLocationRepositorySpy:
    FindingCurrentLocationRepository {
    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0
    private var onLocation: ((FindingEditorLocation) -> Void)?

    func start(
        onLocation: @escaping (FindingEditorLocation) -> Void,
        onError: @escaping (FindingLocationRepositoryError) -> Void
    ) async {
        startCallCount += 1
        self.onLocation = onLocation
    }

    func stop() async {
        stopCallCount += 1
        onLocation = nil
    }

    func send(_ location: FindingEditorLocation) {
        onLocation?(location)
    }
}

private final class FindingAltitudeRepositoryStub: FindingAltitudeRepository {
    let result: Result<Double, FindingAltitudeRepositoryError>
    private(set) var receivedCoordinates: [
        (latitude: Double, longitude: Double)
    ] = []

    init(result: Result<Double, FindingAltitudeRepositoryError>) {
        self.result = result
    }

    func altitude(
        latitude: Double,
        longitude: Double
    ) async throws(FindingAltitudeRepositoryError) -> Double {
        receivedCoordinates.append((latitude, longitude))
        return try result.get()
    }
}
