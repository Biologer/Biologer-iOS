import SwiftUI

struct ProjectNameSettingsScreen: View {
    @StateObject private var viewModel: ProjectNameSettingsViewModel
    let onSaved: Observer<Void>

    init(
        viewModel: ProjectNameSettingsViewModel,
        onSaved: @escaping Observer<Void>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSaved = onSaved
    }

    var body: some View {
        Form {
            TextField("ProjectName.tf.placeholder".localized, text: $viewModel.projectName)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
        }
        .navigationTitle("Settings.lb.projectName.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Common.btn.ok".localized) {
                    viewModel.save()
                    onSaved(())
                }
            }
        }
    }
}
