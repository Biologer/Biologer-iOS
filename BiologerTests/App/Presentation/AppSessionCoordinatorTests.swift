import XCTest
@testable import Biologer

@MainActor
final class AppSessionCoordinatorTests: XCTestCase {
    func test_finishLaunching_withoutAuthenticatedSession_requiresAuthorization() async {
        let sessionStore = AppSessionStoreSpy(state: .unauthenticated)
        let sut = makeSUT(sessionStore: sessionStore)

        await sut.finishLaunching()

        XCTAssertEqual(sut.state, .authorizationRequired)
    }

    func test_finishLaunching_withAuthenticatedSessionAndNoTaxonScope_becomesReady() async {
        let sessionStore = AppSessionStoreSpy(state: .authenticated)
        let sut = makeSUT(
            sessionStore: sessionStore,
            scope: nil
        )

        await sut.finishLaunching()
        XCTAssertEqual(sut.state, .preparing)

        await sut.prepareSession()

        XCTAssertEqual(sut.state, .ready)
    }

    func test_authorizationSucceeded_routesThroughSessionStoreChange() async {
        let sessionStore = AppSessionStoreSpy(
            state: .unauthenticated,
            stateOnSynchronize: .authenticated
        )
        let sut = makeSUT(
            sessionStore: sessionStore,
            scope: nil
        )
        let observationTask = Task { await sut.observeSession() }
        defer { observationTask.cancel() }
        await waitUntil { await sessionStore.isObserved() }

        await sut.finishLaunching()
        XCTAssertEqual(sut.state, .authorizationRequired)

        await sut.authorizationSucceeded()
        await waitUntil { sut.state == .preparing }
        await sut.prepareSession()

        XCTAssertEqual(sut.state, .ready)
    }

    func test_finishLaunching_whenTaxonCatalogIsNotReady_requiresTaxonSync() async {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let status = TaxonCatalogStatus(
            scope: scope,
            availability: .partial,
            localTaxaCount: 100,
            lastSuccessfulSyncTimestamp: nil
        )
        let sut = makeSUT(
            sessionStore: AppSessionStoreSpy(state: .authenticated),
            scope: scope,
            taxonState: TaxonSyncState(
                catalogStatus: status,
                operation: .idle
            )
        )

        await sut.finishLaunching()
        await sut.prepareSession()

        XCTAssertEqual(sut.state, .taxonSyncRequired)
    }

    func test_finishLaunching_withInitialCatalog_allowsOfflineEntry() async {
        let scope = TaxonCatalogScope(environmentHost: "api.biologer.org")
        let status = TaxonCatalogStatus(
            scope: scope,
            availability: .initialCatalogLoaded,
            localTaxaCount: 100,
            lastSuccessfulSyncTimestamp: nil
        )
        let sut = makeSUT(
            sessionStore: AppSessionStoreSpy(state: .authenticated),
            scope: scope,
            taxonState: TaxonSyncState(
                catalogStatus: status,
                operation: .waitingForNetwork(nil)
            )
        )

        await sut.finishLaunching()
        await sut.prepareSession()

        XCTAssertEqual(sut.state, .ready)
    }

    func test_prepareSession_whenPreparationFails_exposesFailureState() async {
        let prepareSessionUseCase = AppSessionPrepareUseCaseStub(
            result: .failure(SettingsDataFailure(message: "prepare failed"))
        )
        let sut = makeSUT(
            sessionStore: AppSessionStoreSpy(state: .authenticated),
            prepareSessionUseCase: prepareSessionUseCase
        )

        await sut.finishLaunching()
        await sut.prepareSession()

        XCTAssertEqual(
            sut.state,
            .preparationFailed(message: "prepare failed")
        )
    }

    func test_sessionExpiration_ignoresSuspendedPreparationResult() async {
        let sessionStore = AppSessionStoreSpy(state: .authenticated)
        let prepareSessionUseCase = AppSessionSuspendedPrepareUseCase()
        let sut = makeSUT(
            sessionStore: sessionStore,
            prepareSessionUseCase: prepareSessionUseCase,
            scope: nil
        )
        let observationTask = Task { await sut.observeSession() }
        defer { observationTask.cancel() }
        await waitUntil { await sessionStore.isObserved() }

        await sut.finishLaunching()
        let preparationTask = Task { await sut.prepareSession() }
        await waitUntil { prepareSessionUseCase.callCount == 1 }

        await sessionStore.send(.unauthenticated)
        await waitUntil { sut.state == .authorizationRequired }

        prepareSessionUseCase.completeCall(at: 0, with: .success(()))
        await preparationTask.value

        XCTAssertEqual(sut.state, .authorizationRequired)
    }

