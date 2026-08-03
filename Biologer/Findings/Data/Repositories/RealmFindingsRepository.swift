import Foundation
import RealmSwift

final class RealmFindingsRepository: FindingsRepository, FindingDetailsRepository {
    private let configuration: Realm.Configuration

    init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }

    func getAll() throws -> [FindingSummary] {
        let realm = try makeRealm()
        return realm.objects(DBFinding.self).map(FindingSummaryMapper.map)
    }

    func get(id: UUID) throws -> FindingDetails {
        let realm = try makeRealm()
        guard let finding = realm.object(ofType: DBFinding.self, forPrimaryKey: id) else {
            throw FindingsRepositoryError.findingNotFound(id)
        }
        return FindingDetailsMapper.map(finding)
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

    func delete(ids: [UUID]) throws {
        guard !ids.isEmpty else { return }

        let realm = try makeRealm()
        var uniqueIDs = Set<UUID>()
        let findings = try ids.compactMap { id -> DBFinding? in
            guard uniqueIDs.insert(id).inserted else { return nil }
            guard let finding = realm.object(
                ofType: DBFinding.self,
                forPrimaryKey: id
            ) else {
                throw FindingsRepositoryError.findingNotFound(id)
            }
            return finding
        }

        try realm.write {
            realm.delete(findings)
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
