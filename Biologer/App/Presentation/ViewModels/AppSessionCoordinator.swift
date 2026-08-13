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

    private var isObservingSession = false
    private var preparationTask: Task<Void, Never>?

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

    func startObservingSession() {
        guard !isObservingSession else { return }
        isObservingSession = true

        sessionStore.onStateChange = { [weak self] sessionState in
            Task { @MainActor [weak self] in
                self?.handle(sessionState)
            }
        }
    }

    func stopObservingSession() {
        guard isObservingSession else { return }
        isObservingSession = false
        sessionStore.onStateChange = nil
    }

    /// Leaves the splash screen by applying the SessionStore's initial snapshot.
    func finishLaunching() {
        handle(sessionStore.state)
    }

    /// Refreshes authentication after the authorization flow persists new tokens.
    /// Root navigation continues only through the SessionStore observer.
    func authorizationSucceeded() {
        sessionStore.synchronize()
    }

    func retryPreparation() {
        guard sessionStore.state == .authenticated else {
            handle(.unauthenticated)
            return
        }

        beginPreparation()
    }

    func showTaxonSync() {
        preparationTask?.cancel()
        transition(to: .taxonSyncRequired)
    }

    func continueAfterTaxonSync() {
        transition(to: .ready)
    }

    func logout() {
        preparationTask?.cancel()
        logoutUseCase.logout()
    }

    private func handle(_ sessionState: SessionState) {
        switch sessionState {
        case .unauthenticated:
            preparationTask?.cancel()
            transition(to: .authorizationRequired)

        case .authenticated:
            beginPreparation()
        }
    }

    private func beginPreparation() {
        preparationTask?.cancel()
        transition(to: .preparing)

        preparationTask = Task { [weak self] in
            guard let self else { return }
            await self.prepareAuthenticatedSession()
        }
    }

    private func prepareAuthenticatedSession() async {
        do {
            try await prepareSessionUseCase.execute()
            guard canApplyPreparationResult else { return }

            guard let scope = taxonScopeProvider.currentScope() else {
                transition(to: .ready)
                return
            }

            let taxonState = await getTaxonSyncStateUseCase.execute(
                scope: scope
            )
            guard canApplyPreparationResult else { return }

            transition(
                to: isTaxonCatalogReady(taxonState)
                    ? .ready
                    : .taxonSyncRequired
            )
        } catch {
            guard canApplyPreparationResult else { return }
            transition(to: .preparationFailed(message: error.message))
        }
    }

    /// An async result may update root state only while its original authenticated
    /// preparation is still current. Cancellation also rejects an older retry task.
    private var canApplyPreparationResult: Bool {
        !Task.isCancelled &&
        sessionStore.state == .authenticated &&
        state == .preparing
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
