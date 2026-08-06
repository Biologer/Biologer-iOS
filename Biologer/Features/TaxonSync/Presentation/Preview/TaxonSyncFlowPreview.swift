import SwiftUI

private struct PreviewTaxonState: GetTaxonSyncStateUseCase, ObserveTaxonSyncStateUseCase {
    let state: TaxonSyncState
    func execute(scope: TaxonCatalogScope) async -> TaxonSyncState { state }
    func execute(scope: TaxonCatalogScope) async -> AsyncStream<TaxonSyncState> { AsyncStream { continuation in continuation.yield(state); continuation.finish() } }
}
private struct PreviewTaxonAction: CheckTaxonUpdatesUseCase, StartTaxonSyncUseCase, PauseTaxonSyncUseCase, ResumeTaxonSyncUseCase {
    func execute(scope: TaxonCatalogScope) async throws(TaxonSyncFailure) -> TaxonSyncCheckResult { .upToDate(.init(scope: scope, availability: .ready, localTaxaCount: 1240, lastSuccessfulSyncTimestamp: nil)) }
    func execute(scope: TaxonCatalogScope) async {}
}
private struct PreviewTaxonScope: TaxonCatalogScopeProviding {
    let scope: TaxonCatalogScope
    func currentScope() -> TaxonCatalogScope? { scope }
}

enum TaxonSyncPreviewFactory {
    static func makeComposition(
        state: TaxonSyncState? = nil
    ) -> TaxonSyncComposition {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let previewState = state ?? .idle(.init(
            scope: scope,
            availability: .partial,
            localTaxaCount: 742,
            lastSuccessfulSyncTimestamp: nil
        ))
        let stateUseCase = PreviewTaxonState(state: previewState)
        let actionUseCase = PreviewTaxonAction()

        return TaxonSyncComposition(
            useCases: TaxonSyncUseCases(
                getState: stateUseCase,
                observeState: stateUseCase,
                checkForUpdates: actionUseCase,
                start: actionUseCase,
                pause: actionUseCase,
                resume: actionUseCase
            ),
            scopeProvider: PreviewTaxonScope(scope: scope)
        )
    }
}

struct TaxonSyncFlowPreview: View {
    private let previewState: TaxonSyncState
    private let showsContinueAction: Bool

    init(state: TaxonSyncState = .idle(.init(
        scope: .init(environmentHost: "api.biologer.org"),
        availability: .partial,
        localTaxaCount: 742,
        lastSuccessfulSyncTimestamp: nil
    )), showsContinueAction: Bool = false) {
        previewState = state
        self.showsContinueAction = showsContinueAction
    }

    var body: some View {
        let composition = TaxonSyncPreviewFactory.makeComposition(
            state: previewState
        )
        NavigationStack {
            TaxonSyncFlow(
                viewModel: TaxonSyncViewModel(
                    useCases: composition.useCases,
                    scopeProvider: composition.scopeProvider
                ),
                onContinue: showsContinueAction ? {} : nil
            )
        }
    }
}

#Preview("Partial catalog") { TaxonSyncFlowPreview() }

#Preview("Startup - empty catalog") {
    TaxonSyncFlowPreview(
        state: .idle(.init(
            scope: .init(environmentHost: "api.biologer.org"),
            availability: .empty,
            localTaxaCount: 0,
            lastSuccessfulSyncTimestamp: nil
        )),
        showsContinueAction: true
    )
}

#Preview("Downloading") {
    TaxonSyncFlowPreview(state: .working(
        phase: .downloading,
        progress: .init(
            completedPages: 18,
            totalPages: 64,
            importedTaxaCount: 1_842,
            totalTaxaCount: 6_400
        )
    ))
}

#Preview("Paused") {
    TaxonSyncFlowPreview(state: .paused(.init(
        completedPages: 31,
        totalPages: 64,
        importedTaxaCount: 3_260,
        totalTaxaCount: 6_400
    )))
}

#Preview("Updates available") {
    TaxonSyncFlowPreview(state: .updateAvailable(.init(
        scope: .init(environmentHost: "api.biologer.org"),
        changedTaxaCount: 128,
        totalPages: 4
    )))
}
