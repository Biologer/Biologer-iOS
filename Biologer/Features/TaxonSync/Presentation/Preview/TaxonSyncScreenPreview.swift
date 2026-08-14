import SwiftUI

private final class PreviewTaxonService: TaxonSyncService {
    let snapshot: TaxonSyncState

    init(state: TaxonSyncState) {
        self.snapshot = state
    }

    func state(scope: TaxonCatalogScope) async -> TaxonSyncState { snapshot }

    func observe(
        scope: TaxonCatalogScope
    ) async -> AsyncStream<TaxonSyncState> {
        AsyncStream { continuation in
            continuation.yield(snapshot)
            continuation.finish()
        }
    }

    func checkForUpdates(
        scope: TaxonCatalogScope
    ) async throws(TaxonSyncFailure) -> TaxonSyncCheckResult {
        .upToDate(
            .init(
                scope: scope,
                availability: .ready,
                localTaxaCount: 1_240,
                lastSuccessfulSyncTimestamp: nil
            )
        )
    }

    func start(scope: TaxonCatalogScope) async {}
    func pause(scope: TaxonCatalogScope) async {}
    func resume(scope: TaxonCatalogScope) async {}
}
private struct PreviewTaxonScope: TaxonCatalogScopeProviding {
    let scope: TaxonCatalogScope
    func currentScope() -> TaxonCatalogScope? { scope }
}

private let previewTaxonScope = TaxonCatalogScope(
    environmentHost: "api.biologer.org"
)

private func makePreviewState(
    availability: TaxonCatalogAvailability,
    operation: TaxonSyncOperation = .idle
) -> TaxonSyncState {
    TaxonSyncState(
        catalogStatus: TaxonCatalogStatus(
            scope: previewTaxonScope,
            availability: availability,
            localTaxaCount: availability == .empty ? 0 : 742,
            lastSuccessfulSyncTimestamp: availability == .ready ? 1 : nil
        ),
        operation: operation
    )
}

enum TaxonSyncPreviewFactory {
    static func makeComposition(
        state: TaxonSyncState? = nil
    ) -> TaxonSyncComposition {
        let previewState = state ?? makePreviewState(availability: .partial)
        return TaxonSyncComposition(
            service: PreviewTaxonService(state: previewState),
            scopeProvider: PreviewTaxonScope(scope: previewTaxonScope)
        )
    }
}

@MainActor
struct TaxonSyncScreenPreview: View {
    /// The preview owns the ViewModel for the same reason as a production flow:
    /// SwiftUI body recomputation must not recreate its observation state.
    @StateObject private var viewModel: TaxonSyncViewModel

    private let showsContinueAction: Bool

    init(
        state: TaxonSyncState? = nil,
        showsContinueAction: Bool = false
    ) {
        let composition = TaxonSyncPreviewFactory.makeComposition(
            state: state ?? makePreviewState(availability: .partial)
        )
        _viewModel = StateObject(
            wrappedValue: composition.makeViewModel()
        )
        self.showsContinueAction = showsContinueAction
    }

    var body: some View {
        NavigationStack {
            TaxonSyncScreen(
                viewModel: viewModel,
                onContinue: showsContinueAction ? {} : nil
            )
        }
        .task {
            await viewModel.observeState()
        }
    }
}

#Preview("Partial catalog") { TaxonSyncScreenPreview() }

#Preview("Startup - offline catalog") {
    TaxonSyncScreenPreview(
        state: makePreviewState(availability: .initialCatalogLoaded),
        showsContinueAction: true
    )
}

#Preview("Downloading") {
    TaxonSyncScreenPreview(
        state: makePreviewState(
            availability: .initialCatalogLoaded,
            operation: .working(
                phase: .downloading,
                progress: .init(
                    completedPages: 18,
                    totalPages: 64,
                    importedTaxaCount: 1_842,
                    totalTaxaCount: 6_400
                )
            )
        )
    )
}

#Preview("Paused") {
    TaxonSyncScreenPreview(
        state: makePreviewState(
            availability: .initialCatalogLoaded,
            operation: .paused(.init(
                completedPages: 31,
                totalPages: 64,
                importedTaxaCount: 3_260,
                totalTaxaCount: 6_400
            ))
        )
    )
}

#Preview("Updates available") {
    TaxonSyncScreenPreview(
        state: makePreviewState(
            availability: .ready,
            operation: .updateAvailable(.init(
                scope: previewTaxonScope,
                changedTaxaCount: 128,
                totalPages: 4
            ))
        )
    )
}
