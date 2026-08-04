final class DefaultObserveTaxonSyncStateUseCase: ObserveTaxonSyncStateUseCase {
    private let controller: TaxonSyncControlling

    init(controller: TaxonSyncControlling) {
        self.controller = controller
    }

    func execute(
        scope: TaxonCatalogScope
    ) async -> AsyncStream<TaxonSyncState> {
        await controller.observe(scope: scope)
    }
}
