struct TaxonCatalogScope: Hashable, Sendable {
    /// API environment whose catalog, sync state and persisted metadata are being used.
    let environmentHost: String
}
