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

@MainActor
final class FindingLocationDetailsViewModel: ObservableObject {
    let location: FindingDetailsLocation
    @Published var mapStyle: FindingLocationDetailsMapStyle = .standard

    init(location: FindingDetailsLocation) {
        self.location = location
    }
}
