import SwiftUI

@MainActor
struct FindingLocationFlow: View {
    @StateObject private var viewModel: FindingLocationV2ViewModel

    init(
        initialLocation: FindingEditorLocation?,
        useCases: FindingLocationUseCases,
        onSelect: @escaping (FindingEditorLocation) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: FindingLocationV2ViewModel(
                initialLocation: initialLocation,
                useCases: useCases,
                onSelect: onSelect
            )
        )
    }

    var body: some View {
        FindingLocationScreenV2(viewModel: viewModel)
    }
}
