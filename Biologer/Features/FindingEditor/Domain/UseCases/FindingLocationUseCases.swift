struct FindingLocationUseCases {
    let observeCurrentLocation: ObserveCurrentFindingLocationUseCase
    let resolveLocation: ResolveFindingLocationUseCase
}

enum FindingCurrentLocationEvent: Equatable {
    case location(FindingEditorLocation)
    case failure(FindingLocationRepositoryError)
}

protocol ObserveCurrentFindingLocationUseCase: AnyObject {
    func execute() -> AsyncStream<FindingCurrentLocationEvent>
}

final class DefaultObserveCurrentFindingLocationUseCase: ObserveCurrentFindingLocationUseCase {
    private let repository: FindingCurrentLocationRepository

    init(repository: FindingCurrentLocationRepository) {
        self.repository = repository
    }

    func execute() -> AsyncStream<FindingCurrentLocationEvent> {
        AsyncStream { [weak repository] continuation in
            guard let repository else {
                continuation.finish()
                return
            }

            continuation.onTermination = { [weak repository] _ in
                repository?.stop()
            }
            repository.start(
                onLocation: { continuation.yield(.location($0)) },
                onError: { continuation.yield(.failure($0)) }
            )
        }
    }
}

protocol ResolveFindingLocationUseCase {
    func execute(_ location: FindingEditorLocation) async -> FindingEditorLocation
}

final class DefaultResolveFindingLocationUseCase: ResolveFindingLocationUseCase {
    private let altitudeRepository: FindingAltitudeRepository

    init(altitudeRepository: FindingAltitudeRepository) {
        self.altitudeRepository = altitudeRepository
    }

    func execute(_ location: FindingEditorLocation) async -> FindingEditorLocation {
        do {
            let altitude = try await altitudeRepository.altitude(
                latitude: location.latitude,
                longitude: location.longitude
            )
            var resolvedLocation = location
            resolvedLocation.altitude = altitude
            return resolvedLocation
        } catch {
            return location
        }
    }
}
