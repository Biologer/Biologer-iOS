import SwiftUI

struct ListOfFindingsScreen: View {
    @ObservedObject private var viewModel: ListOfFindingsViewModel
    @State private var deletionSelection: FindingDeletionSelection?
    private let onAddFinding: () -> Void
    private let onSelectFinding: (UUID) -> Void

    init(
        viewModel: ListOfFindingsViewModel,
        onAddFinding: @escaping () -> Void,
        onSelectFinding: @escaping (UUID) -> Void
    ) {
        self.viewModel = viewModel
        self.onAddFinding = onAddFinding
        self.onSelectFinding = onSelectFinding
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            floatingActionButton
        }
        .biologerPageBackground()
        .navigationTitle("Findings.title".localized)
        .navigationBarTitleDisplayMode(.large)
        .tint(BiologerColors.accent)
        .toolbar {
            toolbarContent
        }
        .onAppear(perform: viewModel.loadFindings)
        .alert(
            deletionTitle,
            isPresented: deletionConfirmationIsPresented
        ) {
            Button(
                "ListOfFindings.deleteScreen.btn.delete".localized,
                role: .destructive,
                action: confirmDeletion
            )
            Button("Common.btn.cancel".localized, role: .cancel) {}
        } message: {
            Text(deletionMessage)
        }
        .alert(
            "API.lb.error".localized,
            isPresented: actionErrorIsPresented
        ) {
            Button("Common.btn.ok".localized) {
                viewModel.dismissActionError()
            }
        } message: {
            Text(actionErrorMessage)
        }
        .alert(
            "Common.title.warning".localized,
            isPresented: submissionWarningIsPresented
        ) {
            Button("Common.btn.ok".localized) {
                guard viewModel.confirmSubmissionWarning() else { return }
                onAddFinding()
            }
        } message: {
            Text("ListOfFindings.popUpUserVerified.description".localized)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            FindingsLoadingView()
        case .empty:
            FindingsEmptyView()
        case .content:
            findingsList
        case .failure:
            FindingsFailureView(onRetry: viewModel.loadFindings)
        }
    }

    private var findingsList: some View {
        List {
            FindingsOverviewCard(
                findings: viewModel.findings,
                selectedFilter: viewModel.selectedFilter,
                isFilterInteractionEnabled: !viewModel.isSelectionActive
                    && !viewModel.isUploading,
                onSelectFilter: viewModel.selectFilter
            )
                .listRowInsets(
                    EdgeInsets(
                        top: BiologerSpacing.small,
                        leading: BiologerSpacing.regular,
                        bottom: BiologerSpacing.regular,
                        trailing: BiologerSpacing.regular
                    )
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            if viewModel.visibleFindings.isEmpty {
                FindingsFilteredEmptyView(filter: viewModel.selectedFilter)
                    .listRowInsets(
                        EdgeInsets(
                            top: BiologerSpacing.small,
                            leading: BiologerSpacing.regular,
                            bottom: BiologerSpacing.small,
                            trailing: BiologerSpacing.regular
                        )
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(viewModel.visibleFindings) { finding in
                FindingSummaryRow(
                    finding: finding,
                    isSelectionActive: viewModel.isSelectionActive,
                    isSelected: viewModel.selectedFindingIDs.contains(finding.id),
                    isDestructiveSelection: viewModel.isDeletionSelectionActive,
                    onSelect: {
                        guard viewModel.canSelectFinding(finding) else { return }
                        onSelectFinding(finding.id)
                    },
                    onToggleSelection: {
                        viewModel.toggleSelection(for: finding)
                    },
                    onDelete: { deletionSelection = .finding(finding) }
                )
                .listRowInsets(
                    EdgeInsets(
                        top: BiologerSpacing.xSmall / 2,
                        leading: BiologerSpacing.regular,
                        bottom: BiologerSpacing.xSmall / 2,
                        trailing: BiologerSpacing.regular
                    )
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Color.clear
                .frame(height: viewModel.isUploading ? 116 : 76)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            viewModel.loadFindings()
        }
    }

    @ViewBuilder
    private var floatingActionButton: some View {
        if let progress = viewModel.uploadState.progress,
           viewModel.isUploading {
            uploadProgressCard(progress)
        } else if viewModel.isUploadSelectionActive {
            uploadSelectedButton
        } else if viewModel.isDeletionSelectionActive {
            deleteSelectedButton
        } else {
            addFindingButton
        }
    }

    private var addFindingButton: some View {
        Button {
            guard viewModel.canAddFinding() else { return }
            onAddFinding()
        } label: {
            HStack(spacing: BiologerSpacing.xSmall) {
                Image(systemName: "plus")
                Text("ListOfFindings.add".localized)
            }
            .font(.body.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, BiologerSpacing.regular)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [
                        BiologerColors.brandStrong,
                        BiologerColors.accent
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: Capsule()
            )
            .shadow(
                color: BiologerColors.brandStrong.opacity(0.3),
                radius: 10,
                y: 5
            )
        }
        .buttonStyle(.plain)
        .padding(BiologerSpacing.large)
    }

    private var uploadSelectedButton: some View {
        Button(action: viewModel.uploadSelectedFindings) {
            HStack(spacing: BiologerSpacing.xSmall) {
                Image(systemName: "icloud.and.arrow.up")
                Text(uploadSelectedButtonTitle)
            }
        }
        .buttonStyle(BiologerActionButtonStyle())
        .disabled(viewModel.selectedFindingIDs.isEmpty)
        .opacity(viewModel.selectedFindingIDs.isEmpty ? 0.55 : 1)
        .padding(BiologerSpacing.large)
    }

    private var deleteSelectedButton: some View {
        Button {
            deletionSelection = .selected(
                count: viewModel.selectedDeletionFindingsCount
            )
        } label: {
            HStack(spacing: BiologerSpacing.xSmall) {
                Image(systemName: "trash")
                Text(deleteSelectedButtonTitle)
            }
        }
        .buttonStyle(BiologerActionButtonStyle(role: .destructive))
        .disabled(viewModel.selectedFindingIDs.isEmpty)
        .opacity(viewModel.selectedFindingIDs.isEmpty ? 0.55 : 1)
        .padding(BiologerSpacing.large)
    }

    private func uploadProgressCard(
        _ progress: FindingUploadProgress
    ) -> some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.small) {
            HStack(spacing: BiologerSpacing.small) {
                ProgressView()
                    .tint(BiologerColors.accent)

                Text("ListOfFindings.upload.progress.title".localized)
                    .font(.body.weight(.semibold))
                    .foregroundColor(BiologerColors.textPrimary)

                Spacer()

                Text(
                    String(
                        format: "ListOfFindings.upload.progress.count".localized,
                        progress.completedCount,
                        progress.totalCount
                    )
                )
                .font(.subheadline.monospacedDigit().weight(.medium))
                .foregroundColor(.secondary)
            }

            ProgressView(value: progress.fractionCompleted)
                .tint(BiologerColors.accent)
        }
        .padding(BiologerSpacing.regular)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(BiologerColors.accent.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.12), radius: 12, y: 5)
        .padding(BiologerSpacing.regular)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if viewModel.isSelectionActive {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    "Common.btn.cancel".localized,
                    action: viewModel.cancelSelection
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    viewModel.areAllSelectableFindingsSelected
                        ? "ListOfFindings.selection.deselectAll".localized
                        : "ListOfFindings.selection.selectAll".localized,
                    action: viewModel.toggleAllSelectableFindings
                )
            }
        } else {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: viewModel.beginUploadSelection) {
                    Image(systemName: "icloud.and.arrow.up")
                }
                .disabled(
                    viewModel.pendingFindingsCount == 0
                        || viewModel.isUploading
                )
                .accessibilityLabel("ListOfFindings.upload".localized)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: viewModel.beginDeletionSelection) {
                        Label(
                            "ListOfFindings.selection.deleteMode".localized,
                            systemImage: "checkmark.circle"
                        )
                    }
                    .disabled(viewModel.findings.isEmpty || viewModel.isUploading)

                    Button(role: .destructive) {
                        deletionSelection = .all
                    } label: {
                        Label(
                            "ListOfFindings.deleteAll".localized,
                            systemImage: "trash"
                        )
                    }
                    .disabled(viewModel.findings.isEmpty || viewModel.isUploading)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private var uploadSelectedButtonTitle: String {
        String(
            format: "ListOfFindings.selection.upload".localized,
            viewModel.selectedUploadFindingsCount
        )
    }

    private var deleteSelectedButtonTitle: String {
        String(
            format: "ListOfFindings.selection.delete".localized,
            viewModel.selectedDeletionFindingsCount
        )
    }

    private var deletionConfirmationIsPresented: Binding<Bool> {
        Binding(
            get: { deletionSelection != nil },
            set: { isPresented in
                if !isPresented {
                    deletionSelection = nil
                }
            }
        )
    }

    private var actionErrorIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.actionError != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissActionError()
                }
            }
        )
    }

    private var submissionWarningIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.submissionWarning != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissSubmissionWarning()
                }
            }
        )
    }

    private var deletionMessage: String {
        switch deletionSelection {
        case .finding(let finding):
            return String(
                format: "ListOfFindings.delete.single.message".localized,
                finding.taxonName.isEmpty ? "-" : finding.taxonName
            )
        case .selected(let count):
            return String(
                format: "ListOfFindings.delete.selected.message".localized,
                count
            )
        case .all:
            return "ListOfFindings.deleteAll.message".localized
        case nil:
            return ""
        }
    }

    private var deletionTitle: String {
        switch deletionSelection {
        case .finding:
            return "ListOfFindings.delete.single.title".localized
        case .selected:
            return "ListOfFindings.delete.selected.title".localized
        case .all:
            return "ListOfFindings.delete.all.title".localized
        case nil:
            return ""
        }
    }

    private var actionErrorMessage: String {
        switch viewModel.actionError {
        case .uploadFindings(let completedCount, let totalCount):
            return String(
                format: "ListOfFindings.upload.failure".localized,
                completedCount,
                totalCount
            )
        case .deleteFinding, .deleteFindings, .deleteAllFindings, nil:
            return "ListOfFindings.actionError.message".localized
        }
    }

    private func confirmDeletion() {
        let selection = deletionSelection
        deletionSelection = nil

        switch selection {
        case .finding(let finding):
            viewModel.deleteFinding(id: finding.id)
        case .selected:
            viewModel.deleteSelectedFindings()
        case .all:
            viewModel.deleteAllFindings()
        case nil:
            break
        }
    }
}

private enum FindingDeletionSelection {
    case finding(FindingSummary)
    case selected(count: Int)
    case all
}
