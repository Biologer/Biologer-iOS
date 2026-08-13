struct FindingLocationUseCases {
    let observeCurrentLocation: ObserveCurrentFindingLocationUseCase
    let resolveLocation: ResolveFindingLocationUseCase
}

enum FindingCurrentLocationEvent: Equatable {
    case location(FindingEditorLocation)
    case failure(FindingLocationRepositoryError)
}

protocol ObserveCurrentFindingLocationUseCase: AnyObject {
    func execute() async -> AsyncStream<FindingCurrentLocationEvent>
}

final class DefaultObserveCurrentFindingLocationUseCase: ObserveCurrentFindingLocationUseCase {
    private let repository: FindingCurrentLocationRepository

    init(repository: FindingCurrentLocationRepository) {
        self.repository = repository
    }

    func execute() async -> AsyncStream<FindingCurrentLocationEvent> {
        let (stream, continuation) = AsyncStream.makeStream(
            of: FindingCurrentLocationEvent.self
        )

        continuation.onTermination = { [weak repository] _ in
            Task {
                await repository?.stop()
            }
        }

        await repository.start(
            onLocation: { continuation.yield(.location($0)) },
            onError: { continuation.yield(.failure($0)) }
        )
        return stream
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
