import CSV
import Foundation

protocol TaxonCatalogCSVParsing {
    func parse(stream: InputStream) throws -> [TaxonCatalogEntry]
}

private enum TaxonCatalogCSVParserError: Error {
    case invalidRow
}

struct TaxonCatalogCSVParser: TaxonCatalogCSVParsing {
    func parse(stream: InputStream) throws -> [TaxonCatalogEntry] {
        let reader = try CSVReader(
            stream: stream,
            codecType: UTF8.self,
            hasHeaderRow: true
        )
        var entries: [TaxonCatalogEntry] = []

        while reader.next() != nil {
            guard let entry = makeEntry(from: reader) else {
                // A partial bundled catalog must never advance the baseline timestamp,
                // otherwise the missing row might not be returned by the delta endpoint.
                throw TaxonCatalogCSVParserError.invalidRow
            }

            entries.append(entry)
        }

        return entries
    }

    private func makeEntry(from reader: CSVReader) -> TaxonCatalogEntry? {
        guard let id = Int(reader["id"] ?? ""),
              id > 0,
              let name = reader["name"],
              !name.isEmpty,
              let rank = reader["rank"],
              !rank.isEmpty,
              let translations = reader["translations"] else {
            return nil
        }

        return TaxonCatalogEntry(
            id: id,
            name: name,
            rank: rank,
            rankLevel: nil,
            isRestricted: nil,
            isAllochthonous: nil,
            isInvasive: nil,
            usesAtlasCodes: nil,
            ancestorNames: nil,
            canEdit: nil,
            canDelete: nil,
            rankTranslation: nil,
            nativeName: nil,
            details: nil,
            translations: makeTranslations(
                from: translations,
                taxonID: id
            ),
            stages: []
        )
    }

    private func makeTranslations(
        from value: String,
        taxonID: Int
    ) -> [TaxonCatalogTranslation] {
        value
            .components(separatedBy: ";")
            .enumerated()
            .compactMap { index, name in
                guard !name.isEmpty else {
                    return nil
                }

                return TaxonCatalogTranslation(
                    // Bundled CSV translations have no server identifier.
                    // Negative IDs keep them outside the positive API ID space.
                    id: -((taxonID * 10) + index + 1),
                    locale: locale(at: index),
                    nativeName: name,
                    details: nil
                )
            }
    }

    private func locale(at index: Int) -> String {
        switch index {
        case 1:
            return "sr"
        case 2:
            return "sr-Latn"
        case 3:
            return "hr"
        case 4:
            return "bs"
        case 5:
            return "cnr"
        default:
            return "en"
        }
    }
}
