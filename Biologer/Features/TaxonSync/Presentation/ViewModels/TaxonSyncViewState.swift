import Foundation

enum TaxonSyncAction: Equatable {
    case check
    case start
    case pause
    case resume
}

struct TaxonSyncPrimaryAction: Equatable {
    let title: String
    let action: TaxonSyncAction
    let isEnabled: Bool
}

struct TaxonSyncViewState: Equatable {
    let statusTitle: String
    let statusMessage: String
    let catalogStatus: TaxonCatalogStatus?
    let progress: TaxonSyncProgress?
    let primaryAction: TaxonSyncPrimaryAction?
    let canPause: Bool
    let canContinue: Bool
}

struct TaxonSyncViewStateMapper {
    func map(
        state: TaxonSyncState?,
        actionFailure: TaxonSyncFailure?,
        isPerformingPrimaryAction: Bool
    ) -> TaxonSyncViewState {
        TaxonSyncViewState(
            statusTitle: statusTitle(for: state),
            statusMessage: statusMessage(
                for: state,
                actionFailure: actionFailure
            ),
            catalogStatus: state?.catalogStatus,
            progress: progress(for: state),
            primaryAction: primaryAction(
                for: state,
                isEnabled: !isPerformingPrimaryAction
            ),
            canPause: canPause(state),
            canContinue: state?.hasUsableCatalog == true
        )
    }

    private func statusTitle(for state: TaxonSyncState?) -> String {
        guard let state else { return "TaxonSync.title".localized }

        switch state.operation {
        case .idle, .completed:
            return availabilityTitle(state.catalogStatus?.availability)
        case .working(let phase, _):
            return phaseTitle(phase)
        case .updateAvailable:
            return "TaxonSync.status.update.title".localized
        case .waitingForNetwork:
            return "TaxonSync.status.waiting.title".localized
        case .paused:
            return "TaxonSync.status.paused.title".localized
        case .failed:
            return "TaxonSync.status.failed.title".localized
        }
    }

    private func statusMessage(
        for state: TaxonSyncState?,
        actionFailure: TaxonSyncFailure?
    ) -> String {
        guard let state else {
            return "TaxonSync.status.default.message".localized
        }

        switch state.operation {
        case .idle, .completed:
            return availabilityMessage(state.catalogStatus?.availability)
        case .working:
            return "TaxonSync.status.working.message".localized
        case .updateAvailable(let update):
            return String(
                format: "TaxonSync.status.update.message".localized,
                update.changedTaxaCount
            )
        case .waitingForNetwork:
            return "TaxonSync.status.waiting.message".localized
        case .paused:
            return "TaxonSync.status.paused.message".localized
        case .failed(let failure, _):
            return message(for: actionFailure ?? failure)
        }
    }

    private func progress(
        for state: TaxonSyncState?
    ) -> TaxonSyncProgress? {
        guard let state else { return nil }

        switch state.operation {
        case .working(_, let progress),
             .waitingForNetwork(let progress),
             .paused(let progress),
             .failed(_, let progress):
            return progress
        case .idle, .updateAvailable, .completed:
            return nil
        }
    }

    private func primaryAction(
        for state: TaxonSyncState?,
        isEnabled: Bool
    ) -> TaxonSyncPrimaryAction? {
        guard let state else { return nil }

        let action: (title: String, action: TaxonSyncAction)?
        switch state.operation {
        case .updateAvailable:
            action = ("TaxonSync.action.download".localized, .start)
        case .paused, .waitingForNetwork:
            action = ("TaxonSync.action.resume".localized, .resume)
        case .failed(_, let progress):
            action = (
                "TaxonSync.action.retry".localized,
                progress == nil ? .start : .resume
            )
        case .idle:
            guard let availability = state.catalogStatus?.availability else {
                return nil
            }
            action = availability == .empty
                ? ("TaxonSync.action.downloadDatabase".localized, .start)
                : ("TaxonSync.action.check".localized, .check)
        case .completed:
            action = ("TaxonSync.action.check".localized, .check)
        case .working:
            action = nil
        }

        guard let action else { return nil }
        return TaxonSyncPrimaryAction(
            title: action.title,
            action: action.action,
            isEnabled: isEnabled
        )
    }

    private func canPause(_ state: TaxonSyncState?) -> Bool {
        guard case .working(let phase, _) = state?.operation else {
            return false
        }
        return phase == .downloading || phase == .importing
    }

    private func availabilityTitle(
        _ availability: TaxonCatalogAvailability?
    ) -> String {
        switch availability {
        case .empty:
            return "TaxonSync.status.empty.title".localized
        case .initialCatalogLoaded:
            return "TaxonSync.status.initial.title".localized
        case .partial:
            return "TaxonSync.status.partial.title".localized
        case .ready:
            return "TaxonSync.status.ready.title".localized
        case .none:
            return "TaxonSync.title".localized
        }
    }

    private func availabilityMessage(
        _ availability: TaxonCatalogAvailability?
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
        case .none:
            return "TaxonSync.status.default.message".localized
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
