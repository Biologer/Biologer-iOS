import Foundation

final class UserDefaultsTaxonSyncMetadataRepository: TaxonSyncMetadataRepository {
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let keyPrefix: String

    init(
        userDefaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder(),
        keyPrefix: String = "taxonSync.metadata"
    ) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
        self.keyPrefix = keyPrefix
    }

    func loadMetadata(
        scope: TaxonCatalogScope
    ) throws(TaxonSyncFailure) -> TaxonSyncMetadata {
        guard let data = userDefaults.data(forKey: key(for: scope)) else {
            return emptyMetadata(scope: scope)
        }

        do {
            let storedMetadata = try decoder.decode(
                StoredTaxonSyncMetadata.self,
                from: data
            )
            return StoredTaxonSyncMetadataMapper.makeDomainMetadata(
                from: storedMetadata,
                scope: scope
            )
        } catch {
            throw .localPersistence
        }
    }

    func saveMetadata(
        _ metadata: TaxonSyncMetadata
    ) throws(TaxonSyncFailure) {
        do {
            let storedMetadata = StoredTaxonSyncMetadataMapper
                .makeStoredMetadata(from: metadata)
            let data = try encoder.encode(storedMetadata)
            userDefaults.set(data, forKey: key(for: metadata.scope))
        } catch {
            throw .localPersistence
        }
    }

    func clearMetadata(
        scope: TaxonCatalogScope
    ) throws(TaxonSyncFailure) {
        userDefaults.removeObject(forKey: key(for: scope))
    }

    private func emptyMetadata(
        scope: TaxonCatalogScope
    ) -> TaxonSyncMetadata {
        TaxonSyncMetadata(
            scope: scope,
            initialCatalogTimestamp: nil,
            lastSuccessfulSyncTimestamp: nil,
            checkpoint: nil
        )
    }

    private func key(for scope: TaxonCatalogScope) -> String {
        "\(keyPrefix).\(scope.environmentHost)"
    }
}
