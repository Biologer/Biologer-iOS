import Foundation

/// Coalesces concurrent refresh attempts into one network operation.
/// Every caller awaits the same result and then retries its own original request.
actor TokenRefreshCoordinator: AccessTokenRefreshing {
    private struct InFlightRefresh {
        let id: UUID
        let task: Task<String, Error>
    }

    private struct CompletedRefresh {
        let session: TokenSnapshot
        let accessToken: String
    }

    private let refresher: AccessTokenRefreshing
    private var inFlightRefreshes: [TokenSnapshot: InFlightRefresh] = [:]
    private var completedRefresh: CompletedRefresh?

    init(refresher: AccessTokenRefreshing) {
        self.refresher = refresher
    }

    func refreshAccessToken(for session: TokenSnapshot) async throws -> String {
        if let completedRefresh,
           completedRefresh.session == session {
            return completedRefresh.accessToken
        }

        if let inFlightRefresh = inFlightRefreshes[session] {
            return try await inFlightRefresh.task.value
        }

        let refreshID = UUID()
        let refreshTask = Task { [refresher] in
            try await refresher.refreshAccessToken(for: session)
        }
        inFlightRefreshes[session] = InFlightRefresh(
            id: refreshID,
            task: refreshTask
        )

        do {
            let accessToken = try await refreshTask.value
            completedRefresh = CompletedRefresh(session: session, accessToken: accessToken)
            clearRefresh(session: session, id: refreshID)
            return accessToken
        } catch {
            clearRefresh(session: session, id: refreshID)
            throw error
        }
    }

    private func clearRefresh(session: TokenSnapshot, id: UUID) {
        guard inFlightRefreshes[session]?.id == id else { return }
        inFlightRefreshes[session] = nil
    }
}
