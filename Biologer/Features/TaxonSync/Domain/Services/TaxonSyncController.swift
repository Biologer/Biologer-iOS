import Foundation

/// Coordinates the complete catalog lifecycle without owning API, CSV or Realm details.
///
/// A cycle is intentionally foreground/cooperative: pause waits for the current page,
/// and no iOS background task is scheduled here. The persisted checkpoint is what makes
/// a later resume safe after suspension or process termination.
actor TaxonSyncController: TaxonSyncService {
    typealias TimestampProvider = @Sendable () -> Int64

    private let catalogRepository: TaxonCatalogRepository
    private let initialCatalogRepository: InitialTaxonCatalogRepository
    private let updatesRepository: TaxonUpdatesRepository
    private let metadataRepository: TaxonSyncMetadataRepository
    private let pageImporter: TaxonSyncPageImporter
    private let pageValidator: TaxonSyncPageValidator
    private let stateStore: TaxonSyncStateStore
    private let pageSize: Int
    private let timestampProvider: TimestampProvider

    private var pendingUpdates: [TaxonCatalogScope: TaxonSyncPendingUpdate] = [:]
    private var requestedPauseScopes: Set<TaxonCatalogScope> = []
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
        if let cachedState = stateStore.state(for: scope) {
            switch cachedState.operation {
            case .working, .updateAvailable, .waitingForNetwork, .paused:
                let refreshedState = makeState(
                    scope: scope,
                    operation: cachedState.operation
                )
                stateStore.store(refreshedState, scope: scope)
                return refreshedState
            case .idle, .completed, .failed:
                break
            }
        }

        // Catalog readiness is rebuilt whenever an entry point opens. Transient
        // operation state is preserved, while reset/logout changes remain visible.
        let state = makeState(scope: scope, operation: .idle)
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
        ) { [weak self] subscriptionID in
            Task {
                await self?.removeSubscription(id: subscriptionID)
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
        requestedPauseScopes.remove(scope)
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
        requestedPauseScopes.insert(scope)

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
        requestedPauseScopes.remove(scope)

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
        if try catalogRepository.count() == 0 {
            metadata = try resetMetadataForEmptyCatalog(
                scope: scope,
                metadata: metadata
            )
        }

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
            publish(
                .completed,
                catalogStatus: status,
                scope: scope
            )
            return .upToDate(status)
        }

        let update = TaxonSyncUpdate(
            scope: scope,
            changedTaxaCount: page.totalEntries,
            totalPages: page.lastPage
        )
        pendingUpdates[scope] = TaxonSyncPendingUpdate(
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
            metadata = try resetMetadataForEmptyCatalog(
                scope: scope,
                metadata: metadata
            )

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
        var cycle = try makeRemoteSyncCycle(
            scope: scope,
            metadata: initialMetadata
        )

        // Each iteration owns one page. It exits only after a safe persisted boundary:
        // no changes, final page committed, pause requested, or an error is thrown.
        while true {
            publish(
                .working(phase: .downloading, progress: cycle.progress),
                scope: scope
            )

            // Publishing and Realm work are synchronous actor-isolated calls. Yielding
            // here gives a queued `pause` call a chance to record its request before
            // the next page begins, including when the first page is already cached.
            await Task.yield()

            if pauseSyncIfRequested(
                scope: scope,
                progress: cycle.progress
            ) {
                return
            }

            let page = try await fetchNextRemotePage(
                scope: scope,
                cachedPage: cycle.consumeCachedPage(),
                request: cycle.request
            )

            try pageValidator.validate(
                page,
                expectedPage: cycle.nextPage
            )

            guard !page.entries.isEmpty else {
                try completeSync(
                    scope: scope,
                    metadata: &cycle.metadata,
                    startedAt: cycle.startedAt
                )
                return
            }

            publish(
                .working(phase: .importing, progress: cycle.progress),
                scope: scope
            )

            // PageImporter persists the checkpoint only after this page is in Realm.
            let importResult = try pageImporter.importPage(
                page,
                scope: scope,
                metadata: cycle.metadata,
                previouslyImportedTaxaCount: cycle.importedTaxaCount,
                pageSize: cycle.pageSize,
                updatedAfter: cycle.updatedAfter,
                startedAt: cycle.startedAt
            )
            pendingUpdates.removeValue(forKey: scope)

            let didCompleteCycle = cycle.advance(after: importResult)
            if didCompleteCycle {
                try publishCompletedSync(
                    scope: scope,
                    metadata: cycle.metadata
                )
                return
            }

            // A page already in Realm is never rolled back. Pause only after its
            // checkpoint has been saved, so resume can continue with the next page.
            if pauseSyncIfRequested(
                scope: scope,
                progress: cycle.progress
            ) {
                return
            }
        }
    }

    private func makeRemoteSyncCycle(
        scope: TaxonCatalogScope,
        metadata initialMetadata: TaxonSyncMetadata
    ) throws(TaxonSyncFailure) -> TaxonRemoteSyncCycle {
        var metadata = initialMetadata

        // Corrupted or obsolete resume data must not influence a new cycle.
        if let checkpoint = metadata.checkpoint,
           !checkpoint.isValid {
            metadata.checkpoint = nil
            try metadataRepository.saveMetadata(metadata)
        }

        // A persisted checkpoint is the strongest source because it survives process
        // termination and describes the exact next page and request baseline.
        if let resumedCycle = TaxonRemoteSyncCycle(
            resuming: metadata
        ) {
            return resumedCycle
        }

        // `checkForUpdates` may already have downloaded page one. It is safe to reuse
        // only while its `updatedAfter` baseline still matches the current metadata.
        if let pendingUpdate = pendingUpdates[scope],
           pendingUpdate.updatedAfter == metadata.effectiveUpdatedAfter {
            return TaxonRemoteSyncCycle(
                metadata: metadata,
                pendingUpdate: pendingUpdate,
                pageSize: pageSize
            )
        }

        pendingUpdates.removeValue(forKey: scope)
        return TaxonRemoteSyncCycle(
            metadata: metadata,
            pageSize: pageSize,
            startedAt: timestampProvider()
        )
    }

    private func fetchNextRemotePage(
        scope: TaxonCatalogScope,
        cachedPage: TaxonSyncPage?,
        request: TaxonSyncPageRequest
    ) async throws(TaxonSyncFailure) -> TaxonSyncPage {
        if let cachedPage {
            return cachedPage
        }

        return try await updatesRepository.fetchPage(
            scope: scope,
            request: request
        )
    }

    private func pauseSyncIfRequested(
        scope: TaxonCatalogScope,
        progress: TaxonSyncProgress?
    ) -> Bool {
        guard requestedPauseScopes.contains(scope) else {
            return false
        }

        publish(.paused(progress), scope: scope)
        return true
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
        publish(
            .completed,
            catalogStatus: status,
            scope: scope
        )
    }

    private func makeState(
        scope: TaxonCatalogScope,
        operation: TaxonSyncOperation
    ) -> TaxonSyncState {
        do {
            let metadata = try metadataRepository.loadMetadata(scope: scope)
            return TaxonSyncState(
                catalogStatus: try makeStatus(scope: scope, metadata: metadata),
                operation: operation
            )
        } catch {
            return TaxonSyncState(
                catalogStatus: nil,
                operation: .failed(failure: error, progress: nil)
            )
        }
    }

    private func makeStatus(
        scope: TaxonCatalogScope,
        metadata: TaxonSyncMetadata
    ) throws(TaxonSyncFailure) -> TaxonCatalogStatus {
        let localTaxaCount = try catalogRepository.count()
        let availability: TaxonCatalogAvailability

        if localTaxaCount == 0 {
            availability = .empty
        } else if metadata.lastSuccessfulSyncTimestamp != nil {
            availability = .ready
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
        _ operation: TaxonSyncOperation,
        catalogStatus: TaxonCatalogStatus? = nil,
        scope: TaxonCatalogScope
    ) {
        let cachedStatus = stateStore.state(for: scope)?.catalogStatus
        let currentStatus: TaxonCatalogStatus?

        if let catalogStatus {
            currentStatus = catalogStatus
        } else {
            do {
                currentStatus = try makeStatus(
                    scope: scope,
                    metadata: metadataRepository.loadMetadata(scope: scope)
                )
            } catch {
                currentStatus = cachedStatus
            }
        }

        stateStore.publish(
            TaxonSyncState(
                catalogStatus: currentStatus,
                operation: operation
            ),
            scope: scope
        )
    }

    private func removeSubscription(id: UUID) {
        stateStore.removeSubscription(id: id)
    }

    private func resetMetadataForEmptyCatalog(
        scope: TaxonCatalogScope,
        metadata initialMetadata: TaxonSyncMetadata
    ) throws(TaxonSyncFailure) -> TaxonSyncMetadata {
        pendingUpdates.removeValue(forKey: scope)

        guard initialMetadata.initialCatalogTimestamp != nil
                || initialMetadata.lastSuccessfulSyncTimestamp != nil
                || initialMetadata.checkpoint != nil else {
            return initialMetadata
        }

        let metadata = TaxonSyncMetadata(
            scope: scope,
            initialCatalogTimestamp: nil,
            lastSuccessfulSyncTimestamp: nil,
            checkpoint: nil
        )
        try metadataRepository.saveMetadata(metadata)
        return metadata
    }
}
