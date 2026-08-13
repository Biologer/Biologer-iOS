import XCTest
@testable import Biologer

@MainActor
final class FindingLocationViewModelTests: XCTestCase {
    func test_observeLocation_selectsFirstCurrentLocationAndStopsOnCancellation() async {
        let current = makeLocation(latitude: 44.8, longitude: 20.4, altitude: 120)
        let observer = FindingLocationObserverStub()
        let sut = makeSUT(observer: observer)
        let observationTask = Task { await sut.observeLocation() }
        await waitUntil { observer.isObserved }

        observer.send(current)
        await waitUntil { sut.currentLocation == current }

        observationTask.cancel()
        await observationTask.value

        XCTAssertEqual(sut.selectedLocation, current)
        XCTAssertEqual(sut.currentLocation, current)
        XCTAssertEqual(sut.status, .ready)
        XCTAssertEqual(sut.cameraTarget.latitude, current.latitude)
        XCTAssertEqual(sut.cameraTarget.longitude, current.longitude)
        XCTAssertEqual(observer.terminationCount, 1)
    }

    func test_manualSelectionRemainsAvailableWhenAuthorizationIsDenied() async {
        let observer = FindingLocationObserverStub()
        let sut = makeSUT(observer: observer)
        let observationTask = Task { await sut.observeLocation() }
        defer { observationTask.cancel() }
        await waitUntil { observer.isObserved }

        observer.fail(.authorizationDenied)
        await waitUntil { sut.status == .authorizationDenied }

        sut.selectCoordinate(latitude: 43.32, longitude: 21.89)

        XCTAssertEqual(sut.status, .ready)
        XCTAssertEqual(sut.selectedLocation?.latitude, 43.32)
        XCTAssertEqual(sut.selectedLocation?.longitude, 21.89)
        XCTAssertEqual(sut.selectedLocation?.accuracy, 25)
        XCTAssertEqual(sut.selectedLocation?.altitude, 0)
    }

    func test_useCurrentLocationReplacesManualSelectionAndRecentersMap() async {
        let current = makeLocation(latitude: 45.26, longitude: 19.83, altitude: 82)
        let observer = FindingLocationObserverStub()
        let sut = makeSUT(observer: observer)
        let observationTask = Task { await sut.observeLocation() }
        defer { observationTask.cancel() }
        await waitUntil { observer.isObserved }
        observer.send(current)
        await waitUntil { sut.currentLocation == current }
        sut.selectCoordinate(latitude: 43.32, longitude: 21.89)

        sut.useCurrentLocation()

        XCTAssertEqual(sut.selectedLocation, current)
        XCTAssertEqual(sut.cameraTarget.latitude, current.latitude)
        XCTAssertEqual(sut.cameraTarget.longitude, current.longitude)
    }

    func test_confirmResolvesAltitudeBeforeReturningSelection() async {
        let initial = makeLocation(latitude: 44.78, longitude: 20.44, altitude: 0)
        var resolved = initial
        resolved.altitude = 321
        let resolver = FindingLocationResolverStub(result: resolved)
        let sut = makeSUT(
            initialLocation: initial,
            resolver: resolver
        )

        let receivedLocation = await sut.confirmSelection()

        XCTAssertEqual(resolver.receivedLocations, [initial])
        XCTAssertEqual(receivedLocation, resolved)
        XCTAssertFalse(sut.isResolvingAltitude)
    }

    private func makeSUT(
        initialLocation: FindingEditorLocation? = nil,
        observer: FindingLocationObserverStub = FindingLocationObserverStub(),
        resolver: FindingLocationResolverStub = FindingLocationResolverStub()
    ) -> FindingLocationViewModel {
        FindingLocationViewModel(
            initialLocation: initialLocation,
            useCases: FindingLocationUseCases(
                observeCurrentLocation: observer,
                resolveLocation: resolver
            )
        )
    }

    private func makeLocation(
        latitude: Double,
        longitude: Double,
        altitude: Double
    ) -> FindingEditorLocation {
        FindingEditorLocation(
            latitude: latitude,
            longitude: longitude,
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

private final class FindingLocationObserverStub: ObserveCurrentFindingLocationUseCase {
    private var continuation: AsyncStream<FindingCurrentLocationEvent>.Continuation?
    private(set) var isObserved = false
    private(set) var terminationCount = 0

    func execute() async -> AsyncStream<FindingCurrentLocationEvent> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

            self.continuation = continuation
            isObserved = true
            continuation.onTermination = { [weak self] _ in
                self?.continuation = nil
                self?.terminationCount += 1
            }
        }
    }

    func send(_ location: FindingEditorLocation) {
        continuation?.yield(.location(location))
    }

    func fail(_ error: FindingLocationRepositoryError) {
        continuation?.yield(.failure(error))
    }
}

private final class FindingLocationResolverStub: ResolveFindingLocationUseCase {
    let result: FindingEditorLocation?
    private(set) var receivedLocations: [FindingEditorLocation] = []

    init(result: FindingEditorLocation? = nil) {
        self.result = result
    }

    func execute(_ location: FindingEditorLocation) async -> FindingEditorLocation {
        receivedLocations.append(location)
        return result ?? location
    }
}
