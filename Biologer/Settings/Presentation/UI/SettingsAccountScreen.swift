import SwiftUI

struct SettingsAccountScreen: View {
    @StateObject private var viewModel: SettingsAccountViewModel
    @State private var isLogoutConfirmationPresented = false
    @State private var isDeleteConfirmationPresented = false

    init(viewModel: SettingsAccountViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                LabeledContent("Logout.lb.currentlyDB".localized) {
                    Text(viewModel.context.environment)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Logout.lb.asUser".localized) {
                    VStack(alignment: .trailing) {
                        Text(viewModel.context.username)
                        Text(viewModel.context.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section {
                Button("Logout.btn.logout".localized, role: .destructive) {
                    isLogoutConfirmationPresented = true
                }
            }

            Section(
                footer: Text("DeleteAccount.lb.doYouWantLogout".localized)
            ) {
                Toggle(
                    "DeleteAccount.lb.doYouWantToDeleteObservations".localized,
                    isOn: $viewModel.shouldDeleteObservations
                )
                Button("DeleteAccount.btn.deleteAccount".localized, role: .destructive) {
                    isDeleteConfirmationPresented = true
                }
            }
        }
        .navigationTitle("Settings.lb.userAccount".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Logout.lb.doYouWantLogout".localized, isPresented: $isLogoutConfirmationPresented) {
            Button("Common.btn.cancel".localized, role: .cancel) {}
            Button("Logout.btn.logout".localized, role: .destructive) {
                viewModel.logout()
            }
        }
        .alert("DeleteAccount.lb.doYouWantLogout".localized, isPresented: $isDeleteConfirmationPresented) {
            Button("Common.btn.cancel".localized, role: .cancel) {}
            Button("DeleteAccount.btn.deleteAccount".localized, role: .destructive) {
                viewModel.deleteAccount()
            }
        }
    }
}
