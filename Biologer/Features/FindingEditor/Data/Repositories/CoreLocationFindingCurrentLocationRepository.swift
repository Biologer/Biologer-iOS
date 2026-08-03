import CoreLocation

final class CoreLocationFindingCurrentLocationRepository: NSObject,
    FindingCurrentLocationRepository {
    private let manager: CLLocationManager
    private var onLocation: ((FindingEditorLocation) -> Void)?
    private var onError: ((FindingLocationRepositoryError) -> Void)?

    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func start(
        onLocation: @escaping (FindingEditorLocation) -> Void,
        onError: @escaping (FindingLocationRepositoryError) -> Void
    ) {
        self.onLocation = onLocation
        self.onError = onError

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            onError(.authorizationDenied)
        @unknown default:
            onError(.locationUnavailable)
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
        onLocation = nil
        onError = nil
    }
}

extension CoreLocationFindingCurrentLocationRepository: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            onError?(.authorizationDenied)
        case .notDetermined:
            break
        @unknown default:
            onError?(.locationUnavailable)
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else {
            return
        }

        onLocation?(
            FindingEditorLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                accuracy: location.horizontalAccuracy
            )
        )
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError?(.locationUnavailable)
    }
}
