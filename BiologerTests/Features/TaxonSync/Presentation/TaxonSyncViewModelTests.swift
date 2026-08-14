import XCTest
@testable import Biologer

@MainActor
final class TaxonSyncViewModelTests: XCTestCase {
    func test_observeState_mapsStreamValuesAndRemovesSubscriptionWhenCancelled() async {
        let scope = makeScope("api.biologer.org")
        let service = TaxonSyncServiceSpy()
        let sut = makeSUT(service: service, scope: scope)
        let observationTask = Task { await sut.observeState() }
        await waitUntil { await service.isObserving(scope) }

        let status = makeStatus(scope: scope, availability: .partial)
        await service.send(
            TaxonSyncState(catalogStatus: status, operation: .idle),
            scope: scope
        )
        await waitUntil { sut.viewState.catalogStatus == status }

        XCTAssertEqual(
            sut.viewState.statusTitle,
            "TaxonSync.status.partial.title".localized
        )
        XCTAssertFalse(sut.viewState.canContinue)

        observationTask.cancel()
        await observationTask.value

        await waitUntil { await service.terminationCount == 1 }
    }

    func test_initialCatalogAllowsContinuingOffline() async {
        let scope = makeScope("api.biologer.org")
        let service = TaxonSyncServiceSpy()
        let sut = makeSUT(service: service, scope: scope)
        let observationTask = Task { await sut.observeState() }
        await waitUntil { await service.isObserving(scope) }

        let status = makeStatus(
            scope: scope,
            availability: .initialCatalogLoaded
        )
        await service.send(
            TaxonSyncState(
                catalogStatus: status,
                operation: .waitingForNetwork(nil)
            ),
            scope: scope
        )
        await waitUntil { sut.viewState.catalogStatus == status }

        XCTAssertTrue(sut.viewState.canContinue)
        XCTAssertEqual(
            sut.viewState.statusTitle,
            "TaxonSync.status.waiting.title".localized
        )

        observationTask.cancel()
        await observationTask.value
    }

    func test_observeState_rejectsOldScopeAfterEnvironmentChanges() async {
        let firstScope = makeScope("api.biologer.org")
        let secondScope = makeScope("dev.biologer.org")
        let service = TaxonSyncServiceSpy()
        let scopeProvider = MutableTaxonSyncScopeProvider(scope: firstScope)
        let sut = TaxonSyncViewModel(
            service: service,
            scopeProvider: scopeProvider
        )
        let firstObservation = Task { await sut.observeState() }
        await waitUntil { await service.isObserving(firstScope) }

        let firstStatus = makeStatus(
            scope: firstScope,
            availability: .ready
        )
        await service.send(
            TaxonSyncState(catalogStatus: firstStatus, operation: .idle),
            scope: firstScope
        )
        await waitUntil { sut.viewState.catalogStatus == firstStatus }

        scopeProvider.scope = secondScope
        await service.send(
            TaxonSyncState(
                catalogStatus: firstStatus,
                operation: .completed
            ),
            scope: firstScope
        )
        await firstObservation.value
        XCTAssertNil(sut.viewState.catalogStatus)

        let secondObservation = Task { await sut.observeState() }
        await waitUntil { await service.isObserving(secondScope) }
        let secondStatus = makeStatus(
            scope: secondScope,
            availability: .initialCatalogLoaded
        )
        await service.send(
            TaxonSyncState(catalogStatus: secondStatus, operation: .idle),
            scope: secondScope
        )
        await waitUntil { sut.viewState.catalogStatus == secondStatus }

        XCTAssertEqual(sut.viewState.catalogStatus?.scope, secondScope)

        secondObservation.cancel()
        await secondObservation.value
    }

