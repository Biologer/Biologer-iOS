final class EnvironmentTaxonCatalogScopeProvider: TaxonCatalogScopeProviding {
    private let environmentProvider: CurrentEnvironmentProviding

    init(environmentProvider: CurrentEnvironmentProviding) {
        self.environmentProvider = environmentProvider
    }

    func currentScope() -> TaxonCatalogScope? {
        guard let environment = environmentProvider.currentEnvironment() else {
            return nil
        }

        return TaxonCatalogScope(environmentHost: environment.host)
    }
}
