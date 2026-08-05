import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsScreenViewModel
    let onSelectDestination: Observer<SettingsDestination>
    let onDownloadTaxa: Observer<Void>

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 22) {
                projectOverview

                settingsSection(
                    title: "Settings.lb.dataEntry".localized,
                    systemImage: "slider.horizontal.3"
                ) {
                    toggleRow(
                        title: "Settings.lb.awayListEnglish.title".localized,
                        systemImage: "character.book.closed",
                        isOn: Binding(
                            get: { viewModel.preferences.alwaysUseEnglishNames },
                            set: viewModel.setEnglishNamesEnabled
                        )
                    )

                    rowDivider

                    toggleRow(
                        title: "Settings.lb.adultDefault.title".localized,
                        systemImage: "leaf",
                        isOn: Binding(
                            get: { viewModel.preferences.defaultsToAdult },
                            set: viewModel.setAdultByDefaultEnabled
                        )
                    )
                }

                settingsSection(
                    title: "Settings.lb.userAccount".localized,
                    systemImage: "person.crop.circle"
                ) {
                    destinationRow(
                        title: "Settings.lb.projectName.title".localized,
                        systemImage: "folder",
                        destination: .projectName
                    )

                    rowDivider

                    destinationRow(
                        title: "Settings.lb.dataLicense.title".localized,
                        systemImage: "doc.text",
                        destination: .license(.data)
                    )

                    rowDivider

                    destinationRow(
                        title: "Settings.lb.imageLicense.title".localized,
                        systemImage: "photo",
                        destination: .license(.image)
                    )
                }

                settingsSection(
                    title: "Settings.lb.otherDownloads".localized,
                    systemImage: "arrow.down.circle"
                ) {
                    destinationRow(
                        title: "Settings.lb.autoDownloadUpload.title".localized,
                        systemImage: "arrow.triangle.2.circlepath",
                        destination: .automaticDownload
                    )

                    rowDivider

                    actionRow(
                        title: "Settings.lb.downloadTaxa.title".localized,
                        systemImage: "arrow.down.to.line",
                        action: { onSelectDestination(.taxonSync) }
                    )

                    rowDivider

                    actionRow(
                        title: "Settings.lb.resetAllTaxa.title".localized,
                        systemImage: "trash",
                        tint: .red,
                        titleColor: .red,
                        iconBackground: Color.red.opacity(0.1),
                        role: .destructive,
                        action: viewModel.requestTaxaReset
                    )
                }

                settingsSection(
                    title: "Settings.section.support".localized,
                    systemImage: "questionmark.circle"
                ) {
                    destinationRow(
                        title: "SideMenu.lb.Help".localized,
                        systemImage: "questionmark.circle",
                        destination: .help
                    )

                    rowDivider

                    destinationRow(
                        title: "SideMenu.lb.aboutUs".localized,
                        systemImage: "info.circle",
                        destination: .about
                    )

                    rowDivider

                    destinationRow(
                        title: "Settings.lb.userAccount".localized,
                        systemImage: "person.crop.circle",
                        destination: .account
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .biologerPageBackground()
        .navigationTitle("SideMenu.lb.setup".localized)
        .navigationBarTitleDisplayMode(.large)
        .tint(BiologerColors.accent)
        .onAppear(perform: viewModel.reload)
        .alert(item: $viewModel.resetAlert) { alert in
            makeAlert(alert)
        }
    }

    private var projectOverview: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 54, height: 54)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Settings.lb.projectName.title".localized.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.78))
                    .tracking(0.6)

                Text(projectName)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Image(systemName: "gearshape.fill")
                .font(.system(size: 44, weight: .light))
                .foregroundColor(.white.opacity(0.18))
        }
        .padding(20)
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
        .accessibilityElement(children: .combine)
    }

    private var projectName: String {
        let name = viewModel.preferences.projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "-" : name
    }

    private func settingsSection<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            BiologerSectionHeader(title: title, systemImage: systemImage)

            VStack(spacing: 0) {
                content()
            }
            .biologerCard()
        }
    }

    private func toggleRow(
        title: String,
        systemImage: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            rowLabel(
                title: title,
                systemImage: systemImage,
                tint: BiologerColors.accent
            )
        }
        .tint(BiologerColors.accent)
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    private func destinationRow(
        title: String,
        systemImage: String,
        destination: SettingsDestination
    ) -> some View {
        Button(action: { onSelectDestination(destination) }) {
            HStack(spacing: 12) {
                rowLabel(
                    title: title,
                    systemImage: systemImage,
                    tint: BiologerColors.accent
                )

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }

    private func actionRow(
        title: String,
        systemImage: String,
        tint: Color = BiologerColors.accent,
        titleColor: Color = BiologerColors.textPrimary,
        iconBackground: Color = BiologerColors.iconBackground,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            HStack(spacing: 12) {
                rowLabel(
                    title: title,
                    systemImage: systemImage,
                    tint: tint,
                    titleColor: titleColor,
                    iconBackground: iconBackground
                )

                Spacer(minLength: 8)
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }

    private func rowLabel(
        title: String,
        systemImage: String,
        tint: Color,
        titleColor: Color = BiologerColors.textPrimary,
        iconBackground: Color = BiologerColors.iconBackground
    ) -> some View {
        HStack(spacing: 12) {
            BiologerIconBadge(
                systemImage: systemImage,
                tint: tint,
                backgroundColor: iconBackground
            )

            Text(title)
                .font(.body)
                .foregroundColor(titleColor)
                .multilineTextAlignment(.leading)
        }
    }

    private var rowDivider: some View {
        Divider()
            .padding(.leading, 62)
    }

    private func makeAlert(_ alert: SettingsResetAlert) -> Alert {
        switch alert {
        case .confirmation:
            Alert(
                title: Text("Settings.lb.resetAllTaxa.yesOrNoAlert.title".localized),
                primaryButton: .destructive(Text("Common.btn.yes".localized)) {
                    viewModel.confirmTaxaReset()
                },
                secondaryButton: .cancel(Text("Common.btn.no".localized))
            )
        case .noDownloadedTaxa:
            Alert(
                title: Text("Settings.lb.resetAllTaxa.confirmAlert.whentTaxonEmpty.title".localized),
                message: Text("Settings.lb.resetAllTaxa.confirmAlert.whentTaxonEmpty.description".localized),
                dismissButton: .default(Text("Common.btn.ok".localized))
            )
        case .completed:
            Alert(
                title: Text("Settings.lb.resetAllTaxa.confirmAlert.title".localized),
                message: Text("Settings.lb.resetAllTaxa.confirmAlert.description".localized),
                dismissButton: .default(Text("Common.btn.ok".localized))
            )
        }
    }
}
