import XCTest
@testable import Biologer

@MainActor
final class TaxonSyncViewModelTests: XCTestCase {
    func test_observeState_appliesStreamValuesWithoutRequestingSnapshot() async {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let status = TaxonCatalogStatus(
            scope: scope,
            availability: .partial,
            localTaxaCount: 100,
            lastSuccessfulSyncTimestamp: nil
        )
        let getState = TaxonSyncGetStateSpy(state: .idle(status))
        let observeState = TaxonSyncObserveStateStub()
        let action = TaxonSyncActionStub()
        let sut = TaxonSyncViewModel(
            useCases: TaxonSyncUseCases(
                getState: getState,
                observeState: observeState,
                checkForUpdates: action,
                start: action,
                pause: action,
                resume: action
            ),
            scopeProvider: TaxonSyncScopeStub(scope: scope)
        )
        let observationTask = Task { await sut.observeState() }
        await waitUntil { observeState.isObserved }

        observeState.send(.idle(status))
        await waitUntil { sut.state == .idle(status) }

        observationTask.cancel()
        await observationTask.value

        XCTAssertEqual(getState.callCount, 0)
        XCTAssertEqual(observeState.terminationCount, 1)
    }

    func test_canContinue_requiresReadyCatalog() async {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let observeState = TaxonSyncObserveStateStub()
        let action = TaxonSyncActionStub()
        let sut = TaxonSyncViewModel(
            useCases: TaxonSyncUseCases(
                getState: TaxonSyncGetStateSpy(
                    state: .idle(makeStatus(scope: scope, availability: .empty))
                ),
                observeState: observeState,
                checkForUpdates: action,
                start: action,
                pause: action,
                resume: action
            ),
            scopeProvider: TaxonSyncScopeStub(scope: scope)
        )
        let observationTask = Task { await sut.observeState() }
        await waitUntil { observeState.isObserved }

        observeState.send(
            .idle(makeStatus(scope: scope, availability: .partial))
        )
        await waitUntil { sut.state != nil }
        XCTAssertFalse(sut.canContinue)

        let readyStatus = makeStatus(scope: scope, availability: .ready)
        observeState.send(.idle(readyStatus))
        await waitUntil { sut.state == .idle(readyStatus) }
        XCTAssertTrue(sut.canContinue)

        observeState.send(.completed(readyStatus))
        await waitUntil { sut.state == .completed(readyStatus) }
        XCTAssertTrue(sut.canContinue)

        observationTask.cancel()
        await observationTask.value
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
        _ condition: @escaping @MainActor () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<100 {
            if condition() { return }
            await Task.yield()
        }

        XCTFail("Condition was not satisfied.", file: file, line: line)
    }
}

private final class TaxonSyncGetStateSpy: GetTaxonSyncStateUseCase {
    let state: TaxonSyncState
    private(set) var callCount = 0

    init(state: TaxonSyncState) {
        self.state = state
    }

    func execute(scope: TaxonCatalogScope) async -> TaxonSyncState {
        callCount += 1
        return state
    }
}

private final class TaxonSyncObserveStateStub: ObserveTaxonSyncStateUseCase {
    private var continuation: AsyncStream<TaxonSyncState>.Continuation?
    private(set) var isObserved = false
    private(set) var terminationCount = 0

    func execute(
        scope: TaxonCatalogScope
    ) async -> AsyncStream<TaxonSyncState> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

            self.continuation = continuation
            isObserved = true
            continuation.onTermination = { [weak self] _ in
                self?.continuation = nil
                self?.terminationCount += 1
            }
        }
    }

    func send(_ state: TaxonSyncState) {
        continuation?.yield(state)
    }
}

private struct TaxonSyncActionStub: CheckTaxonUpdatesUseCase,
    StartTaxonSyncUseCase,
    PauseTaxonSyncUseCase,
    ResumeTaxonSyncUseCase {
    func execute(
        scope: TaxonCatalogScope
    ) async throws(TaxonSyncFailure) -> TaxonSyncCheckResult {
        .upToDate(
            TaxonCatalogStatus(
                scope: scope,
                availability: .ready,
                localTaxaCount: 1,
                lastSuccessfulSyncTimestamp: nil
            )
        )
    }

    func execute(scope: TaxonCatalogScope) async {}
}

private struct TaxonSyncScopeStub: TaxonCatalogScopeProviding {
    let scope: TaxonCatalogScope?

    func currentScope() -> TaxonCatalogScope? {
        scope
    }
}
