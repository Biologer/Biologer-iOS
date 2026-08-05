struct TaxonUpdatesResponse: Decodable, Equatable {
    let data: [Taxon]
    let meta: Pagination
}

extension TaxonUpdatesResponse {
    struct Taxon: Decodable, Equatable {
        let id: Int
        let name: String?
        let rank: String?
        let rankLevel: Int?
        let isRestricted: Bool?
        let isAllochthonous: Bool?
        let isInvasive: Bool?
        let usesAtlasCodes: Bool?
        let ancestorNames: String?
        let canEdit: Bool?
        let canDelete: Bool?
        let rankTranslation: String?
        let nativeName: String?
        let details: String?
        let translations: [Translation]?
        let stages: [Stage]?

        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case rank
            case rankLevel = "rank_level"
            case isRestricted = "restricted"
            case isAllochthonous = "allochthonous"
            case isInvasive = "invasive"
            case usesAtlasCodes = "uses_atlas_codes"
            case ancestorNames = "ancestors_names"
            case canEdit = "can_edit"
            case canDelete = "can_delete"
            case rankTranslation = "rank_translation"
            case nativeName = "native_name"
            case details = "description"
            case translations
            case stages
        }
    }

    struct Translation: Decodable, Equatable {
        let id: Int
        let locale: String?
        let nativeName: String?
        let details: String?

        private enum CodingKeys: String, CodingKey {
            case id
            case locale
            case nativeName = "native_name"
            case details = "description"
        }
    }

    struct Stage: Decodable, Equatable {
        let id: Int
        let name: String?
        let createdAt: String?
        let updatedAt: String?

        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
    }

    struct Pagination: Decodable, Equatable {
        let currentPage: Int
        let lastPage: Int
        let total: Int

        private enum CodingKeys: String, CodingKey {
            case currentPage = "current_page"
            case lastPage = "last_page"
            case total
        }
    }
}
