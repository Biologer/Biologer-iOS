import RealmSwift

final class RealmTaxonCatalogRepository: TaxonCatalogRepository {
    private let configuration: Realm.Configuration

    init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }

    func count() throws(TaxonSyncFailure) -> Int {
        do {
            return try makeRealm().objects(DBTaxon.self).count
        } catch {
            throw .localPersistence
        }
    }

    func upsert(
        _ entries: [TaxonCatalogEntry]
    ) throws(TaxonSyncFailure) {
        guard !entries.isEmpty else {
            return
        }

        do {
            let realm = try makeRealm()
            let databaseTaxa = entries.map(
                TaxonCatalogRealmMapper.makeDatabaseTaxon
            )

            try realm.write {
                realm.add(databaseTaxa, update: .modified)
            }
        } catch {
            throw .localPersistence
        }
    }

    func deleteAll() throws(TaxonSyncFailure) {
        do {
            let realm = try makeRealm()
            let taxa = realm.objects(DBTaxon.self)
            let translations = realm.objects(DBTaxonTranslation.self)
            let stages = realm.objects(DBTaxonStages.self)

            try realm.write {
                realm.delete(taxa)
                realm.delete(translations)
                realm.delete(stages)
            }
        } catch {
            throw .localPersistence
        }
    }

    private func makeRealm() throws -> Realm {
        try Realm(configuration: configuration)
    }
}
