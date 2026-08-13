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

    init(useCases: TaxonSyncUseCases, scopeProvider: TaxonCatalogScopeProviding) {
        self.useCases = useCases
        self.scopeProvider = scopeProvider
    }

    func observeState() async {
        guard let scope = scopeProvider.currentScope() else { return }

        let stream = await useCases.observeState.execute(scope: scope)
        for await nextState in stream {
            guard !Task.isCancelled else { return }
            state = nextState
        }
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
        case .updateAvailable: return "TaxonSync.status.update.title".localized
        case .waitingForNetwork: return "TaxonSync.status.waiting.title".localized
        case .paused: return "TaxonSync.status.paused.title".localized
        case .failed: return "TaxonSync.status.failed.title".localized
        case .none: return "TaxonSync.title".localized
        }
    }

    var statusMessage: String {
        switch state {
        case .idle(let status), .completed(let status):
            return availabilityMessage(status.availability)
        case .working: return "TaxonSync.status.working.message".localized
        case .updateAvailable(let update): return String(format: "TaxonSync.status.update.message".localized, update.changedTaxaCount)
        case .waitingForNetwork: return "TaxonSync.status.waiting.message".localized
        case .paused: return "TaxonSync.status.paused.message".localized
        case .failed(let failure, _): return errorMessage ?? message(for: failure)
        case .none: return "TaxonSync.status.default.message".localized
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
        case .updateAvailable: return ("TaxonSync.action.download".localized, .start)
        case .paused, .waitingForNetwork: return ("TaxonSync.action.resume".localized, .resume)
        case .failed(_, let progress):
            return ("TaxonSync.action.retry".localized, progress == nil ? .start : .resume)
        case .idle(let status):
            return status.availability == .empty
                ? ("TaxonSync.action.downloadDatabase".localized, .start)
                : ("TaxonSync.action.check".localized, .check)
        case .completed:
            return ("TaxonSync.action.check".localized, .check)
        default: return nil
        }
    }

    var canPause: Bool {
        if case .working(let phase, _) = state {
            return phase == .downloading || phase == .importing
        }
        return false
    }

    var canContinue: Bool {
        switch state {
        case .idle(let status), .completed(let status):
            return status.availability == .ready
        default:
            return false
        }
    }

    private func availabilityTitle(_ availability: TaxonCatalogAvailability) -> String {
        switch availability {
        case .empty:
            return "TaxonSync.status.empty.title".localized
        case .initialCatalogLoaded:
            return "TaxonSync.status.initial.title".localized
        case .partial:
            return "TaxonSync.status.partial.title".localized
        case .ready:
            return "TaxonSync.status.ready.title".localized
        }
    }

    private func phaseTitle(_ phase: TaxonSyncPhase) -> String {
        switch phase {
        case .loadingInitialCatalog:
            return "TaxonSync.phase.initial".localized
        case .checking:
            return "TaxonSync.phase.checking".localized
        case .downloading:
            return "TaxonSync.phase.downloading".localized
        case .importing:
            return "TaxonSync.phase.importing".localized
        }
    }

    private func availabilityMessage(
        _ availability: TaxonCatalogAvailability
    ) -> String {
        switch availability {
        case .empty:
            return "TaxonSync.status.empty.message".localized
        case .initialCatalogLoaded:
            return "TaxonSync.status.initial.message".localized
        case .partial:
            return "TaxonSync.status.partial.message".localized
        case .ready:
            return "TaxonSync.status.ready.message".localized
        }
    }

    private func message(for failure: TaxonSyncFailure) -> String {
        switch failure {
        case .networkUnavailable:
            return "TaxonSync.error.network".localized
        case .unauthorized:
            return "TaxonSync.error.unauthorized".localized
        case .initialCatalogUnavailable:
            return "TaxonSync.error.initial".localized
        case .localPersistence:
            return "TaxonSync.error.persistence".localized
        default:
            return "TaxonSync.status.failed.message".localized
        }
    }
}