    func test_performPreventsDuplicatePrimaryAction() async {
        let scope = makeScope("api.biologer.org")
        let service = TaxonSyncServiceSpy(suspendsStart: true)
        let sut = makeSUT(service: service, scope: scope)
        let observationTask = Task { await sut.observeState() }
        await waitUntil { await service.isObserving(scope) }
        await service.send(
            TaxonSyncState(
                catalogStatus: makeStatus(
                    scope: scope,
                    availability: .empty
                ),
                operation: .idle
            ),
            scope: scope
        )
        await waitUntil { sut.viewState.primaryAction != nil }

        sut.perform(.start)
        await waitUntil { await service.startCallCount == 1 }
        XCTAssertFalse(sut.viewState.primaryAction?.isEnabled ?? true)

        sut.perform(.start)
        await Task.yield()
        let startCallCount = await service.startCallCount
        XCTAssertEqual(startCallCount, 1)

        await service.finishStart()
        await waitUntil { sut.viewState.primaryAction?.isEnabled == true }

        observationTask.cancel()
        await observationTask.value
    }

    private func makeSUT(
        service: TaxonSyncServiceSpy,
        scope: TaxonCatalogScope
    ) -> TaxonSyncViewModel {
        TaxonSyncViewModel(
            service: service,
            scopeProvider: MutableTaxonSyncScopeProvider(scope: scope)
        )
    }

    private func makeScope(_ host: String) -> TaxonCatalogScope {
        TaxonCatalogScope(environmentHost: host)
    }

    private func makeStatus(
        scope: TaxonCatalogScope,
        availability: TaxonCatalogAvailability
    ) -> TaxonCatalogStatus {
        TaxonCatalogStatus(
            scope: scope,
            availability: availability,
            localTaxaCount: availability == .empty ? 0 : 100,
            lastSuccessfulSyncTimestamp: availability == .ready ? 1 : nil
        )
    }

    private func waitUntil(
        _ condition: @escaping @MainActor () async -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<100 {
            if await condition() { return }
            await Task.yield()
        }

        XCTFail("Condition was not satisfied.", file: file, line: line)
    }
}

private actor TaxonSyncServiceSpy: TaxonSyncService {
    private var observedScopes: Set<TaxonCatalogScope> = []
    private(set) var terminationCount = 0
    private(set) var startCallCount = 0

    private var continuations: [
        TaxonCatalogScope: AsyncStream<TaxonSyncState>.Continuation
    ] = [:]
    private var startContinuation: CheckedContinuation<Void, Never>?
    private let suspendsStart: Bool

    init(suspendsStart: Bool = false) {
        self.suspendsStart = suspendsStart
    }

    func state(scope: TaxonCatalogScope) async -> TaxonSyncState {
        TaxonSyncState(
            catalogStatus: TaxonCatalogStatus(
                scope: scope,
                availability: .empty,
                localTaxaCount: 0,
                lastSuccessfulSyncTimestamp: nil
            ),
            operation: .idle
        )
    }

    func observe(
        scope: TaxonCatalogScope
    ) async -> AsyncStream<TaxonSyncState> {
        let (stream, continuation) = AsyncStream.makeStream(
            of: TaxonSyncState.self
        )
        continuations[scope] = continuation
        observedScopes.insert(scope)
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeObservation(scope: scope) }
        }
        return stream
    }

    func checkForUpdates(
        scope: TaxonCatalogScope
    ) async throws(TaxonSyncFailure) -> TaxonSyncCheckResult {
        let snapshot = await state(scope: scope)
        return .upToDate(snapshot.catalogStatus!)
    }

    func start(scope: TaxonCatalogScope) async {
        startCallCount += 1
        guard suspendsStart else { return }
        await withCheckedContinuation { continuation in
            startContinuation = continuation
        }
    }

    func pause(scope: TaxonCatalogScope) async {}
    func resume(scope: TaxonCatalogScope) async {}

    func send(_ state: TaxonSyncState, scope: TaxonCatalogScope) {
        continuations[scope]?.yield(state)
    }

    func finishStart() {
        startContinuation?.resume()
        startContinuation = nil
    }

    func isObserving(_ scope: TaxonCatalogScope) -> Bool {
        observedScopes.contains(scope)
    }

    private func removeObservation(scope: TaxonCatalogScope) {
        continuations.removeValue(forKey: scope)
        observedScopes.remove(scope)
        terminationCount += 1
    }
}

private final class MutableTaxonSyncScopeProvider:
    TaxonCatalogScopeProviding {
    var scope: TaxonCatalogScope?

    init(scope: TaxonCatalogScope?) {
        self.scope = scope
    }

    func currentScope() -> TaxonCatalogScope? {
        scope
    }
}
