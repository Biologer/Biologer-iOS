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
private struct PreviewTaxonScope: TaxonCatalogScopeProviding { func currentScope() -> TaxonCatalogScope? { .init(environmentHost: "api.biologer.org") } }

struct TaxonSyncFlowPreview: View {
    private let previewState: TaxonSyncState

    init(state: TaxonSyncState = .idle(.init(
        scope: .init(environmentHost: "api.biologer.org"),
        availability: .partial,
        localTaxaCount: 742,
        lastSuccessfulSyncTimestamp: nil
    ))) {
        previewState = state
    }

    var body: some View {
        NavigationStack {
            TaxonSyncFlow(useCases: makeUseCases(), scopeProvider: PreviewTaxonScope())
        }
    }

    private func makeUseCases() -> TaxonSyncUseCases {
        let state = PreviewTaxonState(state: previewState)
        let action = PreviewTaxonAction()
        return TaxonSyncUseCases(getState: state, observeState: state, checkForUpdates: action, start: action, pause: action, resume: action)
    }
}

#Preview("Partial catalog") { TaxonSyncFlowPreview() }

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
