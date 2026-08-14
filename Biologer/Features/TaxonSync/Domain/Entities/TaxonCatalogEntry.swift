struct TaxonCatalogEntry: Identifiable, Equatable, Sendable {
    /// Stable server identifier used to match and upsert the taxon locally.
    let id: Int

    /// Scientific or canonical name used as the taxon's primary display value.
    let name: String

    /// Taxonomic rank name, such as species, genus or family.
    let rank: String?

    /// Numeric position of the rank in the taxonomic hierarchy.
    let rankLevel: Int?

    /// Indicates that observations of this taxon require restricted-data handling.
    let isRestricted: Bool?

    /// Indicates that the taxon is non-native to the catalog's geographic scope.
    let isAllochthonous: Bool?

    /// Indicates that the taxon is classified as invasive.
    let isInvasive: Bool?

    /// Determines whether findings for this taxon use atlas-code selection.
    let usesAtlasCodes: Bool?

    /// Flattened names of the taxon's ancestors in the classification hierarchy.
    let ancestorNames: String?

    /// Server-reported permission to edit this taxon.
    let canEdit: Bool?

    /// Server-reported permission to delete this taxon.
    let canDelete: Bool?

    /// Localized display name of the taxonomic rank.
    let rankTranslation: String?

    /// Common or native taxon name from the primary API representation.
    let nativeName: String?

    /// Descriptive text from the primary API representation.
    let details: String?

    /// Locale-specific common names and descriptions available for the taxon.
    let translations: [TaxonCatalogTranslation]

    /// Life or development stages that may be selected for a finding.
    let stages: [TaxonCatalogStage]
}

struct TaxonCatalogTranslation: Identifiable, Equatable, Sendable {
    /// Stable server identifier of the translation record.
    let id: Int

    /// Locale or language code to which the translated content belongs.
    let locale: String?

    /// Common taxon name translated for the specified locale.
    let nativeName: String?

    /// Taxon description translated for the specified locale.
    let details: String?
}

struct TaxonCatalogStage: Identifiable, Equatable, Sendable {
    /// Stable server identifier of the stage.
    let id: Int

    /// Display name of the life or development stage.
    let name: String?

    /// Server-provided creation timestamp in its original textual format.
    let createdAt: String?

    /// Server-provided last-update timestamp in its original textual format.
    let updatedAt: String?
}

struct InitialTaxonCatalog: Equatable, Sendable {
    /// Complete baseline entries parsed from the bundled initial catalog.
    let entries: [TaxonCatalogEntry]

    /// Version timestamp of the bundled catalog, used as the first remote-sync baseline.
    let updatedAt: Int64
}
