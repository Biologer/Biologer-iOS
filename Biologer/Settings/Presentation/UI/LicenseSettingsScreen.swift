import SwiftUI

struct LicenseSettingsScreen: View {
    @StateObject private var viewModel: LicenseSettingsViewModel

    init(viewModel: LicenseSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
        .biologerPageBackground()
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .tint(BiologerColors.accent)
    }

    private var headerIcon: String {
        switch viewModel.kind {
        case .data:
            "doc.text.fill"
        case .image:
            "photo.fill"
        }
    }

    private func optionCard(_ option: SettingsLicenseOption) -> some View {
        let isSelected = viewModel.selectedOptionID == option.id

        return Button(action: { viewModel.select(option) }) {
            HStack(alignment: .top, spacing: 14) {
                BiologerIconBadge(
                    systemImage: headerIcon,
                    tint: isSelected
                        ? BiologerColors.brandStrong
                        : BiologerColors.accent
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(option.title)
                        .font(.body.weight(.semibold))
                        .foregroundColor(BiologerColors.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(option.details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(
                        isSelected
                            ? BiologerColors.accent
                            : Color(uiColor: .tertiaryLabel)
                    )
                    .padding(.top, 6)
            }
            .padding(16)
            .contentShape(Rectangle())
            .biologerCard(isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }
}
