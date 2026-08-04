import SwiftUI

struct FindingLocationDetailsFlow: View {
    @StateObject private var viewModel: FindingLocationDetailsV2ViewModel

    init(location: FindingDetailsLocation) {
        _viewModel = StateObject(
            wrappedValue: FindingLocationDetailsV2ViewModel(
                location: location
            )
        )
    }

    var body: some View {
        FindingLocationDetailsScreenV2(viewModel: viewModel)
    }
}
