import Foundation

/// The single state machine that drives the application's root content.
enum AppSessionState: Equatable {
    /// The splash screen is visible while the app finishes its launch presentation.
    case launching

    /// No authenticated session exists, so authorization must be presented.
    case authorizationRequired

    /// The user is authenticated and required account data is being prepared.
    case preparing

    /// Session preparation failed and the user may retry or log out.
    case preparationFailed(message: String)

    /// Required local taxon data is not ready and must be synchronized.
    case taxonSyncRequired

    /// The authenticated session and required local data are ready for the main app.
    case ready
}

/// Coordinates authentication changes, startup preparation and root navigation.
/// Domain use cases remain independent of MainActor; only their UI-facing orchestration
/// is isolated here.
@MainActor
final class AppSessionCoordinator: ObservableObject {
    @Published private(set) var state: AppSessionState = .launching

    private let sessionStore: SessionStore
    private let prepareSessionUseCase: PrepareSessionUseCase
    private let getTaxonSyncStateUseCase: GetTaxonSyncStateUseCase
    private let taxonScopeProvider: TaxonCatalogScopeProviding
    private let logoutUseCase: LogoutUseCase

    init(
        sessionStore: SessionStore,
        prepareSessionUseCase: PrepareSessionUseCase,
        getTaxonSyncStateUseCase: GetTaxonSyncStateUseCase,
        taxonScopeProvider: TaxonCatalogScopeProviding,
        logoutUseCase: LogoutUseCase
    ) {
        self.sessionStore = sessionStore
        self.prepareSessionUseCase = prepareSessionUseCase
        self.getTaxonSyncStateUseCase = getTaxonSyncStateUseCase
        self.taxonScopeProvider = taxonScopeProvider
        self.logoutUseCase = logoutUseCase
    }

    /// Observes session changes for as long as the owning SwiftUI task is alive.
    func observeSession() async {
        let stream = await sessionStore.observeState()
        for await sessionState in stream {
            guard !Task.isCancelled else { return }

            // Splash owns the launch transition and will apply the latest snapshot.
            guard state != .launching else { continue }
            let currentSessionState = await sessionStore.currentState()
            guard sessionState == currentSessionState else {
                continue
            }
            handle(sessionState)
        }
    }

    /// Leaves the splash screen by applying the SessionStore's initial snapshot.
    func finishLaunching() async {
        handle(await sessionStore.currentState())
    }

    /// Refreshes authentication after the authorization flow persists new tokens.
    /// Root navigation continues only through the SessionStore observer.
    func authorizationSucceeded() async {
        await sessionStore.synchronize()
    }

    func retryPreparation() async {
        guard case .preparationFailed = state else { return }
        guard await sessionStore.currentState() == .authenticated else {
            handle(.unauthenticated)
            return
        }

        transition(to: .preparing)
    }

    func showTaxonSync() {
        transition(to: .taxonSyncRequired)
    }

    func continueAfterTaxonSync() {
        transition(to: .ready)
    }

    func logout() async {
        await logoutUseCase.logout()
    }

    /// Prepares authenticated data while the root view is in `.preparing`.
    /// Leaving that state cancels the SwiftUI task that awaits this method.
    func prepareSession() async {
        guard await canApplyPreparationResult() else { return }

        do {
            try await prepareSessionUseCase.execute()
            guard await canApplyPreparationResult() else { return }

            guard let scope = taxonScopeProvider.currentScope() else {
                transition(to: .ready)
                return
            }

            let taxonState = await getTaxonSyncStateUseCase.execute(
                scope: scope
            )
            guard await canApplyPreparationResult() else { return }

            transition(
                to: isTaxonCatalogReady(taxonState)
                    ? .ready
                    : .taxonSyncRequired
            )
        } catch {
            guard await canApplyPreparationResult() else { return }
            transition(to: .preparationFailed(message: error.message))
        }
    }

    private func handle(_ sessionState: SessionState) {
        switch sessionState {
        case .unauthenticated:
            transition(to: .authorizationRequired)

        case .authenticated:
            guard state == .launching || state == .authorizationRequired else {
                return
            }
            transition(to: .preparing)
        }
    }

    /// An async result may update root state only while its authenticated
    /// preparation is still current. Cancellation rejects work whose view ended.
    private func canApplyPreparationResult() async -> Bool {
        guard !Task.isCancelled, state == .preparing else { return false }
        return await sessionStore.currentState() == .authenticated
    }

    private func transition(to newState: AppSessionState) {
        guard state != newState else { return }
        state = newState
    }

    private func isTaxonCatalogReady(_ state: TaxonSyncState) -> Bool {
        switch state {
        case .idle(let status), .completed(let status):
            return status.availability == .ready

        default:
            return false
        }
    }
}
