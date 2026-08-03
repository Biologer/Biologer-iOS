import Foundation

enum FindingLocationRepositoryError: Error, Equatable {
    case authorizationDenied
    case locationUnavailable
}

protocol FindingCurrentLocationRepository: AnyObject {
    func start(
        onLocation: @escaping (FindingEditorLocation) -> Void,
        onError: @escaping (FindingLocationRepositoryError) -> Void
    )

    func stop()
}

protocol FindingAltitudeRepository {
    func altitude(latitude: Double, longitude: Double) async throws -> Double
}
