import SwiftUI

struct FindingLocationDetailsFlow: View {
    @StateObject private var viewModel: FindingLocationDetailsViewModel

    init(location: FindingDetailsLocation) {
        _viewModel = StateObject(
            wrappedValue: FindingLocationDetailsViewModel(
                location: location
            )
        )
    }

    var body: some View {
        FindingLocationDetailsScreen(viewModel: viewModel)
    }
}
