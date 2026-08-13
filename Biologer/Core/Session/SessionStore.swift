import Foundation

enum SessionState: Equatable, Sendable {
    /// No valid persisted credentials are available.
    case unauthenticated

    /// Valid persisted credentials are available for protected requests.
    case authenticated
}

protocol SessionStore: Actor {
    func currentState() -> SessionState
    func observeState() -> AsyncStream<SessionState>
    func synchronize()
    func markAuthenticated()
    func markUnauthenticated()
}

/// Application-level source of truth for whether a session exists.
/// TokenStorage remains the persistence mechanism.
actor DefaultSessionStore: SessionStore {
    private let tokenStorage: TokenStorage
    private var state: SessionState
    private var continuations: [
        UUID: AsyncStream<SessionState>.Continuation
    ] = [:]

    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
        state = Self.resolveState(from: tokenStorage)
    }

    func currentState() -> SessionState {
        state
    }

    func observeState() -> AsyncStream<SessionState> {
        let subscriptionID = UUID()
        let (stream, continuation) = AsyncStream.makeStream(
            of: SessionState.self
        )

        continuation.onTermination = { [weak self] _ in
            Task {
                await self?.removeContinuation(id: subscriptionID)
            }
        }

        continuations[subscriptionID] = continuation
        continuation.yield(state)
        return stream
    }

    func synchronize() {
        update(Self.resolveState(from: tokenStorage))
    }

    func markAuthenticated() { update(.authenticated) }
    func markUnauthenticated() { update(.unauthenticated) }

    private func update(_ newState: SessionState) {
        guard state != newState else { return }
        state = newState
        continuations.values.forEach { $0.yield(newState) }
    }

    private func removeContinuation(id: UUID) {
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
