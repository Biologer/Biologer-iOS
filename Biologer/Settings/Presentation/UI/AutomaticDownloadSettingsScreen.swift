import SwiftUI

struct AutomaticDownloadSettingsScreen: View {
    @StateObject private var viewModel: AutomaticDownloadSettingsViewModel

    init(viewModel: AutomaticDownloadSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.options) { option in
            Button(action: { viewModel.select(option) }) {
                HStack {
                    Text(viewModel.title(for: option))
                    Spacer()
                    if viewModel.selectedOption == option {
                        Image(systemName: "checkmark")
                            .foregroundColor(.biologerGreenColor)
                    }
                }
            }
            .foregroundColor(.primary)
        }
        .navigationTitle("DownloadAndUpload.nav.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}
