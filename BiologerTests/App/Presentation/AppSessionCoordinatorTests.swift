import XCTest
@testable import Biologer

@MainActor
final class AppSessionCoordinatorTests: XCTestCase {
    func test_finishLaunching_withoutAuthenticatedSession_requiresAuthorization() {
        let sessionStore = AppSessionStoreSpy(state: .unauthenticated)
        let sut = makeSUT(sessionStore: sessionStore)

        sut.startObservingSession()
        sut.finishLaunching()

        XCTAssertEqual(sut.state, .authorizationRequired)
    }

    func test_finishLaunching_withAuthenticatedSessionAndNoTaxonScope_becomesReady() async {
        let sessionStore = AppSessionStoreSpy(state: .authenticated)
        let sut = makeSUT(
            sessionStore: sessionStore,
            scope: nil
        )

        sut.startObservingSession()
        sut.finishLaunching()

        await waitUntil { sut.state == .ready }
    }

    func test_authorizationSucceeded_routesThroughSessionStoreChange() async {
        let sessionStore = AppSessionStoreSpy(state: .unauthenticated)
        sessionStore.stateOnSynchronize = .authenticated
        let sut = makeSUT(
            sessionStore: sessionStore,
            scope: nil
        )

        sut.startObservingSession()
        sut.finishLaunching()
        XCTAssertEqual(sut.state, .authorizationRequired)

        sut.authorizationSucceeded()

        await waitUntil { sut.state == .ready }
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
            taxonState: .idle(status)
        )

        sut.startObservingSession()
        sut.finishLaunching()

        await waitUntil { sut.state == .taxonSyncRequired }
    }

    func test_prepareSession_whenPreparationFails_exposesFailureState() async {
        let prepareSessionUseCase = AppSessionPrepareUseCaseStub(
            result: .failure(SettingsDataFailure(message: "prepare failed"))
        )
        let sut = makeSUT(
            sessionStore: AppSessionStoreSpy(state: .authenticated),
            prepareSessionUseCase: prepareSessionUseCase
        )

        sut.startObservingSession()
        sut.finishLaunching()

        await waitUntil {
            sut.state == .preparationFailed(message: "prepare failed")
        }
    }

    func test_sessionExpiration_ignoresSuspendedPreparationResult() async {
        let sessionStore = AppSessionStoreSpy(state: .authenticated)
        let prepareSessionUseCase = AppSessionSuspendedPrepareUseCase()
        let sut = makeSUT(
            sessionStore: sessionStore,
            prepareSessionUseCase: prepareSessionUseCase,
            scope: nil
        )

        sut.startObservingSession()
        sut.finishLaunching()
        await waitUntil { prepareSessionUseCase.callCount == 1 }

        sessionStore.send(.unauthenticated)
        await waitUntil { sut.state == .authorizationRequired }

        prepareSessionUseCase.completeCall(at: 0, with: .success(()))
        await Task.yield()

        XCTAssertEqual(sut.state, .authorizationRequired)
    }

    func test_retryPreparation_ignoresResultFromCancelledAttempt() async {
        let prepareSessionUseCase = AppSessionSuspendedPrepareUseCase()
        let sut = makeSUT(
            sessionStore: AppSessionStoreSpy(state: .authenticated),
            prepareSessionUseCase: prepareSessionUseCase,
            scope: nil
        )

        sut.startObservingSession()
        sut.finishLaunching()
        await waitUntil { prepareSessionUseCase.callCount == 1 }

        sut.retryPreparation()
        await waitUntil { prepareSessionUseCase.callCount == 2 }

        prepareSessionUseCase.completeCall(at: 0, with: .success(()))
        await Task.yield()
        XCTAssertEqual(sut.state, .preparing)

        prepareSessionUseCase.completeCall(at: 1, with: .success(()))
        await waitUntil { sut.state == .ready }
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
        let resolvedTaxonState = taxonState ?? .idle(
            TaxonCatalogStatus(
                scope: scope ?? TaxonCatalogScope(environmentHost: "unused"),
                availability: .ready,
                localTaxaCount: 1,
                lastSuccessfulSyncTimestamp: nil
            )
        )

        return AppSessionCoordinator(
            sessionStore: sessionStore,
            prepareSessionUseCase: prepareSessionUseCase,
            getTaxonSyncStateUseCase: AppSessionTaxonStateUseCaseStub(
                state: resolvedTaxonState
            ),
            taxonScopeProvider: AppSessionTaxonScopeProviderStub(scope: scope),
            logoutUseCase: AppSessionLogoutUseCaseSpy()
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

private final class AppSessionStoreSpy: SessionStore {
    private(set) var state: SessionState
    var onStateChange: ((SessionState) -> Void)?
    var stateOnSynchronize: SessionState?

    init(state: SessionState) {
        self.state = state
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
        onStateChange?(newState)
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

private struct AppSessionTaxonStateUseCaseStub: GetTaxonSyncStateUseCase {
    let state: TaxonSyncState

    func execute(scope: TaxonCatalogScope) async -> TaxonSyncState {
        state
    }
}

private struct AppSessionTaxonScopeProviderStub: TaxonCatalogScopeProviding {
    let scope: TaxonCatalogScope?

    func currentScope() -> TaxonCatalogScope? {
        scope
    }
}

private final class AppSessionLogoutUseCaseSpy: LogoutUseCase {
    func logout() {}
}
