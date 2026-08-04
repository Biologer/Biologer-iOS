/// Describes how complete the local catalog is, independently of an active sync operation.
enum TaxonCatalogAvailability: Equatable, Sendable {
    case empty
    case initialCatalogLoaded
    case partial
    case ready
}

struct TaxonCatalogStatus: Equatable, Sendable {
    let scope: TaxonCatalogScope
    let availability: TaxonCatalogAvailability
    let localTaxaCount: Int
    let lastSuccessfulSyncTimestamp: Int64?
}

struct TaxonSyncUpdate: Equatable, Sendable {
    let scope: TaxonCatalogScope
    let changedTaxaCount: Int
    let totalPages: Int
}

enum TaxonSyncCheckResult: Equatable, Sendable {
    case upToDate(TaxonCatalogStatus)
    case updateAvailable(TaxonSyncUpdate)
}

enum TaxonSyncPhase: Equatable, Sendable {
    case loadingInitialCatalog
    case checking
    case downloading
    case importing
}

enum TaxonSyncFailure: Error, Equatable, Sendable {
    case operationInProgress
    case networkUnavailable
    case unauthorized
    case invalidResponse
    case initialCatalogUnavailable
    case localPersistence
    case unknown
}

/// Runtime state exposed to all TaxonSync entry points (startup, Settings and Search).
enum TaxonSyncState: Equatable, Sendable {
    case idle(TaxonCatalogStatus)
    case working(phase: TaxonSyncPhase, progress: TaxonSyncProgress?)
    case updateAvailable(TaxonSyncUpdate)
    case waitingForNetwork(TaxonSyncProgress?)
    case paused(TaxonSyncProgress?)
    case completed(TaxonCatalogStatus)
    case failed(failure: TaxonSyncFailure, progress: TaxonSyncProgress?)
}
