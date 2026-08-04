/// Composition output shared by all future TaxonSync entry points.
/// The controller is intentionally hidden; consumers depend on use-case protocols.
struct TaxonSyncComposition {
    let useCases: TaxonSyncUseCases
    let scopeProvider: TaxonCatalogScopeProviding
}
