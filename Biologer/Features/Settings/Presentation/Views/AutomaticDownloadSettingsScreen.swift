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
        .biologerScreen(title: "DownloadAndUpload.nav.title".localized)
    }

    private func optionCard(_ option: AutomaticTaxonDownload) -> some View {
        let isSelected = viewModel.selectedOption == option

        return BiologerSelectionCard(
            title: viewModel.title(for: option),
            isSelected: isSelected,
            verticalAlignment: .center,
            titleFont: .body.weight(.medium),
            indicatorTopPadding: 0,
            action: { viewModel.select(option) }
        ) {
            BiologerIconBadge(
                systemImage: icon(for: option),
                tint: isSelected
                    ? BiologerColors.brandStrong
                    : BiologerColors.accent
            )
        }
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
