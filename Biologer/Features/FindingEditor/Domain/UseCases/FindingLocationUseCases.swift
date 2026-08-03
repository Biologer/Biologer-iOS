struct FindingLocationUseCases {
    let observeCurrentLocation: ObserveCurrentFindingLocationUseCase
    let resolveLocation: ResolveFindingLocationUseCase
}

protocol ObserveCurrentFindingLocationUseCase: AnyObject {
    func start(
        onLocation: @escaping (FindingEditorLocation) -> Void,
        onError: @escaping (FindingLocationRepositoryError) -> Void
    )

    func stop()
}

final class DefaultObserveCurrentFindingLocationUseCase: ObserveCurrentFindingLocationUseCase {
    private let repository: FindingCurrentLocationRepository

    init(repository: FindingCurrentLocationRepository) {
        self.repository = repository
    }

    func start(
        onLocation: @escaping (FindingEditorLocation) -> Void,
        onError: @escaping (FindingLocationRepositoryError) -> Void
    ) {
        repository.start(onLocation: onLocation, onError: onError)
    }

    func stop() {
        repository.stop()
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