    func test_retryPreparation_startsNewPreparationAfterFailure() async {
        let prepareSessionUseCase = AppSessionSuspendedPrepareUseCase()
        let sut = makeSUT(
            sessionStore: AppSessionStoreSpy(state: .authenticated),
            prepareSessionUseCase: prepareSessionUseCase,
            scope: nil
        )

        await sut.finishLaunching()
        let firstTask = Task { await sut.prepareSession() }
        await waitUntil { prepareSessionUseCase.callCount == 1 }
        prepareSessionUseCase.completeCall(
            at: 0,
            with: .failure(SettingsDataFailure(message: "prepare failed"))
        )
        await firstTask.value
        XCTAssertEqual(
            sut.state,
            .preparationFailed(message: "prepare failed")
        )

        await sut.retryPreparation()
        XCTAssertEqual(sut.state, .preparing)

        let retryTask = Task { await sut.prepareSession() }
        await waitUntil { prepareSessionUseCase.callCount == 2 }
        prepareSessionUseCase.completeCall(at: 1, with: .success(()))
        await retryTask.value

        XCTAssertEqual(sut.state, .ready)
    }

    private func makeSUT(
        sessionStore: AppSessionStoreSpy,
        prepareSessionUseCase: PrepareSessionUseCase = AppSessionPrepareUseCaseStub(
            result: .success(())
        ),
        scope: TaxonCatalogScope? = TaxonCatalogScope(
            environmentHost: "api.biologer.org"
        ),
        taxonState: TaxonSyncState? = nil
    ) -> AppSessionCoordinator {
        let resolvedTaxonState = taxonState ?? TaxonSyncState(
            catalogStatus: TaxonCatalogStatus(
                scope: scope ?? TaxonCatalogScope(environmentHost: "unused"),
                availability: .ready,
                localTaxaCount: 1,
                lastSuccessfulSyncTimestamp: nil
            ),
            operation: .idle
        )

        return AppSessionCoordinator(
            sessionStore: sessionStore,
            prepareSessionUseCase: prepareSessionUseCase,
            taxonSyncStateProvider: AppSessionTaxonStateProviderStub(
                state: resolvedTaxonState
            ),
            taxonScopeProvider: AppSessionTaxonScopeProviderStub(scope: scope),
            logoutUseCase: AppSessionLogoutUseCaseSpy()
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

private actor AppSessionStoreSpy: SessionStore {
    private var state: SessionState
    private var observationStarted = false
    private let stateOnSynchronize: SessionState?

    private var continuation: AsyncStream<SessionState>.Continuation?

    init(
        state: SessionState,
        stateOnSynchronize: SessionState? = nil
    ) {
        self.state = state
        self.stateOnSynchronize = stateOnSynchronize
    }

    func currentState() -> SessionState {
        state
    }

    func isObserved() -> Bool {
        observationStarted
    }

    func observeState() -> AsyncStream<SessionState> {
        let (stream, continuation) = AsyncStream.makeStream(
            of: SessionState.self
        )
        self.continuation = continuation
        observationStarted = true
        continuation.yield(state)
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeContinuation() }
        }
        return stream
    }

    func synchronize() {
        guard let stateOnSynchronize else { return }
        send(stateOnSynchronize)
    }

    func markAuthenticated() {
        send(.authenticated)
    }

    func markUnauthenticated() {
        send(.unauthenticated)
    }

    func send(_ newState: SessionState) {
        state = newState
        continuation?.yield(newState)
    }

    private func removeContinuation() {
        continuation = nil
    }
}

private struct AppSessionPrepareUseCaseStub: PrepareSessionUseCase {
    let result: Result<Void, SettingsDataFailure>

    func execute() async throws(SettingsDataFailure) {
        try result.get()
    }
}

private final class AppSessionSuspendedPrepareUseCase: PrepareSessionUseCase {
    private(set) var callCount = 0
    private var continuations: [
        CheckedContinuation<Result<Void, SettingsDataFailure>, Never>
    ] = []

    func execute() async throws(SettingsDataFailure) {
        let result = await withCheckedContinuation { continuation in
            continuations.append(continuation)
            callCount = continuations.count
        }
        try result.get()
    }

    func completeCall(
        at index: Int,
        with result: Result<Void, SettingsDataFailure>
    ) {
        continuations[index].resume(returning: result)
    }
}

private final class AppSessionTaxonStateProviderStub:
    TaxonSyncStateProviding {
    let snapshot: TaxonSyncState

    init(state: TaxonSyncState) {
        self.snapshot = state
    }

    func state(scope: TaxonCatalogScope) async -> TaxonSyncState {
        snapshot
    }
}

private struct AppSessionTaxonScopeProviderStub: TaxonCatalogScopeProviding {
    let scope: TaxonCatalogScope?

    func currentScope() -> TaxonCatalogScope? {
        scope
    }
}

private final class AppSessionLogoutUseCaseSpy: LogoutUseCase {
    func logout() async {}
}
