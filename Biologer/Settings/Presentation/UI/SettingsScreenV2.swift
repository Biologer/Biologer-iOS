import SwiftUI

struct SettingsScreenV2: View {
    @ObservedObject var viewModel: SettingsScreenV2ViewModel
    let onSelectDestination: Observer<SettingsDestination>
    let onDownloadTaxa: Observer<Void>

    var body: some View {
        Form {
            Section(header: Text("Settings.lb.dataEntry".localized)) {
                Toggle(
                    "Settings.lb.awayListEnglish.title".localized,
                    isOn: Binding(
                        get: { viewModel.preferences.alwaysUseEnglishNames },
                        set: viewModel.setEnglishNamesEnabled
                    )
                )
                Toggle(
                    "Settings.lb.adultDefault.title".localized,
                    isOn: Binding(
                        get: { viewModel.preferences.defaultsToAdult },
                        set: viewModel.setAdultByDefaultEnabled
                    )
                )
            }

            Section(header: Text("Settings.lb.userAccount".localized)) {
                destinationRow(
                    title: "Settings.lb.projectName.title".localized,
                    systemImage: "folder",
                    destination: .projectName
                )
                destinationRow(
                    title: "Settings.lb.dataLicense.title".localized,
                    systemImage: "doc.text",
                    destination: .license(.data)
                )
                destinationRow(
                    title: "Settings.lb.imageLicense.title".localized,
                    systemImage: "photo",
                    destination: .license(.image)
                )
            }

            Section(header: Text("Settings.lb.otherDownloads".localized)) {
                destinationRow(
                    title: "Settings.lb.autoDownloadUpload.title".localized,
                    systemImage: "arrow.triangle.2.circlepath",
                    destination: .automaticDownload
                )
                actionRow(
                    title: "Settings.lb.downloadTaxa.title".localized,
                    systemImage: "arrow.down.circle",
                    action: { onDownloadTaxa(()) }
                )
                actionRow(
                    title: "Settings.lb.resetAllTaxa.title".localized,
                    systemImage: "trash",
                    role: .destructive,
                    action: viewModel.requestTaxaReset
                )
            }

            Section(header: Text("SettingsV2.section.support".localized)) {
                destinationRow(
                    title: "SideMenu.lb.Help".localized,
                    systemImage: "questionmark.circle",
                    destination: .help
                )
                destinationRow(
                    title: "SideMenu.lb.aboutUs".localized,
                    systemImage: "info.circle",
                    destination: .about
                )
                destinationRow(
                    title: "Settings.lb.userAccount".localized,
                    systemImage: "person.crop.circle",
                    destination: .account
                )
            }
        }
        .navigationTitle("SideMenu.lb.setup".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.reload)
        .alert(item: $viewModel.resetAlert) { alert in
            makeAlert(alert)
        }
    }

    private func destinationRow(
        title: String,
        systemImage: String,
        destination: SettingsDestination
    ) -> some View {
        Button(action: { onSelectDestination(destination) }) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(.primary)
    }

    private func actionRow(
        title: String,
        systemImage: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
        }
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
