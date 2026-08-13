import Foundation

enum SessionState: Equatable, Sendable {
    /// No valid persisted credentials are available.
    case unauthenticated

    /// Valid persisted credentials are available for protected requests.
    case authenticated
}

protocol SessionStore: AnyObject {
    var state: SessionState { get }
    var onStateChange: ((SessionState) -> Void)? { get set }
    func synchronize()
    func markAuthenticated()
    func markUnauthenticated()
}

/// Application-level source of truth for whether a session exists.
/// TokenStorage remains the persistence mechanism.
final class DefaultSessionStore: SessionStore {
    private let tokenStorage: TokenStorage
    private(set) var state: SessionState
    var onStateChange: ((SessionState) -> Void)?

    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
        state = Self.resolveState(from: tokenStorage)
    }

    func synchronize() {
        update(Self.resolveState(from: tokenStorage))
    }

    func markAuthenticated() { update(.authenticated) }
    func markUnauthenticated() { update(.unauthenticated) }

    private func update(_ newState: SessionState) {
        guard state != newState else { return }
        state = newState
        onStateChange?(newState)
    }

    private static func resolveState(
        from tokenStorage: TokenStorage
    ) -> SessionState {
        guard let token = tokenStorage.getToken(),
              !token.accessToken.isEmpty,
              !token.refreshToken.isEmpty
        else {
            return .unauthenticated
        }

        return .authenticated
    }
}
