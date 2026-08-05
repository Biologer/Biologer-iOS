import SwiftUI

@MainActor
struct FindingLocationFlow: View {
    @StateObject private var viewModel: FindingLocationViewModel

    init(
        initialLocation: FindingEditorLocation?,
        useCases: FindingLocationUseCases,
        onSelect: @escaping (FindingEditorLocation) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: FindingLocationViewModel(
                initialLocation: initialLocation,
                useCases: useCases,
                onSelect: onSelect
            )
        )
    }

    var body: some View {
        FindingLocationScreen(viewModel: viewModel)
    }
}
