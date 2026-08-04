import SwiftUI

struct TaxonSyncFlow: View {
    @StateObject private var viewModel: TaxonSyncViewModel

    init(useCases: TaxonSyncUseCases, scopeProvider: TaxonCatalogScopeProviding) {
        _viewModel = StateObject(wrappedValue: TaxonSyncViewModel(useCases: useCases, scopeProvider: scopeProvider))
    }

    var body: some View {
        TaxonSyncScreen(viewModel: viewModel)
            .navigationTitle("Taxon database")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.onAppear() }
            .onDisappear { viewModel.onDisappear() }
    }
}
