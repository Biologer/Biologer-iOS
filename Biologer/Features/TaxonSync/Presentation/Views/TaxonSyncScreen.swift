import SwiftUI

struct TaxonSyncScreen: View {
    /// The screen observes the ViewModel owned by its parent flow and does not
    /// restart either state observation or synchronization when it is rebuilt.
    @ObservedObject var viewModel: TaxonSyncViewModel
    let onContinue: (() -> Void)?

    init(viewModel: TaxonSyncViewModel, onContinue: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onContinue = onContinue
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                statusCard
                if let progress = viewModel.viewState.progress {
                    progressCard(progress)
                }
                actions
                if let onContinue, viewModel.viewState.canContinue {
                    Button("TaxonSync.action.continue".localized, action: onContinue)
                        .buttonStyle(BiologerActionButtonStyle(isFilled: false))
                        .padding(.top, 4)
                }
            }
            .padding(16)
        }
        .biologerPageBackground()
        .biologerScreen(title: "TaxonSync.title".localized)
    }

    private var header: some View {
        HStack(spacing: 14) {
            BiologerIconBadge(systemImage: "leaf.fill", tint: .white, backgroundColor: BiologerColors.accent)
            VStack(alignment: .leading, spacing: 4) {
                Text("TaxonSync.title".localized).font(.title3.weight(.bold)).foregroundStyle(.white)
                Text("TaxonSync.subtitle".localized).font(.subheadline).foregroundStyle(.white.opacity(0.82))
            }
            Spacer()
        }
        .padding(18)
        .background(LinearGradient(colors: [BiologerColors.brandStrong, BiologerColors.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.viewState.statusTitle)
                        .font(.headline)
                        .foregroundStyle(BiologerColors.textPrimary)
                    Text(viewModel.viewState.statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(
                            BiologerColors.textPrimary.opacity(0.7)
                        )
                }
                Spacer()
                Image(systemName: "arrow.triangle.2.circlepath").font(.title2).foregroundStyle(BiologerColors.brandStrong)
            }
            if let status = viewModel.viewState.catalogStatus {
                metadata(status)
            }
        }
        .padding(16)
        .biologerCard()
    }

    private func metadata(_ status: TaxonCatalogStatus) -> some View {
        HStack(spacing: 18) {
            Label("\(status.localTaxaCount)", systemImage: "number")
            Label(status.scope.environmentHost, systemImage: "server.rack")
                .lineLimit(1)
        }
        .font(.caption.weight(.medium)).foregroundStyle(BiologerColors.textPrimary.opacity(0.7))
    }

    private func progressCard(_ progress: TaxonSyncProgress) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            BiologerProgressSummary(
                title: "TaxonSync.progress.title".localized,
                progress: progress.fractionCompleted,
                valueText: "\(Int(progress.fractionCompleted * 100))%",
                showsActivityIndicator: viewModel.viewState.canPause
            )
            HStack {
                Text(
                    String(
                        format: "TaxonSync.progress.taxa".localized,
                        progress.importedTaxaCount,
                        progress.totalTaxaCount
                    )
                )
                Spacer()
                Text(
                    String(
                        format: "TaxonSync.progress.pages".localized,
                        progress.completedPages,
                        progress.totalPages
                    )
                )
            }
            .font(.caption)
            .foregroundStyle(BiologerColors.textPrimary.opacity(0.7))
        }
        .padding(16)
        .biologerCard()
    }

    private var actions: some View {
        VStack(spacing: 10) {
            if let primary = viewModel.viewState.primaryAction {
                Button(primary.title) { viewModel.perform(primary.action) }
                    .buttonStyle(BiologerActionButtonStyle())
                    .disabled(!primary.isEnabled)
            }
            if viewModel.viewState.canPause {
                Button("TaxonSync.action.pause".localized) { viewModel.perform(.pause) }
                    .buttonStyle(BiologerActionButtonStyle(isFilled: false))
            }
        }
    }
}
