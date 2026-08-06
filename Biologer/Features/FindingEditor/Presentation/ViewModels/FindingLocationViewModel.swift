import Foundation

enum FindingLocationStatus: Equatable {
    case idle
    case locating
    case ready
    case authorizationDenied
    case unavailable
}

enum FindingLocationMapStyle: String, CaseIterable, Identifiable {
    case standard
    case hybrid
    case terrain
    case satellite

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .standard:
            "Finding.mapType.normal".localized
        case .hybrid:
            "Finding.mapType.hybrid".localized
        case .terrain:
            "Finding.mapType.terrain".localized
        case .satellite:
            "Finding.mapType.satellite".localized
        }
    }
}

struct FindingLocationCameraTarget: Equatable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
}

@MainActor
final class FindingLocationViewModel: ObservableObject {
    @Published private(set) var selectedLocation: FindingEditorLocation?
    @Published private(set) var currentLocation: FindingEditorLocation?
    @Published private(set) var cameraTarget: FindingLocationCameraTarget
    @Published private(set) var status: FindingLocationStatus
    @Published private(set) var isResolvingAltitude = false
    @Published var mapStyle: FindingLocationMapStyle = .standard

    private let observeCurrentLocation: ObserveCurrentFindingLocationUseCase
    private let resolveLocation: ResolveFindingLocationUseCase
    private var didStart = false

    init(
        initialLocation: FindingEditorLocation?,
        useCases: FindingLocationUseCases
    ) {
        selectedLocation = initialLocation
        status = initialLocation == nil ? .idle : .ready
        cameraTarget = FindingLocationCameraTarget(
            latitude: initialLocation?.latitude ?? 44.0165,
            longitude: initialLocation?.longitude ?? 21.0059
        )
        observeCurrentLocation = useCases.observeCurrentLocation
        resolveLocation = useCases.resolveLocation
    }

    var canConfirm: Bool {
        selectedLocation != nil && !isResolvingAltitude
    }

    func start() {
        guard !didStart else { return }
        didStart = true
        if selectedLocation == nil {
            status = .locating
        }

        observeCurrentLocation.start(
            onLocation: { [weak self] location in
                Task { @MainActor in
                    self?.receiveCurrentLocation(location)
                }
            },
            onError: { [weak self] error in
                Task { @MainActor in
                    self?.receiveLocationError(error)
                }
            }
        )
    }

    func stop() {
        observeCurrentLocation.stop()
        isResolvingAltitude = false
        didStart = false
    }

    func selectCoordinate(latitude: Double, longitude: Double) {
        selectedLocation = FindingEditorLocation(
            latitude: latitude,
            longitude: longitude,
            altitude: 0,
            accuracy: 25
        )
        status = .ready
    }

    func useCurrentLocation() {
        guard let currentLocation else {
            status = .locating
            return
        }

        selectedLocation = currentLocation
        cameraTarget = FindingLocationCameraTarget(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude
        )
        status = .ready
    }

    func confirmSelection() async -> FindingEditorLocation? {
        guard let selectedLocation, !isResolvingAltitude else { return nil }
        isResolvingAltitude = true
        defer { isResolvingAltitude = false }

        let resolvedLocation = await resolveLocation.execute(selectedLocation)
        guard !Task.isCancelled else { return nil }
        return resolvedLocation
    }

    private func receiveCurrentLocation(_ location: FindingEditorLocation) {
        currentLocation = location
        guard selectedLocation == nil else { return }

        selectedLocation = location
        cameraTarget = FindingLocationCameraTarget(
            latitude: location.latitude,
            longitude: location.longitude
        )
        status = .ready
    }

    private func receiveLocationError(_ error: FindingLocationRepositoryError) {
        switch error {
        case .authorizationDenied:
            status = .authorizationDenied
        case .locationUnavailable:
            status = .unavailable
        }
    }
}
