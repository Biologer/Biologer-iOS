import SwiftUI
import UIKit

@MainActor
final class MainTabBuilder {
    private let findingsBuilder: FindingsBuilder
    private let findingEditorBuilder: FindingEditorBuilder
    private let settingsBuilder: SettingsBuilder
    private let findingsFlowController: FindingsFlowController

    init(
        findingsBuilder: FindingsBuilder,
        findingEditorBuilder: FindingEditorBuilder,
        settingsBuilder: SettingsBuilder,
        findingsFlowController: FindingsFlowController
    ) {
        self.findingsBuilder = findingsBuilder
        self.findingEditorBuilder = findingEditorBuilder
        self.settingsBuilder = settingsBuilder
        self.findingsFlowController = findingsFlowController
    }

    func makeViewController(
        onDownloadTaxa: @escaping Observer<Void>,
        onLogout: @escaping Observer<Void>,
        onDeleteAccount: @escaping Observer<Bool>,
        onShowFindingLocation: @escaping Observer<FindingDetailsLocation>
    ) -> UIViewController {
        let navigation = MainTabNavigation(
            findingsFlowController: findingsFlowController
        )
        let flow = MainTabFlow(
            navigation: navigation,
            makeFindings: { [findingsBuilder, findingsFlowController]
                onAddFinding,
                onEditFinding,
                onShowLocation in
                findingsBuilder.makeFlow(
                    controller: findingsFlowController,
                    onAddFinding: onAddFinding,
                    onEditFinding: onEditFinding,
                    onShowLocation: onShowLocation
                )
            },
            makeEditor: { [findingEditorBuilder]
                mode,
                onSaved,
                onUnsavedChangesChanged in
                findingEditorBuilder.makeFlow(
                    mode: mode,
                    onSaved: onSaved,
                    onUnsavedChangesChanged: onUnsavedChangesChanged
                )
            },
            settings: settingsBuilder.makeFlow(
                onDownloadTaxa: onDownloadTaxa,
                onLogout: onLogout,
                onDeleteAccount: onDeleteAccount
            ),
            onShowFindingLocation: onShowFindingLocation
        )
        return UIHostingController(rootView: flow)
    }
}
