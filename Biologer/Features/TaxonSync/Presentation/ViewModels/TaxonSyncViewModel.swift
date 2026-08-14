import Foundation
import SwiftUI

@MainActor
final class TaxonSyncViewModel: ObservableObject {
    @Published private(set) var viewState: TaxonSyncViewState

    private let service: TaxonSyncService
    private let scopeProvider: TaxonCatalogScopeProviding
    private let viewStateMapper: TaxonSyncViewStateMapper

    private var state: TaxonSyncState?
    private var stateScope: TaxonCatalogScope?
    private var actionFailure: TaxonSyncFailure?
    private var primaryActionTask: Task<Void, Never>?
    private var primaryActionScope: TaxonCatalogScope?

    init(
        service: TaxonSyncService,
        scopeProvider: TaxonCatalogScopeProviding,
        viewStateMapper: TaxonSyncViewStateMapper = TaxonSyncViewStateMapper()
    ) {
        self.service = service
        self.scopeProvider = scopeProvider
        self.viewStateMapper = viewStateMapper
        self.viewState = viewStateMapper.map(
            state: nil,
            actionFailure: nil,
            isPerformingPrimaryAction: false
        )
    }

    /// The screen owns this observation task; disappearing cancels only the subscription.
    func observeState() async {
        guard let scope = scopeProvider.currentScope() else {
            resetState()
            return
        }

        prepareForObservation(scope: scope)
        let stream = await service.observe(scope: scope)

        for await nextState in stream {
            guard !Task.isCancelled else { return }
            guard scopeProvider.currentScope() == scope else {
                resetState(ifCurrentScopeIs: scope)
                return
            }

            state = nextState
            updateViewState()
        }
    }

    func perform(_ action: TaxonSyncAction) {
        guard let scope = scopeProvider.currentScope(), stateScope == scope else {
            return
        }

        if action == .pause {
            Task { await service.pause(scope: scope) }
            return
        }

        guard primaryActionTask == nil else { return }
        actionFailure = nil
        primaryActionScope = scope
        updateViewState(isPerformingPrimaryAction: true)

        // This task belongs to the ViewModel, not the screen observation, so an active
        // sync may continue after navigating back while the parent flow still owns it.
        primaryActionTask = Task { [weak self] in
            guard let self else { return }
            await self.execute(action, scope: scope)
            self.finishPrimaryAction(scope: scope)
        }
    }

    private func execute(
        _ action: TaxonSyncAction,
        scope: TaxonCatalogScope
    ) async {
        switch action {
        case .check:
            do {
                _ = try await service.checkForUpdates(scope: scope)
            } catch let failure {
                guard stateScope == scope else { return }
                actionFailure = failure
            }
        case .start:
            await service.start(scope: scope)
        case .resume:
            await service.resume(scope: scope)
        case .pause:
            break
        }
    }

    private func prepareForObservation(scope: TaxonCatalogScope) {
        guard stateScope != scope else { return }

        primaryActionTask?.cancel()
        primaryActionTask = nil
        primaryActionScope = nil
        stateScope = scope
        state = nil
        actionFailure = nil
        updateViewState()
    }

    private func resetState(ifCurrentScopeIs scope: TaxonCatalogScope) {
        guard stateScope == scope else { return }
        resetState()
    }

    private func resetState() {
        primaryActionTask?.cancel()
        primaryActionTask = nil
        primaryActionScope = nil
        stateScope = nil
        state = nil
        actionFailure = nil
        updateViewState()
    }

    private func finishPrimaryAction(scope: TaxonCatalogScope) {
        guard primaryActionScope == scope else { return }
        primaryActionTask = nil
        primaryActionScope = nil
        updateViewState()
    }

    private func updateViewState(
        isPerformingPrimaryAction: Bool? = nil
    ) {
        viewState = viewStateMapper.map(
            state: state,
            actionFailure: actionFailure,
            isPerformingPrimaryAction: isPerformingPrimaryAction
                ?? (primaryActionTask != nil)
        )
    }
}
