import Foundation
import RealmSwift

final class RealmFindingsRepository: FindingsRepository {
    private let configuration: Realm.Configuration

    init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }

    func getAll() throws -> [FindingSummary] {
        let realm = try makeRealm()
        return realm.objects(DBFinding.self).map(FindingSummaryMapper.map)
    }

    func delete(id: UUID) throws {
        let realm = try makeRealm()
        guard let finding = realm.object(ofType: DBFinding.self, forPrimaryKey: id) else {
            throw FindingsRepositoryError.findingNotFound(id)
        }

        try realm.write {
            realm.delete(finding)
        }
    }

    func deleteAll() throws {
        let realm = try makeRealm()
        let findings = realm.objects(DBFinding.self)

        try realm.write {
            realm.delete(findings)
        }
    }

    private func makeRealm() throws -> Realm {
        try Realm(configuration: configuration)
    }
}
