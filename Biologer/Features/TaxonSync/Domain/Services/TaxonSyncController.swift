import Foundation

/// Coordinates the complete catalog lifecycle without owning API, CSV or Realm details.
///
/// A cycle is intentionally foreground/cooperative: pause waits for the current page,
/// and no iOS background task is scheduled here. The persisted checkpoint is what makes
/// a later resume safe after suspension or process termination.
actor TaxonSyncController: TaxonSyncControlling {
    typealias TimestampProvider = @Sendable () -> Int64

    private struct PendingUpdate {
        let firstPage: TaxonSyncPage
        let updatedAfter: Int64
        let startedAt: Int64
    }

    private let catalogRepository: TaxonCatalogRepository
    private let initialCatalogRepository: InitialTaxonCatalogRepository
    private let updatesRepository: TaxonUpdatesRepository
    private let metadataRepository: TaxonSyncMetadataRepository
    private let pageImporter: TaxonSyncPageImporter
    private let pageValidator: TaxonSyncPageValidator
    private let stateStore: TaxonSyncStateStore
    private let pageSize: Int
    private let timestampProvider: TimestampProvider

    private var pendingUpdates: [TaxonCatalogScope: PendingUpdate] = [:]
    private var pauseRequests: Set<TaxonCatalogScope> = []
    private var activeScope: TaxonCatalogScope?

    init(
        catalogRepository: TaxonCatalogRepository,
        initialCatalogRepository: InitialTaxonCatalogRepository,
        updatesRepository: TaxonUpdatesRepository,
        metadataRepository: TaxonSyncMetadataRepository,
        pageSize: Int,
        timestampProvider: @escaping TimestampProvider = {
            Int64(Date().timeIntervalSince1970)
        }
    ) {
        self.catalogRepository = catalogRepository
        self.initialCatalogRepository = initialCatalogRepository
        self.updatesRepository = updatesRepository
        self.metadataRepository = metadataRepository
        self.pageImporter = TaxonSyncPageImporter(
            catalogRepository: catalogRepository,
            metadataRepository: metadataRepository
        )
        self.pageValidator = TaxonSyncPageValidator()
        self.stateStore = TaxonSyncStateStore()
        self.pageSize = max(pageSize, 1)
        self.timestampProvider = timestampProvider
    }

    // MARK: - State and observation

    func state(
        scope: TaxonCatalogScope
    ) async -> TaxonSyncState {
        if let state = stateStore.state(for: scope) {
            return state
        }

        let state = makeInitialState(scope: scope)
        stateStore.store(state, scope: scope)
        return state
    }

    func observe(
        scope: TaxonCatalogScope
    ) async -> AsyncStream<TaxonSyncState> {
        let initialState = await state(scope: scope)
        return stateStore.stream(
            scope: scope,
            initialState: initialState
        ) { [weak self] observerID in
            Task {
                await self?.removeObserver(id: observerID)
            }
        }
    }

    // MARK: - Public controls

    func checkForUpdates(
        scope: TaxonCatalogScope
    ) async throws(TaxonSyncFailure) -> TaxonSyncCheckResult {
        guard activeScope == nil else {
            throw .operationInProgress
        }

        activeScope = scope
        defer {
            activeScope = nil
        }

        do {
            return try await performUpdateCheck(scope: scope)
        } catch {
            publishFailure(error, scope: scope)
            throw error
        }
    }

    func start(scope: TaxonCatalogScope) async {
        guard activeScope == nil else {
            return
        }

        activeScope = scope
        pauseRequests.remove(scope)
        defer {
            activeScope = nil
        }

        do {
            try await synchronize(scope: scope)
        } catch {
            publishFailure(error, scope: scope)
        }
    }

    func pause(scope: TaxonCatalogScope) async {
        pauseRequests.insert(scope)

        guard activeScope != scope else {
            return
        }

        do {
            let checkpoint = try metadataRepository
                .loadMetadata(scope: scope)
                .checkpoint

            guard let checkpoint else {
                return
            }

            publish(.paused(checkpoint.progress), scope: scope)
        } catch {
            publishFailure(error, scope: scope)
        }
    }

    func resume(scope: TaxonCatalogScope) async {
        pauseRequests.remove(scope)

        guard activeScope != scope else {
            return
        }

        await start(scope: scope)
    }

    // MARK: - Sync phases

    private func performUpdateCheck(
        scope: TaxonCatalogScope
    ) async throws(TaxonSyncFailure) -> TaxonSyncCheckResult {
        publish(.working(phase: .checking, progress: nil), scope: scope)

        var metadata = try metadataRepository.loadMetadata(scope: scope)

        if let checkpoint = metadata.checkpoint {
            let update = TaxonSyncUpdate(
                scope: scope,
                changedTaxaCount: checkpoint.totalTaxaCount,
                totalPages: checkpoint.totalPages
            )
            publish(.updateAvailable(update), scope: scope)
            return .updateAvailable(update)
        }

        // Keep this timestamp even if the user starts the actual import later.
        // It prevents changes made during a long cycle from being skipped.
        let startedAt = timestampProvider()
        let updatedAfter = metadata.effectiveUpdatedAfter
        let page = try await updatesRepository.fetchPage(
            scope: scope,
            request: TaxonSyncPageRequest(
                page: 1,
                perPage: pageSize,
                updatedAfter: updatedAfter
            )
        )
        try pageValidator.validate(page, expectedPage: 1)

        guard !page.entries.isEmpty else {
            metadata = try pageImporter.complete(
                metadata: metadata,
                startedAt: startedAt
            )
            pendingUpdates.removeValue(forKey: scope)

            let status = try makeStatus(
                scope: scope,
                metadata: metadata
            )
            publish(.completed(status), scope: scope)
            return .upToDate(status)
        }

        let update = TaxonSyncUpdate(
            scope: scope,
            changedTaxaCount: page.totalEntries,
            totalPages: page.lastPage
        )
        pendingUpdates[scope] = PendingUpdate(
            firstPage: page,
            updatedAfter: updatedAfter,
            startedAt: startedAt
        )
        publish(.updateAvailable(update), scope: scope)
        return .updateAvailable(update)
    }

    private func synchronize(
        scope: TaxonCatalogScope
    ) async throws(TaxonSyncFailure) {
        var metadata = try metadataRepository.loadMetadata(scope: scope)
        let localTaxaCount = try catalogRepository.count()

        // A deleted local catalog invalidates any old metadata for this active environment.
        if localTaxaCount == 0 {
            if metadata.initialCatalogTimestamp != nil
                || metadata.lastSuccessfulSyncTimestamp != nil
                || metadata.checkpoint != nil {
                metadata.initialCatalogTimestamp = nil
                metadata.lastSuccessfulSyncTimestamp = nil
                metadata.checkpoint = nil
                try metadataRepository.saveMetadata(metadata)
            }

            try loadInitialCatalogIfAvailable(
                scope: scope,
                metadata: &metadata
            )
        }

        try await synchronizeRemoteCatalog(
            scope: scope,
            metadata: metadata
        )
    }

    private func loadInitialCatalogIfAvailable(
        scope: TaxonCatalogScope,
        metadata: inout TaxonSyncMetadata
    ) throws(TaxonSyncFailure) {
        publish(
            .working(phase: .loadingInitialCatalog, progress: nil),
            scope: scope
        )

        let initialCatalog: InitialTaxonCatalog?

        do {
            initialCatalog = try initialCatalogRepository
                .loadInitialCatalog(scope: scope)
        } catch let failure {
            guard failure == .initialCatalogUnavailable else {
                throw failure
            }

            initialCatalog = nil
        }

        guard let initialCatalog else {
            return
        }

        publish(
            .working(phase: .importing, progress: nil),
            scope: scope
        )
        try catalogRepository.upsert(initialCatalog.entries)
        metadata.initialCatalogTimestamp = initialCatalog.updatedAt
        try metadataRepository.saveMetadata(metadata)
    }

    private func synchronizeRemoteCatalog(
        scope: TaxonCatalogScope,
        metadata initialMetadata: TaxonSyncMetadata
    ) async throws(TaxonSyncFailure) {
        var metadata = initialMetadata
        var nextPage: Int
        var importedTaxaCount: Int
        var updatedAfter: Int64
        var startedAt: Int64
        var knownProgress: TaxonSyncProgress?
        var cachedPage: TaxonSyncPage?

        // Priority is: persisted resume point, an in-memory checked page, then a new cycle.
        if let checkpoint = metadata.checkpoint {
            guard checkpoint.nextPage <= checkpoint.totalPages else {
                try completeSync(
                    scope: scope,
                    metadata: &metadata,
                    startedAt: checkpoint.startedAt
                )
                return
            }

            nextPage = checkpoint.nextPage
            importedTaxaCount = checkpoint.importedTaxaCount
            updatedAfter = checkpoint.updatedAfter
            startedAt = checkpoint.startedAt
            knownProgress = checkpoint.progress
        } else if let pendingUpdate = pendingUpdates[scope],
                  pendingUpdate.updatedAfter == metadata.effectiveUpdatedAfter {
            nextPage = 1
            importedTaxaCount = 0
            updatedAfter = pendingUpdate.updatedAfter
            startedAt = pendingUpdate.startedAt
            knownProgress = nil
            cachedPage = pendingUpdate.firstPage
        } else {
            pendingUpdates.removeValue(forKey: scope)
            nextPage = 1
            importedTaxaCount = 0
            updatedAfter = metadata.effectiveUpdatedAfter
            startedAt = timestampProvider()
            knownProgress = nil
        }

        while true {
            publish(
                .working(phase: .downloading, progress: knownProgress),
                scope: scope
            )
            await Task.yield()

            if pauseRequests.contains(scope) {
                publish(.paused(knownProgress), scope: scope)
                return
            }

            let page: TaxonSyncPage

            if let currentCachedPage = cachedPage {
                page = currentCachedPage
                cachedPage = nil
            } else {
                page = try await updatesRepository.fetchPage(
                    scope: scope,
                    request: TaxonSyncPageRequest(
                        page: nextPage,
                        perPage: pageSize,
                        updatedAfter: updatedAfter
                    )
                )
            }

            try pageValidator.validate(page, expectedPage: nextPage)

            guard !page.entries.isEmpty else {
                try completeSync(
                    scope: scope,
                    metadata: &metadata,
                    startedAt: startedAt
                )
                return
            }

            publish(
                .working(phase: .importing, progress: knownProgress),
                scope: scope
            )
            // PageImporter persists the checkpoint only after this page is in Realm.
            let importResult = try pageImporter.importPage(
                page,
                scope: scope,
                metadata: metadata,
                previouslyImportedTaxaCount: importedTaxaCount,
                pageSize: pageSize,
                updatedAfter: updatedAfter,
                startedAt: startedAt
            )
            metadata = importResult.metadata
            importedTaxaCount = importResult.importedTaxaCount
            pendingUpdates.removeValue(forKey: scope)

            if importResult.isComplete {
                try publishCompletedSync(
                    scope: scope,
                    metadata: metadata
                )
                return
            }

            guard let checkpoint = importResult.checkpoint else {
                throw .unknown
            }

            knownProgress = checkpoint.progress
            nextPage = checkpoint.nextPage

            if pauseRequests.contains(scope) {
                publish(.paused(knownProgress), scope: scope)
                return
            }
        }
    }

    private func completeSync(
        scope: TaxonCatalogScope,
        metadata: inout TaxonSyncMetadata,
        startedAt: Int64
    ) throws(TaxonSyncFailure) {
        metadata = try pageImporter.complete(
            metadata: metadata,
            startedAt: startedAt
        )
        pendingUpdates.removeValue(forKey: scope)

        try publishCompletedSync(scope: scope, metadata: metadata)
    }

    private func publishCompletedSync(
        scope: TaxonCatalogScope,
        metadata: TaxonSyncMetadata
    ) throws(TaxonSyncFailure) {
        let status = try makeStatus(
            scope: scope,
            metadata: metadata
        )
        publish(.completed(status), scope: scope)
    }

    private func makeInitialState(
        scope: TaxonCatalogScope
    ) -> TaxonSyncState {
        do {
            let metadata = try metadataRepository.loadMetadata(scope: scope)
            return .idle(
                try makeStatus(scope: scope, metadata: metadata)
            )
        } catch {
            return .failed(failure: error, progress: nil)
        }
    }

    private func makeStatus(
        scope: TaxonCatalogScope,
        metadata: TaxonSyncMetadata
    ) throws(TaxonSyncFailure) -> TaxonCatalogStatus {
        let localTaxaCount = try catalogRepository.count()
        let availability: TaxonCatalogAvailability

        if metadata.checkpoint != nil {
            availability = .partial
        } else if metadata.lastSuccessfulSyncTimestamp != nil {
            availability = .ready
        } else if localTaxaCount == 0 {
            availability = .empty
        } else if metadata.initialCatalogTimestamp != nil {
            availability = .initialCatalogLoaded
        } else {
            availability = .partial
        }

        return TaxonCatalogStatus(
            scope: scope,
            availability: availability,
            localTaxaCount: localTaxaCount,
            lastSuccessfulSyncTimestamp: metadata.lastSuccessfulSyncTimestamp
        )
    }

    private func publishFailure(
        _ failure: TaxonSyncFailure,
        scope: TaxonCatalogScope
    ) {
        let progress: TaxonSyncProgress?

        do {
            progress = try metadataRepository
                .loadMetadata(scope: scope)
                .checkpoint?
                .progress
        } catch {
            progress = nil
        }

        if failure == .networkUnavailable {
            publish(.waitingForNetwork(progress), scope: scope)
        } else {
            publish(
                .failed(failure: failure, progress: progress),
                scope: scope
            )
        }
    }

    private func publish(
        _ state: TaxonSyncState,
        scope: TaxonCatalogScope
    ) {
        stateStore.publish(state, scope: scope)
    }

    private func removeObserver(id: UUID) {
        stateStore.removeObserver(id: id)
    }
}
