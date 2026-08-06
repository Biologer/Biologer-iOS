import SwiftUI

struct SettingsAboutScreen: View {
    @SwiftUI.Environment(\.openURL) private var openURL
    @ObservedObject private var viewModel: SettingsAboutViewModel
    let onBack: () -> Void

    init(
        viewModel: SettingsAboutViewModel,
        onBack: @escaping () -> Void
    ) {
        self.onBack = onBack
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                brandHeader

                databaseCard

                VStack(spacing: 0) {
                    descriptionRow(
                        viewModel.descriptionOne,
                        systemImage: "leaf.fill"
                    )

                    Divider()
                        .padding(.leading, 62)

                    descriptionRow(
                        viewModel.descriptionTwo,
                        systemImage: "heart.fill"
                    )
                }
                .biologerCard()

                VStack(spacing: 14) {
                    Text(viewModel.descriptionThree)
                        .font(.body)
                        .foregroundColor(BiologerColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Button(action: openEnvironment) {
                        Label(viewModel.environment, systemImage: "safari")
                    }
                    .buttonStyle(
                        BiologerActionButtonStyle(
                            isFilled: false
                        )
                    )
                }
                .padding(18)
                .biologerCard()

                Text(viewModel.version)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(BiologerColors.sectionTitle)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        BiologerColors.iconBackground,
                        in: Capsule()
                    )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .biologerPageBackground()
        .biologerNavigationBar(
            title: "Settings.support.about".localized,
            onBack: onBack
        )
    }

    private var brandHeader: some View {
        VStack(spacing: 14) {
            Image(viewModel.logoImageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 250, maxHeight: 78)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))

            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(
            LinearGradient(
                colors: [
                    BiologerColors.brandStrong,
                    BiologerColors.accent
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(
                cornerRadius: BiologerRadius.hero,
                style: .continuous
            )
        )
        .shadow(color: BiologerColors.brandStrong.opacity(0.24), radius: 12, y: 6)
    }

    private var databaseCard: some View {
        HStack(alignment: .top, spacing: 14) {
            BiologerIconBadge(systemImage: "server.rack")

            VStack(alignment: .leading, spacing: 7) {
                Text(viewModel.currentDatabaseDescription)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                Text(viewModel.environment)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(BiologerColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .biologerCard()
    }

    private func descriptionRow(
        _ description: String,
        systemImage: String
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            BiologerIconBadge(systemImage: systemImage)

            Text(description)
                .font(.body)
                .foregroundColor(BiologerColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(16)
    }

    private func openEnvironment() {
        guard let url = viewModel.environmentURL else { return }
        openURL(url)
    }
}
