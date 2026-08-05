import SwiftUI

@MainActor
struct AppRootFlow: View {
    let composition: AppRootComposition

    @StateObject private var viewModel: AppRootViewModel

    init(
        composition: AppRootComposition
    ) {
        self.composition = composition
        _viewModel = StateObject(wrappedValue: composition.rootViewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .launching:
                SplashScreen {
                    viewModel.finishLaunching()
                }
            case .authorization:
                authorizationFlow
            case .preparingSession:
                ProgressView()
                    .task { await viewModel.prepareSession() }
            case .taxonSync:
                taxonSyncFlow
            case .main:
                mainFlow
            }
        }
        .onAppear {
            viewModel.startObservingSession()
        }
        .onDisappear {
            viewModel.stopObservingSession()
        }
        .alert(item: $viewModel.alert, content: makeAlert)
    }

    private var authorizationFlow: some View {
        AuthorizationFlow(
            authorizationUseCases: composition.authorizationUseCases,
            shouldPresentHelp: !composition.tutorialRepository.wasPresented,
            onHelpCompleted: { _ in composition.tutorialRepository.markPresented() },
            onAuthorizationSuccess: { _ in viewModel.authorizationSucceeded() }
        )
    }

    private var mainFlow: some View {
        MainTabFlow(
            navigation: MainTabNavigation(
                findingsFlowController: composition.findingsFlowController
            ),
            makeFindings: { onAddFinding, onEditFinding in
                composition.findingsBuilder.makeFlow(
                    controller: composition.findingsFlowController,
                    onAddFinding: onAddFinding,
                    onEditFinding: onEditFinding
                )
            },
            makeEditor: { mode, onSaved, onUnsavedChangesChanged in
                composition.findingEditorBuilder.makeFlow(
                    mode: mode,
                    onSaved: onSaved,
                    onUnsavedChangesChanged: onUnsavedChangesChanged
                )
            },
            settings: composition.settingsBuilder.makeFlow(
                onDownloadTaxa: { _ in viewModel.showTaxonSync() }
            )
        )
    }

    private var taxonSyncFlow: some View {
        TaxonSyncFlow(
            useCases: composition.taxonSyncComposition.useCases,
            scopeProvider: composition.taxonSyncComposition.scopeProvider,
            onContinue: { viewModel.showMain() }
        )
    }

    private func makeAlert(_ alert: AppRootAlert) -> Alert {
        Alert(
            title: Text("API.lb.error".localized),
            message: Text(alert.message),
            primaryButton: .default(Text("TaxonSync.action.retry".localized)) {
                Task { await viewModel.prepareSession() }
            },
            secondaryButton: .destructive(Text("Logout.btn.logout".localized)) {
                viewModel.logout()
            }
        )
    }
}
