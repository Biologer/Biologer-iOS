import SwiftUI

struct LicenseSettingsScreen: View {
    @ObservedObject private var viewModel: LicenseSettingsViewModel

    init(viewModel: LicenseSettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                BiologerIconBadge(
                    systemImage: headerIcon,
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
        .biologerScreen(title: viewModel.navigationTitle)
    }

    private var headerIcon: String {
        switch viewModel.kind {
        case .data:
            "doc.text.fill"
        case .image:
            "photo.fill"
        }
    }

    private func optionCard(_ option: LicenseOption) -> some View {
        let isSelected = viewModel.selectedOptionID == option.id

        return BiologerSelectionCard(
            title: option.title,
            subtitle: option.details,
            isSelected: isSelected,
            indicatorTopPadding: 6,
            action: { viewModel.select(option) }
        ) {
            BiologerIconBadge(
                systemImage: headerIcon,
                tint: isSelected
                    ? BiologerColors.brandStrong
                    : BiologerColors.accent
            )
        }
    }
}
