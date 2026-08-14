/// Describes how complete the local catalog is, independently of an active sync operation.
enum TaxonCatalogAvailability: Equatable, Sendable {
    /// No taxon entries are stored locally.
    case empty

    /// The complete bundled baseline is available, but remote sync has not yet completed.
    case initialCatalogLoaded

    /// Some entries exist, but no complete local baseline can be proven.
    case partial

    /// A complete remote sync has succeeded and the local catalog can be used.
    case ready

    /// A complete local baseline is enough to use the app without a network.
    /// An interrupted update does not invalidate an initial or previously synced catalog.
    var isUsable: Bool {
        switch self {
        case .initialCatalogLoaded, .ready:
            return true
        case .empty, .partial:
            return false
        }
    }
}

struct TaxonCatalogStatus: Equatable, Sendable {
    /// Catalog environment described by this status.
    let scope: TaxonCatalogScope

    /// Completeness and usability of the locally stored catalog.
    let availability: TaxonCatalogAvailability

    /// Current number of taxon entries stored in the local database.
    let localTaxaCount: Int

    /// Start timestamp of the latest remote sync that completed successfully.
    let lastSuccessfulSyncTimestamp: Int64?
}

struct TaxonSyncUpdate: Equatable, Sendable {
    /// Catalog environment for which the update was found.
    let scope: TaxonCatalogScope

    /// Total number of changed taxon records reported by the API.
    let changedTaxaCount: Int

    /// Number of pages required to download the reported changes.
    let totalPages: Int
}

enum TaxonSyncCheckResult: Equatable, Sendable {
    /// No remote changes exist and the included local status is current.
    case upToDate(TaxonCatalogStatus)

    /// Remote changes exist and can be downloaded by starting the sync.
    case updateAvailable(TaxonSyncUpdate)
}

enum TaxonSyncPhase: Equatable, Sendable {
    /// Resolving and parsing the bundled CSV catalog.
    case loadingInitialCatalog

    /// Requesting the first API page to determine whether changes exist.
    case checking

    /// Fetching a page of taxon changes from the API.
    case downloading

    /// Persisting catalog entries and the corresponding resume checkpoint.
    case importing
}

enum TaxonSyncFailure: Error, Equatable, Sendable {
    /// Another catalog operation already owns the controller.
    case operationInProgress

    /// The updates API cannot currently be reached.
    case networkUnavailable

    /// The server rejected the current authentication credentials.
    case unauthorized

    /// The API response cannot safely be used for the expected page.
    case invalidResponse

    /// The bundled CSV catalog is missing or cannot be parsed.
    case initialCatalogUnavailable

    /// Local Realm or metadata persistence failed.
    case localPersistence

    /// The underlying failure could not be classified more precisely.
    case unknown
}

/// Describes the operation independently of whether the local catalog is usable.
enum TaxonSyncOperation: Equatable, Sendable {
    /// No catalog operation is currently running.
    case idle

    /// Work is active in the supplied phase, optionally with known progress.
    case working(phase: TaxonSyncPhase, progress: TaxonSyncProgress?)

    /// An update check found remote changes that are ready to be downloaded.
    case updateAvailable(TaxonSyncUpdate)

    /// Sync stopped because the network is unavailable and can be retried later.
    case waitingForNetwork(TaxonSyncProgress?)

    /// Sync stopped at a safely persisted page boundary after a user request.
    case paused(TaxonSyncProgress?)

    /// The current check or synchronization cycle completed successfully.
    case completed

    /// Sync stopped because of a non-network failure, preserving any known progress.
    case failed(failure: TaxonSyncFailure, progress: TaxonSyncProgress?)
}

/// Runtime state exposed to all TaxonSync entry points (startup, Settings and Search).
/// Catalog readiness remains available while an operation is working, paused or failed.
struct TaxonSyncState: Equatable, Sendable {
    /// Latest known local-catalog status, independent of the active operation.
    let catalogStatus: TaxonCatalogStatus?

    /// Current runtime operation exposed to startup, Settings and Search observers.
    let operation: TaxonSyncOperation

    /// Indicates whether the current local catalog is complete enough for offline use.
    var hasUsableCatalog: Bool {
        catalogStatus?.availability.isUsable == true
    }
}
