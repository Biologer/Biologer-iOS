import SwiftUI

struct LicenseSettingsScreen: View {
    @StateObject private var viewModel: LicenseSettingsViewModel

    init(viewModel: LicenseSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                SettingsIconBadge(
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
        .settingsPageBackground()
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .tint(SettingsColorPalette.primary)
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
                SettingsIconBadge(
                    systemImage: headerIcon,
                    tint: isSelected
                        ? SettingsColorPalette.forest
                        : SettingsColorPalette.primary
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(option.title)
                        .font(.body.weight(.semibold))
                        .foregroundColor(SettingsColorPalette.primaryText)
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
                            ? SettingsColorPalette.primary
                            : Color(uiColor: .tertiaryLabel)
                    )
                    .padding(.top, 6)
            }
            .padding(16)
            .contentShape(Rectangle())
            .settingsCard(isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }
}
