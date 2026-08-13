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
