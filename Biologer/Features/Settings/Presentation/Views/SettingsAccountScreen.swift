import SwiftUI

struct SettingsAccountScreen: View {
    @ObservedObject private var viewModel: SettingsAccountViewModel
    @State private var isLogoutConfirmationPresented = false
    @State private var isDeleteConfirmationPresented = false

    init(viewModel: SettingsAccountViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                profileHeader

                VStack(alignment: .leading, spacing: 10) {
                    BiologerSectionHeader(
                        title: "Logout.lb.currentlyDB".localized,
                        systemImage: "server.rack"
                    )

                    HStack(spacing: 14) {
                        BiologerIconBadge(systemImage: "network")

                        Text(viewModel.context.environment)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(BiologerColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .biologerCard()
                }

                Button(role: .destructive) {
                    isLogoutConfirmationPresented = true
                } label: {
                    Label("Logout.btn.logout".localized, systemImage: "rectangle.portrait.and.arrow.right")
                }
                .buttonStyle(
                    BiologerActionButtonStyle(
                        role: .destructive,
                        isFilled: false
                    )
                )

                VStack(alignment: .leading, spacing: 10) {
                    BiologerSectionHeader(
                        title: "DeleteAccount.btn.deleteAccount".localized,
                        systemImage: "exclamationmark.triangle"
                    )

                    VStack(spacing: 0) {
                        Toggle(
                            "DeleteAccount.lb.doYouWantToDeleteObservations".localized,
                            isOn: $viewModel.shouldDeleteObservations
                        )
                        .tint(BiologerColors.accent)
                        .foregroundColor(BiologerColors.textPrimary)
                        .padding(16)

                        Divider()
                            .padding(.leading, 16)

                        Text("DeleteAccount.lb.doYouWantLogout".localized)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                    }
                    .biologerCard()

                    Button(role: .destructive) {
                        isDeleteConfirmationPresented = true
                    } label: {
                        Label("DeleteAccount.btn.deleteAccount".localized, systemImage: "trash")
                    }
                    .buttonStyle(
                        BiologerActionButtonStyle(
                            role: .destructive
                        )
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .biologerScreen(title: "Settings.lb.userAccount".localized)
        .biologerLoadingOverlay(isPresented: viewModel.isLoading)
        .alert("Logout.lb.doYouWantLogout".localized, isPresented: $isLogoutConfirmationPresented) {
            Button("Common.btn.cancel".localized, role: .cancel) {}
            Button("Logout.btn.logout".localized, role: .destructive) {
                Task { await viewModel.logout() }
            }
        }
        .alert("DeleteAccount.lb.doYouWantLogout".localized, isPresented: $isDeleteConfirmationPresented) {
            Button("Common.btn.cancel".localized, role: .cancel) {}
            Button("DeleteAccount.btn.deleteAccount".localized, role: .destructive) {
                Task { await viewModel.deleteAccount() }
            }
        }
        .sheet(isPresented: errorSheetBinding) {
            BiologerResultSheet(
                style: .failure,
                title: "API.lb.error".localized,
                message: viewModel.errorMessage ?? "",
                onConfirm: viewModel.dismissError
            )
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 58, height: 58)

                Image(systemName: "person.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(viewModel.context.username)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)

                Text(viewModel.context.email)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Image(systemName: "leaf.fill")
                .font(.system(size: 38))
                .foregroundColor(.white.opacity(0.16))
        }
        .padding(20)
        .biologerHeroCard()
        .accessibilityElement(children: .combine)
    }

    private var errorSheetBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissError()
                }
            }
        )
    }
}
