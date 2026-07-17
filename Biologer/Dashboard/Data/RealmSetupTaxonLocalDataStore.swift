import Foundation

final class RealmSetupTaxonLocalDataStore: SetupTaxonLocalDataStore {
    func hasTaxa() -> Bool {
        !RealmManager.get(fromEntity: DBTaxon.self).isEmpty
    }

    func deleteTaxa() {
        RealmManager.delete(fromEntity: DBTaxon.self)
    }
}
