import Foundation
import RealmSwift

final class RealmFindingTaxonSearchRepository: FindingTaxonSearchRepository {
    private let configuration: Realm.Configuration

    init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }

    func search(query: String, limit: Int) throws -> [FindingEditorTaxon] {
        let realm = try Realm(configuration: configuration)
        let predicate = NSCompoundPredicate(
            type: .or,
            subpredicates: [
                NSPredicate(format: "name BEGINSWITH[cd] %@", query),
                NSPredicate(format: "nativName BEGINSWITH[cd] %@", query),
                NSPredicate(
                    format: "ANY translations.nativeName BEGINSWITH[cd] %@",
                    query
                )
            ]
        )

        return realm.objects(DBTaxon.self)
            .filter(predicate)
            .sorted(byKeyPath: "name", ascending: true)
            .prefix(max(limit, 0))
            .map { self.mapTaxon($0) }
    }

    private func mapTaxon(_ taxon: DBTaxon) -> FindingEditorTaxon {
        FindingEditorTaxon(
            apiID: taxon.id,
            name: displayName(for: taxon),
            usesAtlasCodes: taxon.isAtlasCodeExist ?? false,
            developmentStages: taxon.stages.map {
                FindingEditorOption(id: $0.id, name: $0.name ?? "")
            },
            translations: taxon.translations.map {
                FindingEditorTaxonTranslation(
                    id: $0.id,
                    taxonID: Int($0.taxonId) ?? taxon.id,
                    locale: $0.locale ?? "",
                    nativeName: $0.nativeName ?? "",
                    details: $0.trasnlationDescription ?? ""
                )
            }
        )
    }

    private func displayName(for taxon: DBTaxon) -> String {
        let languageCode = Locale.current.language.languageCode?.identifier
        let localizedName = taxon.translations.first {
            $0.locale == languageCode
        }?.nativeName ?? taxon.nativName

        guard
            let localizedName,
            !localizedName.isEmpty,
            localizedName.caseInsensitiveCompare(taxon.name) != .orderedSame
        else {
            return taxon.name
        }
        return "\(taxon.name) (\(localizedName))"
    }
}
