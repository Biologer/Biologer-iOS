import Foundation

enum AppRootState: Equatable {
    case launching
    case authorization
    case preparingSession
    case taxonSync
    case main
}

struct AppRootAlert: Identifiable {
    let id = UUID()
    let message: String
}

@MainActor
final class AppRootViewModel: ObservableObject {
    @Published private(set) var state: AppRootState = .launching
    @Published var alert: AppRootAlert?

    private let sessionStore: SessionStore
    private let prepareSessionUseCase: PrepareSessionUseCase
    private let getTaxonSyncStateUseCase: GetTaxonSyncStateUseCase
    private let taxonScopeProvider: TaxonCatalogScopeProviding
    private let logoutUseCase: LogoutUseCase

    private var isObservingSession = false
    private var isPreparingSession = false

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
        sessionStore.onStateChange = { [weak self] state in
            Task { @MainActor [weak self] in
                self?.route(for: state)
            }
        }
    }

    func stopObservingSession() {
        guard isObservingSession else { return }
        isObservingSession = false
        sessionStore.onStateChange = nil
    }

    func finishLaunching() {
        sessionStore.synchronize()
        route(for: sessionStore.state)
    }

    func authorizationSucceeded() {
        sessionStore.synchronize()
        route(for: sessionStore.state)
    }

    func prepareSession() async {
        guard !isPreparingSession else { return }
        isPreparingSession = true
        alert = nil
        defer { isPreparingSession = false }

        do {
            try await prepareSessionUseCase.execute()
            guard sessionStore.state == .authenticated, state == .preparingSession else {
                return
            }
            guard let scope = taxonScopeProvider.currentScope() else {
                transition(to: .main)
                return
            }

            let taxonState = await getTaxonSyncStateUseCase.execute(scope: scope)
            guard sessionStore.state == .authenticated, state == .preparingSession else {
                return
            }
            transition(to: isTaxonCatalogReady(taxonState) ? .main : .taxonSync)
        } catch {
            guard sessionStore.state == .authenticated, state == .preparingSession else {
                return
            }
            alert = AppRootAlert(message: error.description)
        }
    }

    func showTaxonSync() {
        transition(to: .taxonSync)
    }

    func showMain() {
        transition(to: .main)
    }

    func logout() {
        logoutUseCase.logout()
    }

    private func route(for sessionState: SessionState) {
        switch sessionState {
        case .checking:
            transition(to: .launching)
        case .unauthenticated:
            alert = nil
            transition(to: .authorization)
        case .authenticated:
            transition(to: .preparingSession)
        }
    }

    private func transition(to newState: AppRootState) {
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
