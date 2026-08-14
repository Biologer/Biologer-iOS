import XCTest
@testable import Biologer

final class TaxonSyncControllerTests: XCTestCase {
    func test_start_whenNetworkIsUnavailable_keepsInitialCatalogUsable() async {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let catalogRepository = TaxonCatalogRepositoryStub()
        let metadataRepository = TaxonSyncMetadataRepositoryStub(scope: scope)
        let sut = TaxonSyncController(
            catalogRepository: catalogRepository,
            initialCatalogRepository: InitialTaxonCatalogRepositoryStub(
                catalog: InitialTaxonCatalog(
                    entries: [makeEntry()],
                    updatedAt: 100
                )
            ),
            updatesRepository: OfflineTaxonUpdatesRepositoryStub(),
            metadataRepository: metadataRepository,
            pageSize: 100
        )

        await sut.start(scope: scope)
        let state = await sut.state(scope: scope)

        XCTAssertEqual(state.operation, .waitingForNetwork(nil))
        XCTAssertEqual(
            state.catalogStatus?.availability,
            .initialCatalogLoaded
        )
        XCTAssertTrue(state.hasUsableCatalog)
        XCTAssertEqual(try? catalogRepository.count(), 1)
    }

    func test_state_withInterruptedUpdate_keepsPreviouslySyncedCatalogReady() async {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let checkpoint = TaxonSyncCheckpoint(
            scope: scope,
            nextPage: 2,
            perPage: 100,
            totalPages: 3,
            totalTaxaCount: 250,
            importedTaxaCount: 100,
            updatedAfter: 100,
            startedAt: 200
        )
        let catalogRepository = TaxonCatalogRepositoryStub(entryCount: 250)
        let metadataRepository = TaxonSyncMetadataRepositoryStub(
            metadata: TaxonSyncMetadata(
                scope: scope,
                initialCatalogTimestamp: 50,
                lastSuccessfulSyncTimestamp: 100,
                checkpoint: checkpoint
            )
        )
        let sut = TaxonSyncController(
            catalogRepository: catalogRepository,
            initialCatalogRepository: InitialTaxonCatalogRepositoryStub(
                catalog: nil
            ),
            updatesRepository: OfflineTaxonUpdatesRepositoryStub(),
            metadataRepository: metadataRepository,
            pageSize: 100
        )

        let state = await sut.state(scope: scope)

        XCTAssertEqual(state.catalogStatus?.availability, .ready)
        XCTAssertTrue(state.hasUsableCatalog)
    }

    func test_state_afterCatalogReset_doesNotReuseCachedReadiness() async throws {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let catalogRepository = TaxonCatalogRepositoryStub(entryCount: 100)
        let metadataRepository = TaxonSyncMetadataRepositoryStub(
            metadata: TaxonSyncMetadata(
                scope: scope,
                initialCatalogTimestamp: 50,
                lastSuccessfulSyncTimestamp: 100,
                checkpoint: nil
            )
        )
        let update = TaxonSyncPage(
            entries: [makeEntry()],
            currentPage: 1,
            lastPage: 1,
            totalEntries: 1
        )
        let sut = TaxonSyncController(
            catalogRepository: catalogRepository,
            initialCatalogRepository: InitialTaxonCatalogRepositoryStub(
                catalog: nil
            ),
            updatesRepository: TaxonUpdatesRepositoryStub(page: update),
            metadataRepository: metadataRepository,
            pageSize: 100
        )

        _ = try await sut.checkForUpdates(scope: scope)
        let stateBeforeReset = await sut.state(scope: scope)
        XCTAssertTrue(stateBeforeReset.hasUsableCatalog)

        try catalogRepository.deleteAll()
        try metadataRepository.clearMetadata(scope: scope)
        let state = await sut.state(scope: scope)

        XCTAssertEqual(state.catalogStatus?.availability, .empty)
        XCTAssertFalse(state.hasUsableCatalog)
    }

