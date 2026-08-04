final class APITaxonUpdatesRepository: TaxonUpdatesRepository {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchPage(
        scope: TaxonCatalogScope,
        request: TaxonSyncPageRequest
    ) async throws(TaxonSyncFailure) -> TaxonSyncPage {
        let endpoint = TaxonUpdatesEndpoint(
            host: scope.environmentHost,
            request: request
        )

        do {
            return try await client.send(endpoint).asDomain
        } catch let error as APIClientError {
            throw error.asTaxonSyncFailure
        } catch {
            throw .unknown
        }
    }
}
