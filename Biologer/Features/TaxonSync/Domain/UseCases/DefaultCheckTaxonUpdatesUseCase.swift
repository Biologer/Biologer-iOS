final class DefaultCheckTaxonUpdatesUseCase: CheckTaxonUpdatesUseCase {
    private let controller: TaxonSyncControlling

    init(controller: TaxonSyncControlling) {
        self.controller = controller
    }

    func execute(
        scope: TaxonCatalogScope
    ) async throws(TaxonSyncFailure) -> TaxonSyncCheckResult {
        try await controller.checkForUpdates(scope: scope)
    }
}
