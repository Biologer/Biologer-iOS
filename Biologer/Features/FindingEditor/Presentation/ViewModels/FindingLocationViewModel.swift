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
            "NewTaxon.mapType.normal.title".localized
        case .hybrid:
            "NewTaxon.mapType.hybrid.title".localized
        case .terrain:
            "NewTaxon.mapType.terrain.title".localized
        case .satellite:
            "NewTaxon.mapType.satellite.title".localized
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
    private let onSelect: (FindingEditorLocation) -> Void
    private var didStart = false
    private var resolveTask: Task<Void, Never>?

    init(
        initialLocation: FindingEditorLocation?,
        useCases: FindingLocationUseCases,
        onSelect: @escaping (FindingEditorLocation) -> Void
    ) {
        selectedLocation = initialLocation
        status = initialLocation == nil ? .idle : .ready
        cameraTarget = FindingLocationCameraTarget(
            latitude: initialLocation?.latitude ?? 44.0165,
            longitude: initialLocation?.longitude ?? 21.0059
        )
        observeCurrentLocation = useCases.observeCurrentLocation
        resolveLocation = useCases.resolveLocation
        self.onSelect = onSelect
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
        resolveTask?.cancel()
        resolveTask = nil
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

    func confirmSelection() {
        guard let selectedLocation, !isResolvingAltitude else { return }
        isResolvingAltitude = true
        resolveTask?.cancel()
        resolveTask = Task { [weak self] in
            guard let self else { return }
            let resolvedLocation = await resolveLocation.execute(selectedLocation)
            guard !Task.isCancelled else { return }
            isResolvingAltitude = false
            onSelect(resolvedLocation)
        }
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
