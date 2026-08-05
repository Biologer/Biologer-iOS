import Foundation

enum FindingLocationDetailsMapStyle: String, CaseIterable, Identifiable {
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

@MainActor
final class FindingLocationDetailsViewModel: ObservableObject {
    let location: FindingDetailsLocation
    @Published var mapStyle: FindingLocationDetailsMapStyle = .standard

    init(location: FindingDetailsLocation) {
        self.location = location
    }
}
