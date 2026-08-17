import Foundation

final class MainTabFlowBuilder {
    private let findingsFlowBuilder: FindingsFlowBuilder
    private let findingEditorFlowBuilder: FindingEditorFlowBuilder
    private let settingsFlowBuilder: SettingsFlowBuilder
    private let findingsFlowController: FindingsFlowController

    init(
        findingsFlowBuilder: FindingsFlowBuilder,
        findingEditorFlowBuilder: FindingEditorFlowBuilder,
        settingsFlowBuilder: SettingsFlowBuilder,
        findingsFlowController: FindingsFlowController
    ) {
        self.findingsFlowBuilder = findingsFlowBuilder
        self.findingEditorFlowBuilder = findingEditorFlowBuilder
        self.settingsFlowBuilder = settingsFlowBuilder
        self.findingsFlowController = findingsFlowController
    }

    @MainActor
    func makeFlow() -> MainTabFlow {
        let viewModel = MainTabFlowViewModel(
            findingsFlowController: findingsFlowController
        )
        let findingsFlow = findingsFlowBuilder.makeFlow(
            controller: findingsFlowController,
            onAddFinding: {
                viewModel.openCreateEditor()
            },
            onEditFinding: { findingID in
                viewModel.openEditEditor(id: findingID)
            }
        )
        let settingsFlow = settingsFlowBuilder.makeFlow()

        return MainTabFlow(
            viewModel: viewModel,
            findingsFlow: findingsFlow,
            editorFlowBuilder: findingEditorFlowBuilder,
            settingsFlow: settingsFlow
        )
    }
}
