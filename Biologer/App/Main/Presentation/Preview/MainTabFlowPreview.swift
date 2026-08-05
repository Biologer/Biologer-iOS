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
        let navigation = MainTabNavigation(
            findingsFlowController: findingsFlowController
        )

        return MainTabFlow(
            navigation: navigation,
            makeFindings: { onAddFinding, onEditFinding in
                FindingsFlow_Previews.makeFlow(
                    onAddFinding: onAddFinding,
                    onEditFinding: onEditFinding
                )
            },
            makeEditor: { mode, onSaved, onUnsavedChangesChanged in
                FindingEditorScreen_Previews.makeFlow(
                    mode: mode,
                    onSaved: onSaved,
                    onUnsavedChangesChanged: onUnsavedChangesChanged
                )
            },
            settings: SettingsFlow_Previews.makeSettingsFlow()
        )
    }
}
