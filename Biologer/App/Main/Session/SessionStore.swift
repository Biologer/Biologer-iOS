import Foundation

enum SessionState: Equatable, Sendable {
    case checking
    case unauthenticated
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
    private(set) var state: SessionState = .checking
    var onStateChange: ((SessionState) -> Void)?

    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
        synchronize()
    }

    func synchronize() {
        if let token = tokenStorage.getToken(),
           !token.accessToken.isEmpty,
           !token.refreshToken.isEmpty {
            update(.authenticated)
        } else {
            update(.unauthenticated)
        }
    }

    func markAuthenticated() { update(.authenticated) }
    func markUnauthenticated() { update(.unauthenticated) }

    private func update(_ newState: SessionState) {
        guard state != newState else { return }
        state = newState
        onStateChange?(newState)
    }
}
