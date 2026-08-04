import Foundation
import SwiftUI

@MainActor
final class TaxonSyncViewModel: ObservableObject {
    enum Action {
        case check, start, pause, resume
    }

    @Published private(set) var state: TaxonSyncState?
    @Published private(set) var errorMessage: String?

    private let useCases: TaxonSyncUseCases
    private let scopeProvider: TaxonCatalogScopeProviding
    private var observationTask: Task<Void, Never>?

    init(useCases: TaxonSyncUseCases, scopeProvider: TaxonCatalogScopeProviding) {
        self.useCases = useCases
        self.scopeProvider = scopeProvider
    }

    func onAppear() {
        guard observationTask == nil, let scope = scopeProvider.currentScope() else { return }

        observationTask = Task { [weak self] in
            guard let self else { return }
            self.state = await self.useCases.getState.execute(scope: scope)
            let stream = await self.useCases.observeState.execute(scope: scope)
            for await nextState in stream {
                guard !Task.isCancelled else { return }
                self.state = nextState
            }
        }
    }

    func onDisappear() {
        observationTask?.cancel()
        observationTask = nil
    }

    func perform(_ action: Action) {
        guard let scope = scopeProvider.currentScope() else { return }
        errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            switch action {
            case .check:
                do { _ = try await self.useCases.checkForUpdates.execute(scope: scope) }
                catch { self.errorMessage = self.message(for: error as? TaxonSyncFailure ?? .unknown) }
            case .start:
                await self.useCases.start.execute(scope: scope)
            case .pause:
                await self.useCases.pause.execute(scope: scope)
            case .resume:
                await self.useCases.resume.execute(scope: scope)
            }
        }
    }

    var statusTitle: String {
        switch state {
        case .idle(let status), .completed(let status): return availabilityTitle(status.availability)
        case .working(let phase, _): return phaseTitle(phase)
        case .updateAvailable: return "Updates available"
        case .waitingForNetwork: return "Waiting for connection"
        case .paused: return "Download paused"
        case .failed: return "Update failed"
        case .none: return "Taxon database"
        }
    }

    var statusMessage: String {
        switch state {
        case .idle(let status), .completed(let status):
            return status.availability == .ready ? "The local taxon database is ready to use." : "Download the taxon database to search species offline."
        case .working: return "Your taxon database is being updated."
        case .updateAvailable(let update): return "\(update.changedTaxaCount) taxa are ready to download."
        case .waitingForNetwork: return "A network connection is required to continue."
        case .paused: return "The download is paused and can be resumed at any time."
        case .failed: return errorMessage ?? "The taxon database could not be updated."
        case .none: return "Keep the taxon database up to date for reliable search."
        }
    }

    var progress: TaxonSyncProgress? {
        switch state {
        case .working(_, let progress), .waitingForNetwork(let progress), .paused(let progress), .failed(_, let progress): return progress
        default: return nil
        }
    }

    var primaryAction: (title: String, action: Action)? {
        switch state {
        case .updateAvailable: return ("Download updates", .start)
        case .paused, .waitingForNetwork: return ("Resume", .resume)
        case .failed, .idle, .completed: return ("Check for updates", .check)
        default: return nil
        }
    }

    var canPause: Bool {
        if case .working = state { return true }
        return false
    }

    private func availabilityTitle(_ availability: TaxonCatalogAvailability) -> String {
        switch availability { case .empty: return "Taxon database is empty"; case .initialCatalogLoaded: return "Initial catalog loaded"; case .partial: return "Catalog is partially loaded"; case .ready: return "Catalog is up to date" }
    }

    private func phaseTitle(_ phase: TaxonSyncPhase) -> String {
        switch phase { case .loadingInitialCatalog: return "Loading initial catalog"; case .checking: return "Checking for updates"; case .downloading: return "Downloading updates"; case .importing: return "Importing taxa" }
    }

    private func message(for failure: TaxonSyncFailure) -> String {
        switch failure { case .networkUnavailable: return "Check your internet connection and try again."; case .unauthorized: return "Your session has expired. Please log in again."; case .initialCatalogUnavailable: return "The initial taxon catalog is unavailable."; case .localPersistence: return "The local taxon database could not be saved."; default: return "The taxon database could not be updated." }
    }
}
