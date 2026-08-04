final class EnvironmentTaxonCatalogScopeProvider: TaxonCatalogScopeProviding {
    private let environmentStorage: EnvironmentStorage

    init(environmentStorage: EnvironmentStorage) {
        self.environmentStorage = environmentStorage
    }

    func currentScope() -> TaxonCatalogScope? {
        guard let environment = environmentStorage.getEnvironment() else {
            return nil
        }

        return TaxonCatalogScope(environmentHost: environment.host)
    }
}
