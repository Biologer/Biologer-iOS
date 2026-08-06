import Foundation

@MainActor
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

    func makeFlow(
        onDownloadTaxa: @escaping Observer<Void>
    ) -> MainTabFlow {
        let viewModel = MainTabFlowViewModel(
            findingsFlowController: findingsFlowController
        )
        let findingsFlow = findingsFlowBuilder.makeFlow(
            controller: findingsFlowController,
            onAddFinding: { _ in
                viewModel.openCreateEditor()
            },
            onEditFinding: { findingID in
                viewModel.openEditEditor(id: findingID)
            }
        )
        let settingsFlow = settingsFlowBuilder.makeFlow(
            onDownloadTaxa: onDownloadTaxa
        )

        return MainTabFlow(
            viewModel: viewModel,
            findingsFlow: findingsFlow,
            editorFlowBuilder: findingEditorFlowBuilder,
            settingsFlow: settingsFlow
        )
    }
}
