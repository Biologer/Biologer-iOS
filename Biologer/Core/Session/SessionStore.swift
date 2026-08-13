import Foundation

enum SessionState: Equatable, Sendable {
    /// No valid persisted credentials are available.
    case unauthenticated

    /// Valid persisted credentials are available for protected requests.
    case authenticated
}

protocol SessionStore: AnyObject {
    var state: SessionState { get }
    func observeState() -> AsyncStream<SessionState>
    func synchronize()
    func markAuthenticated()
    func markUnauthenticated()
}

/// Application-level source of truth for whether a session exists.
/// TokenStorage remains the persistence mechanism.
final class DefaultSessionStore: SessionStore {
    private let tokenStorage: TokenStorage
    private let lock = NSLock()
    private var storedState: SessionState
    private var continuations: [
        UUID: AsyncStream<SessionState>.Continuation
    ] = [:]

    var state: SessionState {
        lock.lock()
        defer { lock.unlock() }
        return storedState
    }

    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
        storedState = Self.resolveState(from: tokenStorage)
    }

    func observeState() -> AsyncStream<SessionState> {
        let subscriptionID = UUID()

        return AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

            continuation.onTermination = { [weak self] _ in
                self?.removeContinuation(id: subscriptionID)
            }

            lock.lock()
            continuations[subscriptionID] = continuation
            continuation.yield(storedState)
            lock.unlock()
        }
    }

    func synchronize() {
        update(Self.resolveState(from: tokenStorage))
    }

    func markAuthenticated() { update(.authenticated) }
    func markUnauthenticated() { update(.unauthenticated) }

    private func update(_ newState: SessionState) {
        lock.lock()
        defer { lock.unlock() }

        guard storedState != newState else { return }
        storedState = newState
        continuations.values.forEach { $0.yield(newState) }
    }

    private func removeContinuation(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        continuations[id] = nil
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
