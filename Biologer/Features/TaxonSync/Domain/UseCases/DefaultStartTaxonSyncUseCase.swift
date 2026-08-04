final class DefaultStartTaxonSyncUseCase: StartTaxonSyncUseCase {
    private let controller: TaxonSyncControlling

    init(controller: TaxonSyncControlling) {
        self.controller = controller
    }

    func execute(scope: TaxonCatalogScope) async {
        await controller.start(scope: scope)
    }
}
