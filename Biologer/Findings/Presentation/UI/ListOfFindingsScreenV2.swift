import SwiftUI

struct ListOfFindingsScreenV2: View {
    @StateObject private var viewModel: ListOfFindingsV2ViewModel
    @State private var deletionSelection: FindingDeletionSelection?

    init(viewModel: ListOfFindingsV2ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            floatingActionButton
        }
        .biologerPageBackground()
        .navigationTitle("SideMenu.lb.listOfFindings".localized)
        .navigationBarTitleDisplayMode(.large)
        .tint(BiologerColors.accent)
        .toolbar {
            toolbarContent
        }
        .onAppear(perform: viewModel.loadFindings)
        .confirmationDialog(
            "ListOfFindings.deleteScreen.title".localized,
            isPresented: deletionConfirmationIsPresented,
            titleVisibility: .visible
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
                isFilterInteractionEnabled: !viewModel.isUploadSelectionActive
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
                    isUploadSelectionActive: viewModel.isUploadSelectionActive,
                    isSelectedForUpload: viewModel.selectedUploadFindingIDs.contains(
                        finding.id
                    ),
                    onSelect: { viewModel.didSelectFinding(finding) },
                    onToggleUploadSelection: {
                        viewModel.toggleUploadSelection(for: finding)
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
        } else {
            addFindingButton
        }
    }

    private var addFindingButton: some View {
        Button(action: viewModel.didTapAddFinding) {
            HStack(spacing: BiologerSpacing.xSmall) {
                Image(systemName: "plus")
                Text("ListOfFindingsV2.add".localized)
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
        .disabled(viewModel.selectedUploadFindingIDs.isEmpty)
        .opacity(viewModel.selectedUploadFindingIDs.isEmpty ? 0.55 : 1)
        .padding(BiologerSpacing.large)
    }

    private func uploadProgressCard(
        _ progress: FindingUploadProgress
    ) -> some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.small) {
            HStack(spacing: BiologerSpacing.small) {
                ProgressView()
                    .tint(BiologerColors.accent)

                Text("ListOfFindingsV2.upload.progress.title".localized)
                    .font(.body.weight(.semibold))
                    .foregroundColor(BiologerColors.textPrimary)

                Spacer()

                Text(
                    String(
                        format: "ListOfFindingsV2.upload.progress.count".localized,
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
        if viewModel.isUploadSelectionActive {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    "Common.btn.cancel".localized,
                    action: viewModel.cancelUploadSelection
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    viewModel.areAllPendingFindingsSelected
                        ? "ListOfFindingsV2.selection.deselectAll".localized
                        : "ListOfFindingsV2.selection.selectAll".localized,
                    action: viewModel.toggleAllPendingFindings
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
                .accessibilityLabel("ListOfFindingsV2.upload".localized)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        deletionSelection = .all
                    } label: {
                        Label(
                            "ListOfFindingsV2.deleteAll".localized,
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
            format: "ListOfFindingsV2.selection.upload".localized,
            viewModel.selectedUploadFindingsCount
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

    private var deletionMessage: String {
        switch deletionSelection {
        case .finding(let finding):
            finding.taxonName.isEmpty ? "-" : finding.taxonName
        case .all:
            "ListOfFindingsV2.deleteAll.message".localized
        case nil:
            ""
        }
    }

    private var actionErrorMessage: String {
        switch viewModel.actionError {
        case .uploadFindings(let completedCount, let totalCount):
            return String(
                format: "ListOfFindingsV2.upload.failure".localized,
                completedCount,
                totalCount
            )
        case .deleteFinding, .deleteAllFindings, nil:
            return "ListOfFindingsV2.actionError.message".localized
        }
    }

    private func confirmDeletion() {
        let selection = deletionSelection
        deletionSelection = nil

        switch selection {
        case .finding(let finding):
            viewModel.deleteFinding(id: finding.id)
        case .all:
            viewModel.deleteAllFindings()
        case nil:
            break
        }
    }
}

private enum FindingDeletionSelection {
    case finding(FindingSummary)
    case all
}
