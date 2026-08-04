import SwiftUI

struct FindingTaxonSearchScreenV2: View {
    @StateObject private var viewModel: FindingTaxonSearchV2ViewModel
    private let onTaxonSync: (() -> Void)?

    init(viewModel: FindingTaxonSearchV2ViewModel, onTaxonSync: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onTaxonSync = onTaxonSync
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: BiologerSpacing.small) {
                content
            }
            .padding(.horizontal, BiologerSpacing.regular)
            .padding(.vertical, BiologerSpacing.small)
        }
        .biologerPageBackground()
        .navigationTitle("NewTaxon.search.nav.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let onTaxonSync {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onTaxonSync) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .accessibilityLabel("TaxonSync.title".localized)
                }
            }
        }
        .searchable(
            text: $viewModel.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "FindingEditorV2.taxon.searchPrompt".localized
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .tint(BiologerColors.accent)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            messageState(
                systemImage: "text.magnifyingglass",
                title: "FindingEditorV2.taxon.searchStart.title".localized,
                message: "FindingEditorV2.taxon.searchStart.message".localized
            )
        case .loading:
            VStack(spacing: BiologerSpacing.small) {
                ProgressView().controlSize(.large).tint(BiologerColors.accent)
                Text("FindingEditorV2.taxon.searching".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, BiologerSpacing.xxLarge)
        case .results:
            customNameButton
            ForEach(viewModel.results, id: \.apiID) { taxon in
                taxonRow(taxon)
            }
            if viewModel.results.count == 100 {
                Text("FindingEditorV2.taxon.refineSearch".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(BiologerSpacing.small)
            }
        case .empty:
            customNameButton
            messageState(
                systemImage: "leaf",
                title: "FindingEditorV2.taxon.noResults.title".localized,
                message: "FindingEditorV2.taxon.noResults.message".localized
            )
        case .failure:
            messageState(
                systemImage: "exclamationmark.arrow.triangle.2.circlepath",
                title: "FindingEditorV2.taxon.error.title".localized,
                message: "FindingEditorV2.taxon.error.message".localized,
                retryAction: viewModel.retry
            )
        }
    }

    private var customNameButton: some View {
        Button(action: viewModel.useCustomName) {
            HStack(spacing: BiologerSpacing.small) {
                BiologerIconBadge(systemImage: "pencil", size: 38)
                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    Text("FindingEditorV2.taxon.custom.title".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.normalizedQuery)
                        .font(.body.weight(.semibold))
                        .foregroundColor(BiologerColors.textPrimary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(BiologerColors.accent)
            }
            .padding(BiologerSpacing.regular)
            .biologerCard()
        }
        .buttonStyle(.plain)
    }

    private func taxonRow(_ taxon: FindingEditorTaxon) -> some View {
        Button { viewModel.select(taxon) } label: {
            HStack(spacing: BiologerSpacing.small) {
                BiologerIconBadge(systemImage: "leaf.fill", size: 38)
                Text(taxon.name)
                    .font(.body.weight(.medium))
                    .italic()
                    .foregroundColor(BiologerColors.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: BiologerSpacing.xSmall)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(BiologerColors.accent)
            }
            .padding(BiologerSpacing.regular)
            .biologerCard()
        }
        .buttonStyle(.plain)
    }

    private func messageState(
        systemImage: String,
        title: String,
        message: String,
        retryAction: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: BiologerSpacing.regular) {
            BiologerIconBadge(systemImage: systemImage, size: 62)
            VStack(spacing: BiologerSpacing.xSmall) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(BiologerColors.textPrimary)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            if let retryAction {
                Button("ListOfFindingsV2.retry".localized, action: retryAction)
                    .buttonStyle(BiologerActionButtonStyle())
                    .frame(maxWidth: 240)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, BiologerSpacing.xLarge)
        .padding(.top, BiologerSpacing.xxLarge)
    }
}
