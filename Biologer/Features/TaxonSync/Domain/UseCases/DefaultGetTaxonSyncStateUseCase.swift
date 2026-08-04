final class DefaultGetTaxonSyncStateUseCase: GetTaxonSyncStateUseCase {
    private let controller: TaxonSyncControlling

    init(controller: TaxonSyncControlling) {
        self.controller = controller
    }

    func execute(
        scope: TaxonCatalogScope
    ) async -> TaxonSyncState {
        await controller.state(scope: scope)
    }
}
