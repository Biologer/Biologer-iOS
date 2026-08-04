import Foundation

final class CSVInitialTaxonCatalogRepository: InitialTaxonCatalogRepository {
    private let bundle: Bundle
    private let parser: TaxonCatalogCSVParsing
    private let fileResolver: InitialTaxonCatalogFileResolver
    private let initialCatalogTimestamp: Int64

    init(
        bundle: Bundle = .main,
        parser: TaxonCatalogCSVParsing = TaxonCatalogCSVParser(),
        fileResolver: InitialTaxonCatalogFileResolver = InitialTaxonCatalogFileResolver(),
        initialCatalogTimestamp: Int64 = APIConstants.filesTimestamp
    ) {
        self.bundle = bundle
        self.parser = parser
        self.fileResolver = fileResolver
        self.initialCatalogTimestamp = initialCatalogTimestamp
    }

    func loadInitialCatalog(
        scope: TaxonCatalogScope
    ) throws(TaxonSyncFailure) -> InitialTaxonCatalog? {
        let resourceName = fileResolver.resourceName(for: scope)

        guard let fileURL = bundle.url(
            forResource: resourceName,
            withExtension: "csv"
        ), let stream = InputStream(url: fileURL) else {
            return nil
        }

        defer {
            stream.close()
        }

        do {
            let entries = try parser.parse(stream: stream)

            guard !entries.isEmpty else {
                return nil
            }

            return InitialTaxonCatalog(
                entries: entries,
                updatedAt: initialCatalogTimestamp
            )
        } catch {
            throw .initialCatalogUnavailable
        }
    }
}
