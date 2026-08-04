import Foundation

/// Keeps the latest state and broadcasts only the newest value to observers.
/// It is owned by TaxonSyncController and is not a second synchronization engine.
final class TaxonSyncStateStore {
    typealias ObserverTermination = @Sendable (UUID) -> Void

    private struct Observer {
        let scope: TaxonCatalogScope
        let continuation: AsyncStream<TaxonSyncState>.Continuation
    }

    private var states: [TaxonCatalogScope: TaxonSyncState] = [:]
    private var observers: [UUID: Observer] = [:]

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
        onTermination: @escaping ObserverTermination
    ) -> AsyncStream<TaxonSyncState> {
        let observerID = UUID()
        var streamContinuation: AsyncStream<TaxonSyncState>.Continuation?
        let stream = AsyncStream<TaxonSyncState>(
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            streamContinuation = continuation
        }

        guard let streamContinuation else {
            return stream
        }

        observers[observerID] = Observer(
            scope: scope,
            continuation: streamContinuation
        )
        streamContinuation.onTermination = { _ in
            onTermination(observerID)
        }
        streamContinuation.yield(initialState)
        return stream
    }

    func publish(
        _ state: TaxonSyncState,
        scope: TaxonCatalogScope
    ) {
        states[scope] = state

        observers.values
            .filter { $0.scope == scope }
            .forEach { $0.continuation.yield(state) }
    }

    func removeObserver(id: UUID) {
        observers.removeValue(forKey: id)
    }
}
