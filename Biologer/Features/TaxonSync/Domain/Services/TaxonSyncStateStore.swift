import Foundation

/// Keeps the latest state and broadcasts only the newest value to subscribers.
/// It is owned by TaxonSyncController and is not a second synchronization engine.
final class TaxonSyncStateStore {
    private struct Subscription {
        let scope: TaxonCatalogScope
        let continuation: AsyncStream<TaxonSyncState>.Continuation
    }

    private var states: [TaxonCatalogScope: TaxonSyncState] = [:]
    private var subscriptions: [UUID: Subscription] = [:]

    func state(for scope: TaxonCatalogScope) -> TaxonSyncState? {
        states[scope]
    }

    func store(
        _ state: TaxonSyncState,
        scope: TaxonCatalogScope
    ) {
        states[scope] = state
    }

    func stream(
        scope: TaxonCatalogScope,
        initialState: TaxonSyncState,
        onTermination: @escaping @Sendable (UUID) -> Void
    ) -> AsyncStream<TaxonSyncState> {
        let subscriptionID = UUID()
        var streamContinuation: AsyncStream<TaxonSyncState>.Continuation?
        let stream = AsyncStream<TaxonSyncState>(
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            streamContinuation = continuation
        }

        guard let streamContinuation else {
            return stream
        }

        subscriptions[subscriptionID] = Subscription(
            scope: scope,
            continuation: streamContinuation
        )
        streamContinuation.onTermination = { _ in
            onTermination(subscriptionID)
        }
        streamContinuation.yield(initialState)
        return stream
    }

    func publish(
        _ state: TaxonSyncState,
        scope: TaxonCatalogScope
    ) {
        states[scope] = state

        subscriptions.values
            .filter { $0.scope == scope }
            .forEach { $0.continuation.yield(state) }
    }

    func removeSubscription(id: UUID) {
        subscriptions.removeValue(forKey: id)
    }
}
