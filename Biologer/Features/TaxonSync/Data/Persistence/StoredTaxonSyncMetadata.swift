struct StoredTaxonSyncMetadata: Codable, Equatable {
    let initialCatalogTimestamp: Int64?
    let lastSuccessfulSyncTimestamp: Int64?
    let checkpoint: Checkpoint?
}

extension StoredTaxonSyncMetadata {
    struct Checkpoint: Codable, Equatable {
        let nextPage: Int
        let perPage: Int
        let totalPages: Int
        let totalTaxaCount: Int
        let importedTaxaCount: Int
        let updatedAfter: Int64
        let startedAt: Int64
    }
}
