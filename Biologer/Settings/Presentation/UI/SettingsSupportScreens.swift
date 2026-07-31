import SwiftUI

struct SettingsHelpScreen: View {
    @StateObject private var viewModel: HelpScreenViewModel
    let onBack: Observer<Void>

    init(onBack: @escaping Observer<Void>) {
        self.onBack = onBack
        _viewModel = StateObject(
            wrappedValue: HelpScreenViewModel(onDone: onBack)
        )
    }

    var body: some View {
        VStack(spacing: 18) {
            TabView(selection: $viewModel.currentPageIndex) {
                ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                    helpCard(item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentPageIndex)

            HStack(spacing: 20) {
                navigationButton(
                    systemImage: "chevron.left",
                    action: viewModel.previousTapped
                )
                .disabled(viewModel.currentPageIndex == 0)
                .opacity(viewModel.currentPageIndex == 0 ? 0.35 : 1)

                Text(pageIndicator)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(SettingsColorPalette.sectionTitle)
                    .monospacedDigit()
                    .frame(minWidth: 64)

                navigationButton(
                    systemImage: isLastPage ? "checkmark" : "chevron.right",
                    action: viewModel.nextTapped
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .settingsPageBackground()
        .navigationTitle("SideMenu.lb.Help".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .tint(SettingsColorPalette.primary)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { onBack(()) }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }

    private var isLastPage: Bool {
        viewModel.currentPageIndex == viewModel.items.count - 1
    }

    private var pageIndicator: String {
        guard !viewModel.items.isEmpty else { return "0 / 0" }
        return "\(viewModel.currentPageIndex + 1) / \(viewModel.items.count)"
    }

    private func helpCard(_ item: HelpItemViewModel) -> some View {
        VStack(spacing: 22) {
            Spacer(minLength: 12)

            Image(item.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 260, maxHeight: 260)

            VStack(spacing: 10) {
                Text(item.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(SettingsColorPalette.primaryText)
                    .multilineTextAlignment(.center)

                Text(item.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
        .settingsCard(cornerRadius: 24)
        .padding(.vertical, 4)
    }

    private func navigationButton(
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    SettingsColorPalette.primary,
                    in: Circle()
                )
                .shadow(
                    color: SettingsColorPalette.forest.opacity(0.2),
                    radius: 7,
                    y: 3
                )
        }
        .buttonStyle(.plain)
    }
}

struct SettingsAboutScreen: View {
    @StateObject private var viewModel: AboutBiologerScreenViewModel
    let onBack: Observer<Void>

    init(
        environment: String,
        version: String,
        onOpenURL: @escaping Observer<String>,
        onBack: @escaping Observer<Void>
    ) {
        self.onBack = onBack
        _viewModel = StateObject(
            wrappedValue: AboutBiologerScreenViewModel(
                currentEnv: environment,
                version: version,
                onEnvTapped: onOpenURL
            )
        )
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
                .settingsCard()

                VStack(spacing: 14) {
                    Text(viewModel.descriptionThree)
                        .font(.body)
                        .foregroundColor(SettingsColorPalette.primaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Button(action: viewModel.envTapped) {
                        Label(viewModel.envButtonTitle, systemImage: "safari")
                    }
                    .buttonStyle(
                        SettingsActionButtonStyle(
                            tint: SettingsColorPalette.primary,
                            isFilled: false
                        )
                    )
                }
                .padding(18)
                .settingsCard()

                Text(viewModel.version)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(SettingsColorPalette.sectionTitle)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        SettingsColorPalette.iconBackground,
                        in: Capsule()
                    )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .settingsPageBackground()
        .navigationTitle("SideMenu.lb.aboutUs".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .tint(SettingsColorPalette.primary)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { onBack(()) }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }

    private var brandHeader: some View {
        VStack(spacing: 14) {
            Image(viewModel.topImge)
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
                    SettingsColorPalette.forest,
                    SettingsColorPalette.primary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .shadow(color: SettingsColorPalette.forest.opacity(0.24), radius: 12, y: 6)
    }

    private var databaseCard: some View {
        HStack(alignment: .top, spacing: 14) {
            SettingsIconBadge(systemImage: "server.rack")

            VStack(alignment: .leading, spacing: 7) {
                Text(viewModel.currentDbDescription)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                Text(viewModel.currentEnv)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(SettingsColorPalette.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .settingsCard()
    }

    private func descriptionRow(
        _ description: String,
        systemImage: String
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            SettingsIconBadge(systemImage: systemImage)

            Text(description)
                .font(.body)
                .foregroundColor(SettingsColorPalette.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(16)
    }
}
