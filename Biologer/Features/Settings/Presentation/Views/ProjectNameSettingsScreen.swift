import SwiftUI

struct ProjectNameSettingsScreen: View {
    @ObservedObject private var viewModel: ProjectNameSettingsViewModel
    @FocusState private var isProjectNameFocused: Bool
    let onSaved: () -> Void

    init(
        viewModel: ProjectNameSettingsViewModel,
        onSaved: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onSaved = onSaved
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                BiologerIconBadge(
                    systemImage: "folder.fill",
                    size: 68
                )
                .padding(.top, 18)

                VStack(alignment: .leading, spacing: 12) {
                    BiologerSectionHeader(
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
                    .foregroundColor(BiologerColors.textPrimary)
                    .padding(.horizontal, 16)
                    .frame(minHeight: 52)
                    .background(
                        BiologerColors.pageBackground,
                        in: RoundedRectangle(
                            cornerRadius: BiologerRadius.control,
                            style: .continuous
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: BiologerRadius.control,
                            style: .continuous
                        )
                            .stroke(
                                isProjectNameFocused
                                    ? BiologerColors.accent
                                    : BiologerColors.brandStrong.opacity(0.14),
                                lineWidth: isProjectNameFocused ? 1.5 : 1
                            )
                    }
                    .onSubmit(save)
                }
                .padding(18)
                .biologerCard()

                Button(action: save) {
                    Label("Common.btn.ok".localized, systemImage: "checkmark")
                }
                .buttonStyle(
                    BiologerActionButtonStyle()
                )

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .biologerPageBackground()
        .navigationTitle("Settings.lb.projectName.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .tint(BiologerColors.accent)
    }

    private func save() {
        viewModel.save()
        onSaved()
    }
}
