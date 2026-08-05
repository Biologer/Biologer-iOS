final class RealmDownloadedTaxaRepository: DownloadedTaxaRepository {
    func hasDownloadedTaxa() -> Bool {
        !RealmManager.get(fromEntity: DBTaxon.self).isEmpty
    }

    func resetDownloadedTaxa() {
        RealmManager.delete(fromEntity: DBTaxon.self)
    }
}
