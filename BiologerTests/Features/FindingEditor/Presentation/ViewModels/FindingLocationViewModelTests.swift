import XCTest
@testable import Biologer

@MainActor
final class FindingLocationViewModelTests: XCTestCase {
    func test_startSelectsFirstCurrentLocationAndStopEndsObservation() async {
        let current = makeLocation(latitude: 44.8, longitude: 20.4, altitude: 120)
        let observer = FindingLocationObserverStub()
        let sut = makeSUT(observer: observer)

        sut.start()
        observer.send(current)
        await Task.yield()
        sut.stop()

        XCTAssertEqual(sut.selectedLocation, current)
        XCTAssertEqual(sut.currentLocation, current)
        XCTAssertEqual(sut.status, .ready)
        XCTAssertEqual(sut.cameraTarget.latitude, current.latitude)
        XCTAssertEqual(sut.cameraTarget.longitude, current.longitude)
        XCTAssertEqual(observer.stopCallCount, 1)
    }

    func test_manualSelectionRemainsAvailableWhenAuthorizationIsDenied() async {
        let observer = FindingLocationObserverStub()
        let sut = makeSUT(observer: observer)

        sut.start()
        observer.fail(.authorizationDenied)
        await Task.yield()
        XCTAssertEqual(sut.status, .authorizationDenied)

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
        sut.start()
        observer.send(current)
        await Task.yield()
        sut.selectCoordinate(latitude: 43.32, longitude: 21.89)

        sut.useCurrentLocation()

        XCTAssertEqual(sut.selectedLocation, current)
        XCTAssertEqual(sut.cameraTarget.latitude, current.latitude)
        XCTAssertEqual(sut.cameraTarget.longitude, current.longitude)
    }

    func test_confirmResolvesAltitudeBeforeForwardingSelection() async {
        let initial = makeLocation(latitude: 44.78, longitude: 20.44, altitude: 0)
        var resolved = initial
        resolved.altitude = 321
        let resolver = FindingLocationResolverStub(result: resolved)
        let selected = expectation(description: "location selected")
        var receivedLocation: FindingEditorLocation?
        let sut = makeSUT(
            initialLocation: initial,
            resolver: resolver,
            onSelect: {
                receivedLocation = $0
                selected.fulfill()
            }
        )

        sut.confirmSelection()

        await fulfillment(of: [selected], timeout: 1)
        XCTAssertEqual(resolver.receivedLocations, [initial])
        XCTAssertEqual(receivedLocation, resolved)
        XCTAssertFalse(sut.isResolvingAltitude)
    }

    private func makeSUT(
        initialLocation: FindingEditorLocation? = nil,
        observer: FindingLocationObserverStub = FindingLocationObserverStub(),
        resolver: FindingLocationResolverStub = FindingLocationResolverStub(),
        onSelect: @escaping (FindingEditorLocation) -> Void = { _ in }
    ) -> FindingLocationViewModel {
        FindingLocationViewModel(
            initialLocation: initialLocation,
            useCases: FindingLocationUseCases(
                observeCurrentLocation: observer,
                resolveLocation: resolver
            ),
            onSelect: onSelect
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
}

private final class FindingLocationObserverStub: ObserveCurrentFindingLocationUseCase {
    private var onLocation: ((FindingEditorLocation) -> Void)?
    private var onError: ((FindingLocationRepositoryError) -> Void)?
    private(set) var stopCallCount = 0

    func start(
        onLocation: @escaping (FindingEditorLocation) -> Void,
        onError: @escaping (FindingLocationRepositoryError) -> Void
    ) {
        self.onLocation = onLocation
        self.onError = onError
    }

    func stop() {
        stopCallCount += 1
    }

    func send(_ location: FindingEditorLocation) {
        onLocation?(location)
    }

    func fail(_ error: FindingLocationRepositoryError) {
        onError?(error)
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
