final class RealmDownloadedTaxaRepository: DownloadedTaxaRepository {
    private let paginationStorage: TaxonsPaginationInfoStorage

    init(paginationStorage: TaxonsPaginationInfoStorage) {
        self.paginationStorage = paginationStorage
    }

    func hasDownloadedTaxa() -> Bool {
        !RealmManager.get(fromEntity: DBTaxon.self).isEmpty
    }

    func resetDownloadedTaxa() {
        RealmManager.delete(fromEntity: DBTaxon.self)
        paginationStorage.delete()
    }
}
