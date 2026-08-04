import SwiftUI

struct TaxonSyncFlow: View {
    @StateObject private var viewModel: TaxonSyncViewModel
    private let onContinue: (() -> Void)?

    init(
        useCases: TaxonSyncUseCases,
        scopeProvider: TaxonCatalogScopeProviding,
        onContinue: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: TaxonSyncViewModel(useCases: useCases, scopeProvider: scopeProvider))
        self.onContinue = onContinue
    }

    var body: some View {
        TaxonSyncScreen(viewModel: viewModel, onContinue: onContinue)
            .navigationTitle("TaxonSync.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.onAppear() }
            .onDisappear { viewModel.onDisappear() }
    }
}
