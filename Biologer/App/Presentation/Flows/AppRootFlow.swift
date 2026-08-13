import SwiftUI

@MainActor
struct AppRootFlow: View {
    let composition: AppRootComposition

    @StateObject private var coordinator: AppSessionCoordinator

    init(
        composition: AppRootComposition
    ) {
        self.composition = composition
        _coordinator = StateObject(
            wrappedValue: composition.appSessionCoordinator
        )
    }

    var body: some View {
        Group {
            switch coordinator.state {
            case .launching:
                SplashScreen {
                    await coordinator.finishLaunching()
                }

            case .authorizationRequired:
                authorizationFlow

            case .preparing:
                BiologerActivityIndicator(size: .large)
                    .task {
                        await coordinator.prepareSession()
                    }

            case .preparationFailed(let message):
                AppSessionPreparationFailureView(
                    message: message,
                    onRetry: coordinator.retryPreparation,
                    onLogout: coordinator.logout
                )

            case .taxonSyncRequired:
                taxonSyncFlow

            case .ready:
                mainFlow
            }
        }
        .task {
            await coordinator.observeSession()
        }
    }

    private var authorizationFlow: some View {
        composition.authorizationFlowBuilder.makeFlow(
            onAuthorizationSuccess: coordinator.authorizationSucceeded
        )
    }

    private var mainFlow: some View {
        composition.mainTabFlowBuilder.makeFlow(
            onDownloadTaxa: coordinator.showTaxonSync
        )
    }

    private var taxonSyncFlow: some View {
        composition.taxonSyncFlowBuilder.makeFlow(
            onContinue: coordinator.continueAfterTaxonSync
        )
    }
}