    func test_start_withCheckpoint_resumesPersistedRequestCursor() async throws {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let checkpoint = TaxonSyncCheckpoint(
            scope: scope,
            nextPage: 2,
            perPage: 50,
            totalPages: 2,
            totalTaxaCount: 2,
            importedTaxaCount: 1,
            updatedAfter: 100,
            startedAt: 200
        )
        let catalogRepository = TaxonCatalogRepositoryStub(entryCount: 1)
        let metadataRepository = TaxonSyncMetadataRepositoryStub(
            metadata: TaxonSyncMetadata(
                scope: scope,
                initialCatalogTimestamp: 50,
                lastSuccessfulSyncTimestamp: nil,
                checkpoint: checkpoint
            )
        )
        let updatesRepository = RecordingTaxonUpdatesRepositoryStub(
            pages: [
                2: TaxonSyncPage(
                    entries: [makeEntry(id: 2)],
                    currentPage: 2,
                    lastPage: 2,
                    totalEntries: 2
                )
            ]
        )
        let sut = TaxonSyncController(
            catalogRepository: catalogRepository,
            initialCatalogRepository: InitialTaxonCatalogRepositoryStub(
                catalog: nil
            ),
            updatesRepository: updatesRepository,
            metadataRepository: metadataRepository,
            pageSize: 100,
            timestampProvider: { 999 }
        )

        await sut.start(scope: scope)

        let requests = await updatesRepository.recordedRequests()
        XCTAssertEqual(
            requests,
            [
                TaxonSyncPageRequest(
                    page: 2,
                    perPage: 50,
                    updatedAfter: 100
                )
            ]
        )
        XCTAssertEqual(try catalogRepository.count(), 2)

        let metadata = try metadataRepository.loadMetadata(scope: scope)
        XCTAssertEqual(metadata.lastSuccessfulSyncTimestamp, 200)
        XCTAssertNil(metadata.checkpoint)

        let state = await sut.state(scope: scope)
        XCTAssertEqual(state.operation, .idle)
        XCTAssertEqual(state.catalogStatus?.availability, .ready)
    }

    func test_start_afterUpdateCheck_reusesDownloadedFirstPage() async throws {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let catalogRepository = TaxonCatalogRepositoryStub(entryCount: 1)
        let metadataRepository = TaxonSyncMetadataRepositoryStub(
            metadata: TaxonSyncMetadata(
                scope: scope,
                initialCatalogTimestamp: 50,
                lastSuccessfulSyncTimestamp: 100,
                checkpoint: nil
            )
        )
        let updatesRepository = RecordingTaxonUpdatesRepositoryStub(
            pages: [
                1: TaxonSyncPage(
                    entries: [makeEntry(id: 2)],
                    currentPage: 1,
                    lastPage: 2,
                    totalEntries: 2
                ),
                2: TaxonSyncPage(
                    entries: [makeEntry(id: 3)],
                    currentPage: 2,
                    lastPage: 2,
                    totalEntries: 2
                )
            ]
        )
        let sut = TaxonSyncController(
            catalogRepository: catalogRepository,
            initialCatalogRepository: InitialTaxonCatalogRepositoryStub(
                catalog: nil
            ),
            updatesRepository: updatesRepository,
            metadataRepository: metadataRepository,
            pageSize: 100,
            timestampProvider: { 200 }
        )

        _ = try await sut.checkForUpdates(scope: scope)
        await sut.start(scope: scope)

        let requests = await updatesRepository.recordedRequests()
        XCTAssertEqual(requests.map(\.page), [1, 2])
        XCTAssertEqual(requests.map(\.updatedAfter), [100, 100])
        XCTAssertEqual(try catalogRepository.count(), 3)

        let metadata = try metadataRepository.loadMetadata(scope: scope)
        XCTAssertEqual(metadata.lastSuccessfulSyncTimestamp, 200)
        XCTAssertNil(metadata.checkpoint)
    }

    func test_pause_duringPageDownload_stopsAfterPageAndCheckpointAreSaved() async throws {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let catalogRepository = TaxonCatalogRepositoryStub(entryCount: 1)
        let metadataRepository = TaxonSyncMetadataRepositoryStub(
            metadata: TaxonSyncMetadata(
                scope: scope,
                initialCatalogTimestamp: 50,
                lastSuccessfulSyncTimestamp: 100,
                checkpoint: nil
            )
        )
        let updatesRepository = SuspendedTaxonUpdatesRepositoryStub(
            page: TaxonSyncPage(
                entries: [makeEntry(id: 2)],
                currentPage: 1,
                lastPage: 2,
                totalEntries: 2
            )
        )
        let sut = TaxonSyncController(
            catalogRepository: catalogRepository,
            initialCatalogRepository: InitialTaxonCatalogRepositoryStub(
                catalog: nil
            ),
            updatesRepository: updatesRepository,
            metadataRepository: metadataRepository,
            pageSize: 100,
            timestampProvider: { 200 }
        )

        let syncTask = Task {
            await sut.start(scope: scope)
        }
        await updatesRepository.waitUntilRequestStarts()

        await sut.pause(scope: scope)
        await updatesRepository.completeRequest()
        await syncTask.value

        XCTAssertEqual(try catalogRepository.count(), 2)

        let expectedProgress = TaxonSyncProgress(
            completedPages: 1,
            totalPages: 2,
            importedTaxaCount: 1,
            totalTaxaCount: 2
        )
        let metadata = try metadataRepository.loadMetadata(scope: scope)
        XCTAssertEqual(metadata.checkpoint?.nextPage, 2)
        XCTAssertEqual(metadata.checkpoint?.progress, expectedProgress)

        let state = await sut.state(scope: scope)
        XCTAssertEqual(state.operation, .paused(expectedProgress))
    }

