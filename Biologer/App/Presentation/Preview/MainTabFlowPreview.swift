import SwiftUI

struct MainTabFlow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            makeFlow()
                .previewDisplayName("Main tabs ")

            makeFlow()
                .preferredColorScheme(.dark)
                .previewDisplayName("Main tabs  - Dark")
        }
    }

    @MainActor
    private static func makeFlow() -> some View {
        let findingsFlowController = FindingsFlowController()
        let viewModel = MainTabFlowViewModel(
            findingsFlowController: findingsFlowController
        )
        let findingsFlow = FindingsFlow_Previews.makeFlow(
            onAddFinding: viewModel.openCreateEditor,
            onEditFinding: { viewModel.openEditEditor(id: $0) }
        )

        return MainTabFlow(
            viewModel: viewModel,
            findingsFlow: findingsFlow,
            editorFlowBuilder: PreviewFindingEditorFlowBuilder(),
            settingsFlow: SettingsFlow_Previews.makeSettingsFlow()
        )
    }
}

@MainActor
private struct PreviewFindingEditorFlowBuilder: FindingEditorFlowBuilding {
    func makeFlow(
        mode: FindingEditorMode,
        onSaved: @escaping (UUID) -> Void,
        onUnsavedChangesChanged: @escaping (Bool) -> Void
    ) -> FindingEditorFlow {
        FindingEditorScreen_Previews.makeFlow(
            mode: mode,
            onSaved: onSaved,
            onUnsavedChangesChanged: onUnsavedChangesChanged
        )
    }
}
