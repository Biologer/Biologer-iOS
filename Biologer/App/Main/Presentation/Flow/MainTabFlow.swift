import SwiftUI

enum MainTab: Hashable {
    case findings
    case editor
    case settings
}

@MainActor
final class MainTabNavigation: ObservableObject {
    @Published var selectedTab: MainTab = .findings
    @Published private(set) var editorMode: FindingEditorMode = .create
    @Published private(set) var editorSessionID = UUID()
    @Published private(set) var pendingEditorMode: FindingEditorMode?

    private let findingsFlowController: FindingsFlowControlling
    private var editorHasUnsavedChanges = false

    init(findingsFlowController: FindingsFlowControlling) {
        self.findingsFlowController = findingsFlowController
    }

    func openCreateEditor() {
        requestEditor(mode: .create)
    }

    func openEditEditor(id: UUID) {
        requestEditor(mode: .edit(id))
    }

    func updateEditorUnsavedChanges(_ hasUnsavedChanges: Bool) {
        editorHasUnsavedChanges = hasUnsavedChanges
    }

    func didSaveFinding() {
        editorHasUnsavedChanges = false
        pendingEditorMode = nil
        findingsFlowController.showListAndReload()
        replaceEditor(mode: .create)
        selectedTab = .findings
    }

    func continueEditing() {
        pendingEditorMode = nil
    }

    func discardChangesAndOpenPendingEditor() {
        guard let pendingEditorMode else { return }
        self.pendingEditorMode = nil
        replaceEditor(mode: pendingEditorMode)
    }

    private func requestEditor(mode: FindingEditorMode) {
        selectedTab = .editor

        guard editorMode != mode else { return }
        guard editorHasUnsavedChanges else {
            replaceEditor(mode: mode)
            return
        }

        pendingEditorMode = mode
    }

    private func replaceEditor(mode: FindingEditorMode) {
        editorHasUnsavedChanges = false
        editorMode = mode
        editorSessionID = UUID()
    }
}

@MainActor
private final class MainTabEditorContentStorage<Content: View>: ObservableObject {
    let content: Content

    init(content: Content) {
        self.content = content
    }
}

@MainActor
private struct MainTabEditorContent<Content: View>: View {
    @StateObject private var storage: MainTabEditorContentStorage<Content>

    init(
        mode: FindingEditorMode,
        makeEditor: @escaping MainTabFlow<EmptyView, Content, EmptyView>.EditorFactory,
        onSaved: @escaping Observer<UUID>,
        onUnsavedChangesChanged: @escaping Observer<Bool>
    ) {
        _storage = StateObject(
            wrappedValue: MainTabEditorContentStorage(
                content: makeEditor(
                    mode,
                    onSaved,
                    onUnsavedChangesChanged
                )
            )
        )
    }

    var body: some View {
        storage.content
    }
}

@MainActor
struct MainTabFlow<FindingsContent: View, EditorContent: View, SettingsContent: View>: View {
    typealias FindingsFactory = (
        _ onAddFinding: @escaping Observer<Void>,
        _ onEditFinding: @escaping Observer<UUID>
    ) -> FindingsContent

    typealias EditorFactory = (
        _ mode: FindingEditorMode,
        _ onSaved: @escaping Observer<UUID>,
        _ onUnsavedChangesChanged: @escaping Observer<Bool>
    ) -> EditorContent

    @StateObject private var navigation: MainTabNavigation

    private let findings: FindingsContent
    private let makeEditor: EditorFactory
    private let settings: SettingsContent

    init(
        navigation: MainTabNavigation,
        makeFindings: @escaping FindingsFactory,
        makeEditor: @escaping EditorFactory,
        settings: SettingsContent
    ) {
        _navigation = StateObject(wrappedValue: navigation)
        findings = makeFindings(
            { _ in navigation.openCreateEditor() },
            { id in navigation.openEditEditor(id: id) }
        )
        self.makeEditor = makeEditor
        self.settings = settings
    }

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            findings
                .tag(MainTab.findings)
                .tabItem {
                    Label(
                        "SideMenu.lb.listOfFindings".localized,
                        systemImage: "list.bullet"
                    )
                }

            MainTabEditorContent(
                mode: navigation.editorMode,
                makeEditor: makeEditor,
                onSaved: { _ in navigation.didSaveFinding() },
                onUnsavedChangesChanged: navigation.updateEditorUnsavedChanges
            )
            .id(navigation.editorSessionID)
            .tag(MainTab.editor)
            .tabItem {
                Label(
                    "TabBar.add.title".localized,
                    systemImage: "plus.circle.fill"
                )
            }

            settings
                .tag(MainTab.settings)
                .tabItem {
                    Label(
                        "SideMenu.lb.setup".localized,
                        systemImage: "gearshape"
                    )
                }
        }
        .tint(BiologerColors.accent)
        .alert(
            "FindingEditorV2.unsaved.title".localized,
            isPresented: unsavedChangesAlertIsPresented
        ) {
            Button(
                "FindingEditorV2.unsaved.continue".localized,
                role: .cancel,
                action: navigation.continueEditing
            )
            Button(
                "FindingEditorV2.unsaved.discard".localized,
                role: .destructive,
                action: navigation.discardChangesAndOpenPendingEditor
            )
        } message: {
            Text("FindingEditorV2.unsaved.message".localized)
        }
    }

    private var unsavedChangesAlertIsPresented: Binding<Bool> {
        Binding(
            get: { navigation.pendingEditorMode != nil },
            set: { isPresented in
                if !isPresented {
                    navigation.continueEditing()
                }
            }
        )
    }
}