    private func makeEntry(id: Int = 1) -> TaxonCatalogEntry {
        TaxonCatalogEntry(
            id: id,
            name: "Taxon",
            rank: nil,
            rankLevel: nil,
            isRestricted: nil,
            isAllochthonous: nil,
            isInvasive: nil,
            usesAtlasCodes: nil,
            ancestorNames: nil,
            canEdit: nil,
            canDelete: nil,
            rankTranslation: nil,
            nativeName: nil,
            details: nil,
            translations: [],
            stages: []
        )
    }
}

private final class TaxonCatalogRepositoryStub: TaxonCatalogRepository {
    private var entryCount: Int

    init(entryCount: Int = 0) {
        self.entryCount = entryCount
    }

    func count() throws(TaxonSyncFailure) -> Int {
        entryCount
    }

    func upsert(_ entries: [TaxonCatalogEntry]) throws(TaxonSyncFailure) {
        entryCount += entries.count
    }

    func deleteAll() throws(TaxonSyncFailure) {
        entryCount = 0
    }
}

private struct InitialTaxonCatalogRepositoryStub:
    InitialTaxonCatalogRepository {
    let catalog: InitialTaxonCatalog?

    func loadInitialCatalog(
        scope: TaxonCatalogScope
    ) throws(TaxonSyncFailure) -> InitialTaxonCatalog? {
        catalog
    }
}

private struct OfflineTaxonUpdatesRepositoryStub: TaxonUpdatesRepository {
    func fetchPage(
        scope: TaxonCatalogScope,
        request: TaxonSyncPageRequest
    ) async throws(TaxonSyncFailure) -> TaxonSyncPage {
        throw .networkUnavailable
    }
}

private struct TaxonUpdatesRepositoryStub: TaxonUpdatesRepository {
    let page: TaxonSyncPage

    func fetchPage(
        scope: TaxonCatalogScope,
        request: TaxonSyncPageRequest
    ) async throws(TaxonSyncFailure) -> TaxonSyncPage {
        page
    }
}

private actor RecordingTaxonUpdatesRepositoryStub: TaxonUpdatesRepository {
    private let pages: [Int: TaxonSyncPage]
    private var requests: [TaxonSyncPageRequest] = []

    init(pages: [Int: TaxonSyncPage]) {
        self.pages = pages
    }

    func fetchPage(
        scope: TaxonCatalogScope,
        request: TaxonSyncPageRequest
    ) async throws(TaxonSyncFailure) -> TaxonSyncPage {
        requests.append(request)

        guard let page = pages[request.page] else {
            throw .invalidResponse
        }

        return page
    }

    func recordedRequests() -> [TaxonSyncPageRequest] {
        requests
    }
}

private actor SuspendedTaxonUpdatesRepositoryStub: TaxonUpdatesRepository {
    private let page: TaxonSyncPage
    private var didStartRequest = false
    private var requestWaiters: [CheckedContinuation<Void, Never>] = []
    private var responseContinuation: CheckedContinuation<TaxonSyncPage, Never>?

    init(page: TaxonSyncPage) {
        self.page = page
    }

    func fetchPage(
        scope: TaxonCatalogScope,
        request: TaxonSyncPageRequest
    ) async throws(TaxonSyncFailure) -> TaxonSyncPage {
        didStartRequest = true
        requestWaiters.forEach { $0.resume() }
        requestWaiters.removeAll()

        return await withCheckedContinuation { continuation in
            responseContinuation = continuation
        }
    }

    func waitUntilRequestStarts() async {
        guard !didStartRequest else {
            return
        }

        await withCheckedContinuation { continuation in
            requestWaiters.append(continuation)
        }
    }

    func completeRequest() {
        responseContinuation?.resume(returning: page)
        responseContinuation = nil
    }
}

private final class TaxonSyncMetadataRepositoryStub:
    TaxonSyncMetadataRepository {
    private var metadata: TaxonSyncMetadata

    init(scope: TaxonCatalogScope) {
        self.metadata = TaxonSyncMetadata(
            scope: scope,
            initialCatalogTimestamp: nil,
            lastSuccessfulSyncTimestamp: nil,
            checkpoint: nil
        )
    }

    init(metadata: TaxonSyncMetadata) {
        self.metadata = metadata
    }

    func loadMetadata(
        scope: TaxonCatalogScope
    ) throws(TaxonSyncFailure) -> TaxonSyncMetadata {
        metadata
    }

    func saveMetadata(
        _ metadata: TaxonSyncMetadata
    ) throws(TaxonSyncFailure) {
        self.metadata = metadata
    }

    func clearMetadata(
        scope: TaxonCatalogScope
    ) throws(TaxonSyncFailure) {
        metadata = TaxonSyncMetadata(
            scope: scope,
            initialCatalogTimestamp: nil,
            lastSuccessfulSyncTimestamp: nil,
            checkpoint: nil
        )
    }
}
