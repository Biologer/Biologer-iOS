import SwiftUI

struct FindingTaxonSearchScreen: View {
    @ObservedObject private var viewModel: FindingTaxonSearchViewModel
    private let onSelectTaxon: (FindingEditorTaxon) -> Void
    private let onTaxonSync: (() -> Void)?

    init(
        viewModel: FindingTaxonSearchViewModel,
        onSelectTaxon: @escaping (FindingEditorTaxon) -> Void,
        onTaxonSync: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onSelectTaxon = onSelectTaxon
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
        .biologerScreen(title: "FindingEditor.taxon.searchTitle".localized)
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
            prompt: "FindingEditor.taxon.searchPrompt".localized
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            messageState(
                systemImage: "text.magnifyingglass",
                title: "FindingEditor.taxon.searchStart.title".localized,
                message: "FindingEditor.taxon.searchStart.message".localized
            )
        case .loading:
            BiologerLoadingStateView(
                message: "FindingEditor.taxon.searching".localized,
                fillsAvailableSpace: false
            )
        case .results:
            customNameButton
            ForEach(viewModel.results, id: \.apiID) { taxon in
                taxonRow(taxon)
            }
            if viewModel.results.count == 100 {
                Text("FindingEditor.taxon.refineSearch".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(BiologerSpacing.small)
            }
        case .empty:
            customNameButton
            messageState(
                systemImage: "leaf",
                title: "FindingEditor.taxon.noResults.title".localized,
                message: "FindingEditor.taxon.noResults.message".localized
            )
        case .failure:
            messageState(
                systemImage: "exclamationmark.arrow.triangle.2.circlepath",
                title: "FindingEditor.taxon.error.title".localized,
                message: "FindingEditor.taxon.error.message".localized,
                retryAction: viewModel.retry
            )
        }
    }

    private var customNameButton: some View {
        Button {
            guard let taxon = viewModel.customTaxon() else { return }
            onSelectTaxon(taxon)
        } label: {
            HStack(spacing: BiologerSpacing.small) {
                BiologerIconBadge(systemImage: "pencil", size: 38)
                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    Text("FindingEditor.taxon.custom.title".localized)
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
        Button { onSelectTaxon(taxon) } label: {
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
        BiologerMessageStateView(
            systemImage: systemImage,
            title: title,
            message: message,
            actionTitle: retryAction == nil
                ? nil
                : "ListOfFindings.retry".localized,
            fillsAvailableSpace: false,
            action: retryAction
        )
    }
}
