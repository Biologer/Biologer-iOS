import Foundation
import RealmSwift

final class RealmFindingEditorRepository: FindingEditorRepository {
    private let configuration: Realm.Configuration

    init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }

    func makeNewDraft() throws -> FindingEditorDraft {
        let realm = try makeRealm()
        let observations = realm.objects(DBObservation.self).map {
            FindingEditorObservation(
                id: $0.id,
                name: self.observationName($0),
                isSelected: false
            )
        }
        return .empty(observations: Array(observations))
    }

    func getDraft(id: UUID) throws -> FindingEditorDraft {
        let realm = try makeRealm()
        guard let finding = realm.object(ofType: DBFinding.self, forPrimaryKey: id) else {
            throw FindingEditorRepositoryError.findingNotFound(id)
        }
        return FindingEditorMapper.map(finding)
    }

    func create(_ draft: FindingEditorDraft) throws {
        let realm = try makeRealm()
        let finding = FindingEditorMapper.makeDatabaseFinding(from: draft)

        try realm.write {
            realm.add(finding)
        }
    }

    func update(_ draft: FindingEditorDraft) throws {
        let realm = try makeRealm()
        guard let finding = realm.object(
            ofType: DBFinding.self,
            forPrimaryKey: draft.id
        ) else {
            throw FindingEditorRepositoryError.findingNotFound(draft.id)
        }

        try realm.write {
            FindingEditorMapper.apply(draft, to: finding)
        }
    }

    private func makeRealm() throws -> Realm {
        try Realm(configuration: configuration)
    }

    private func observationName(_ observation: DBObservation) -> String {
        let languageCode = Locale.current.language.languageCode?.identifier
        return observation.translation.first(where: { $0.local == languageCode })?.name
            ?? observation.translation.first(where: { $0.local == "en" })?.name
            ?? observation.translation.first?.name
            ?? ""
    }
}
