import SwiftUI

struct AutomaticDownloadSettingsScreen: View {
    @StateObject private var viewModel: AutomaticDownloadSettingsViewModel

    init(viewModel: AutomaticDownloadSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                SettingsIconBadge(
                    systemImage: "arrow.triangle.2.circlepath",
                    size: 64
                )
                .padding(.vertical, 10)

                ForEach(viewModel.options) { option in
                    optionCard(option)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .settingsPageBackground()
        .navigationTitle("DownloadAndUpload.nav.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .tint(SettingsColorPalette.primary)
    }

    private func optionCard(_ option: AutomaticTaxonDownload) -> some View {
        let isSelected = viewModel.selectedOption == option

        return Button(action: { viewModel.select(option) }) {
            HStack(spacing: 14) {
                SettingsIconBadge(
                    systemImage: icon(for: option),
                    tint: isSelected
                        ? SettingsColorPalette.forest
                        : SettingsColorPalette.primary
                )

                Text(viewModel.title(for: option))
                    .font(.body.weight(.medium))
                    .foregroundColor(SettingsColorPalette.primaryText)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(
                        isSelected
                            ? SettingsColorPalette.primary
                            : Color(uiColor: .tertiaryLabel)
                    )
            }
            .padding(16)
            .contentShape(Rectangle())
            .settingsCard(isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }

    private func icon(for option: AutomaticTaxonDownload) -> String {
        switch option {
        case .onlyWiFi:
            "wifi"
        case .onAnyNetwork:
            "antenna.radiowaves.left.and.right"
        case .alwaysAskUser:
            "questionmark.bubble"
        }
    }
}
