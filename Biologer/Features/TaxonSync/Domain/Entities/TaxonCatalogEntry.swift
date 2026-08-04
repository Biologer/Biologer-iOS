struct TaxonCatalogEntry: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
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
    let translations: [TaxonCatalogTranslation]
    let stages: [TaxonCatalogStage]
}

struct TaxonCatalogTranslation: Identifiable, Equatable, Sendable {
    let id: Int
    let locale: String?
    let nativeName: String?
    let details: String?
}

struct TaxonCatalogStage: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String?
    let createdAt: String?
    let updatedAt: String?
}

struct InitialTaxonCatalog: Equatable, Sendable {
    let entries: [TaxonCatalogEntry]
    let updatedAt: Int64
}
