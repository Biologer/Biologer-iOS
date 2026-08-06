import SwiftUI

struct AutomaticDownloadSettingsScreen: View {
    @ObservedObject private var viewModel: AutomaticDownloadSettingsViewModel

    init(viewModel: AutomaticDownloadSettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                BiologerIconBadge(
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
        .biologerPageBackground()
        .navigationTitle("DownloadAndUpload.nav.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .tint(BiologerColors.accent)
    }

    private func optionCard(_ option: AutomaticTaxonDownload) -> some View {
        let isSelected = viewModel.selectedOption == option

        return Button(action: { viewModel.select(option) }) {
            HStack(spacing: 14) {
                BiologerIconBadge(
                    systemImage: icon(for: option),
                    tint: isSelected
                        ? BiologerColors.brandStrong
                        : BiologerColors.accent
                )

                Text(viewModel.title(for: option))
                    .font(.body.weight(.medium))
                    .foregroundColor(BiologerColors.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(
                        isSelected
                            ? BiologerColors.accent
                            : Color(uiColor: .tertiaryLabel)
                    )
            }
            .padding(16)
            .contentShape(Rectangle())
            .biologerCard(isSelected: isSelected)
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
