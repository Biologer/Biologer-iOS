final class DefaultResumeTaxonSyncUseCase: ResumeTaxonSyncUseCase {
    private let controller: TaxonSyncControlling

    init(controller: TaxonSyncControlling) {
        self.controller = controller
    }

    func execute(scope: TaxonCatalogScope) async {
        await controller.resume(scope: scope)
    }
}
