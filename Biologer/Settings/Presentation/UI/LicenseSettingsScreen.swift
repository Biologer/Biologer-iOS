import SwiftUI

struct LicenseSettingsScreen: View {
    @StateObject private var viewModel: LicenseSettingsViewModel

    init(viewModel: LicenseSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.options) { option in
            Button(action: { viewModel.select(option) }) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.title)
                            .font(.body.weight(.medium))
                        Text(option.details)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if viewModel.selectedOptionID == option.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.biologerGreenColor)
                    }
                }
            }
            .foregroundColor(.primary)
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
