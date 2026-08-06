import SwiftUI

@MainActor
struct MainTabFlow: View {
    @StateObject private var viewModel: MainTabFlowViewModel

    private let findingsFlow: FindingsFlow
    private let editorFlowBuilder: any FindingEditorFlowBuilding
    private let settingsFlow: SettingsFlow

    init(
        viewModel: MainTabFlowViewModel,
        findingsFlow: FindingsFlow,
        editorFlowBuilder: any FindingEditorFlowBuilding,
        settingsFlow: SettingsFlow
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.findingsFlow = findingsFlow
        self.editorFlowBuilder = editorFlowBuilder
        self.settingsFlow = settingsFlow
    }

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            findingsFlow
                .tag(MainTab.findings)
                .tabItem {
                    Label(
                        "Findings.title".localized,
                        systemImage: "list.bullet"
                    )
                }

            editorFlowBuilder.makeFlow(
                mode: viewModel.editorMode,
                onSaved: { _ in viewModel.didSaveFinding() },
                onUnsavedChangesChanged: viewModel.updateEditorUnsavedChanges
            )
            .id(viewModel.editorSessionID)
            .tag(MainTab.editor)
            .tabItem {
                Label(
                    "TabBar.add.title".localized,
                    systemImage: "plus.circle.fill"
                )
            }

            settingsFlow
                .tag(MainTab.settings)
                .tabItem {
                    Label(
                        "Settings.title".localized,
                        systemImage: "gearshape"
                    )
                }
        }
        .tint(BiologerColors.accent)
        .alert(
            "FindingEditor.unsaved.title".localized,
            isPresented: unsavedChangesAlertIsPresented
        ) {
            Button(
                "FindingEditor.unsaved.continue".localized,
                role: .cancel,
                action: viewModel.continueEditing
            )
            Button(
                "FindingEditor.unsaved.discard".localized,
                role: .destructive,
                action: viewModel.discardChangesAndOpenPendingEditor
            )
        } message: {
            Text("FindingEditor.unsaved.message".localized)
        }
    }

    private var unsavedChangesAlertIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.pendingEditorMode != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.continueEditing()
                }
            }
        )
    }
}
