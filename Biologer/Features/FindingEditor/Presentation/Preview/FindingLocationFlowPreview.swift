import SwiftUI

struct FindingLocationFlow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FindingLocationFlow(
                initialLocation: FindingEditorLocation(
                    latitude: 44.78657,
                    longitude: 20.44892,
                    altitude: 284,
                    accuracy: 7.2
                ),
                useCases: FindingLocationUseCases(
                    observeCurrentLocation: LocationPreviewObserver(),
                    resolveLocation: LocationPreviewResolver()
                ),
                onSelect: { _ in }
            )
        }
        .previewDisplayName("Finding location")
    }
}

private final class LocationPreviewObserver: ObserveCurrentFindingLocationUseCase {
    func start(
        onLocation: @escaping (FindingEditorLocation) -> Void,
        onError: @escaping (FindingLocationRepositoryError) -> Void
    ) {}

    func stop() {}
}

private final class LocationPreviewResolver: ResolveFindingLocationUseCase {
    func execute(_ location: FindingEditorLocation) async -> FindingEditorLocation {
        location
    }
}
