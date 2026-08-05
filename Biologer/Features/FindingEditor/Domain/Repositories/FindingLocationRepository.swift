import Foundation

enum FindingLocationRepositoryError: Error, Equatable {
    case authorizationDenied
    case locationUnavailable
}

enum FindingAltitudeRepositoryError: Error, Equatable {
    case environmentUnavailable
    case altitudeUnavailable
}

protocol FindingCurrentLocationRepository: AnyObject {
    func start(
        onLocation: @escaping (FindingEditorLocation) -> Void,
        onError: @escaping (FindingLocationRepositoryError) -> Void
    )

    func stop()
}

protocol FindingAltitudeRepository {
    func altitude(
        latitude: Double,
        longitude: Double
    ) async throws(FindingAltitudeRepositoryError) -> Double
}
