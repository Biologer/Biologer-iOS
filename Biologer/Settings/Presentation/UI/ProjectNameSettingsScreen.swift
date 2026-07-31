import SwiftUI

struct ProjectNameSettingsScreen: View {
    @StateObject private var viewModel: ProjectNameSettingsViewModel
    @FocusState private var isProjectNameFocused: Bool
    let onSaved: Observer<Void>

    init(
        viewModel: ProjectNameSettingsViewModel,
        onSaved: @escaping Observer<Void>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSaved = onSaved
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SettingsIconBadge(
                    systemImage: "folder.fill",
                    size: 68
                )
                .padding(.top, 18)

                VStack(alignment: .leading, spacing: 12) {
                    SettingsSectionHeader(
                        title: "Settings.lb.projectName.title".localized,
                        systemImage: "pencil"
                    )

                    TextField(
                        "ProjectName.tf.placeholder".localized,
                        text: $viewModel.projectName
                    )
                    .focused($isProjectNameFocused)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled(false)
                    .submitLabel(.done)
                    .foregroundColor(SettingsColorPalette.primaryText)
                    .padding(.horizontal, 16)
                    .frame(minHeight: 52)
                    .background(
                        SettingsColorPalette.pageBackground,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isProjectNameFocused
                                    ? SettingsColorPalette.primary
                                    : SettingsColorPalette.forest.opacity(0.14),
                                lineWidth: isProjectNameFocused ? 1.5 : 1
                            )
                    }
                    .onSubmit(save)
                }
                .padding(18)
                .settingsCard()

                Button(action: save) {
                    Label("Common.btn.ok".localized, systemImage: "checkmark")
                }
                .buttonStyle(
                    SettingsActionButtonStyle(
                        tint: SettingsColorPalette.primary
                    )
                )

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .settingsPageBackground()
        .navigationTitle("Settings.lb.projectName.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .tint(SettingsColorPalette.primary)
    }

    private func save() {
        viewModel.save()
        onSaved(())
    }
}
