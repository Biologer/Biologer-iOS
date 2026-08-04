struct InitialTaxonCatalogFileResolver {
    func resourceName(for scope: TaxonCatalogScope) -> String? {
        let fileIdentifier: String

        switch scope.environmentHost {
        case APIConstants.serbiaHost:
            fileIdentifier = "rs"
        case APIConstants.croatiaHost:
            fileIdentifier = "hr"
        case APIConstants.bosnianAndHerzegovinHost:
            fileIdentifier = "ba"
        case APIConstants.montenegroHost:
            fileIdentifier = "me"
        case APIConstants.devHost:
            fileIdentifier = "dev"
        default:
            return nil
        }

        return "\(fileIdentifier)_taxa"
    }
}
