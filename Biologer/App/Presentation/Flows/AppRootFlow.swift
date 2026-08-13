import SwiftUI

@MainActor
struct AppRootFlow: View {
    let composition: AppRootComposition

    @StateObject private var coordinator: AppSessionCoordinator
    @StateObject private var taxonSyncViewModel: TaxonSyncViewModel

    init(
        composition: AppRootComposition
    ) {
        self.composition = composition
        _coordinator = StateObject(
            wrappedValue: composition.appSessionCoordinator
        )
        _taxonSyncViewModel = StateObject(
            wrappedValue: TaxonSyncViewModel(
                useCases: composition.taxonSyncComposition.useCases,
                scopeProvider: composition.taxonSyncComposition.scopeProvider
            )
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
                taxonSyncScreen

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
        composition.mainTabFlowBuilder.makeFlow()
    }

    private var taxonSyncScreen: some View {
        TaxonSyncScreen(
            viewModel: taxonSyncViewModel,
            onContinue: coordinator.continueAfterTaxonSync
        )
    }
}
