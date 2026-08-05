import SwiftUI

enum AppRootState: Equatable {
    case launching
    case authorization
    case preparingSession
    case taxonSync
    case main
}

@MainActor
struct AppRootFlow: View {
    let composition: AppRootComposition

    @State private var rootState: AppRootState = .launching
    @State private var alert: AppRootAlert?

    init(
        composition: AppRootComposition
    ) {
        self.composition = composition
    }

    var body: some View {
        Group {
            switch rootState {
            case .launching:
                SplashScreen {
                    finishLaunching()
                }
            case .authorization:
                authorizationFlow
            case .preparingSession:
                ProgressView()
                    .task { await prepareSession() }
            case .taxonSync:
                taxonSyncFlow
            case .main:
                mainFlow
            }
        }
        .onAppear {
            composition.sessionStore.onStateChange = { state in
                route(for: state)
            }
        }
        .onDisappear {
            composition.sessionStore.onStateChange = nil
        }
        .alert(item: $alert, content: makeAlert)
    }

    private var authorizationFlow: some View {
        AuthorizationFlow(
            authorizationUseCases: composition.authorizationUseCases,
            shouldPresentHelp: !composition.tutorialRepository.wasPresented,
            onHelpCompleted: { _ in composition.tutorialRepository.markPresented() },
            onAuthorizationSuccess: { _ in composition.sessionStore.synchronize() }
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
                onDownloadTaxa: { _ in rootState = .taxonSync }
            )
        )
    }

    private var taxonSyncFlow: some View {
        TaxonSyncFlow(
            useCases: composition.taxonSyncComposition.useCases,
            scopeProvider: composition.taxonSyncComposition.scopeProvider,
            onContinue: { rootState = .main }
        )
    }

    private func finishLaunching() {
        composition.sessionStore.synchronize()
        route(for: composition.sessionStore.state)
    }

    private func route(for state: SessionState) {
        let nextState: AppRootState
        switch state {
        case .checking:
            nextState = .launching
        case .unauthenticated:
            nextState = .authorization
        case .authenticated:
            nextState = .preparingSession
        }

        guard rootState != nextState else { return }
        DispatchQueue.main.async {
            rootState = nextState
        }
    }

    private func prepareSession() async {
        do {
            try await composition.prepareSessionUseCase.execute()
            guard let scope = composition.taxonSyncComposition.scopeProvider.currentScope() else {
                rootState = .main
                return
            }
            let state = await composition.taxonSyncComposition.useCases.getState.execute(scope: scope)
            rootState = isTaxonCatalogReady(state) ? .main : .taxonSync
        } catch {
            alert = AppRootAlert(message: error.description)
        }
    }

    private func isTaxonCatalogReady(_ state: TaxonSyncState) -> Bool {
        switch state {
        case .idle(let status), .completed(let status):
            return status.availability == .ready
        default:
            return false
        }
    }

    private func makeAlert(_ alert: AppRootAlert) -> Alert {
        Alert(
            title: Text("API.lb.error".localized),
            message: Text(alert.message),
            primaryButton: .default(Text("TaxonSync.action.retry".localized)) {
                Task { await prepareSession() }
            },
            secondaryButton: .destructive(Text("Logout.btn.logout".localized)) {
                composition.logoutUseCase.logout()
            }
        )
    }
}

private struct AppRootAlert: Identifiable {
    let id = UUID()
    let message: String
}
