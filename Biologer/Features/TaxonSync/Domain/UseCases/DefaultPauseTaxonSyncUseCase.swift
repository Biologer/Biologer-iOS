final class DefaultPauseTaxonSyncUseCase: PauseTaxonSyncUseCase {
    private let controller: TaxonSyncControlling

    init(controller: TaxonSyncControlling) {
        self.controller = controller
    }

    func execute(scope: TaxonCatalogScope) async {
        await controller.pause(scope: scope)
    }
}
