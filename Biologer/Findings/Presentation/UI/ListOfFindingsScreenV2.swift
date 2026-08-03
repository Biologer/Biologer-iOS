import SwiftUI

struct ListOfFindingsScreenV2: View {
    @StateObject private var viewModel: ListOfFindingsV2ViewModel
    @State private var deletionSelection: FindingDeletionSelection?

    private let onUploadFindings: Observer<Void>

    init(
        viewModel: ListOfFindingsV2ViewModel,
        onUploadFindings: @escaping Observer<Void>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onUploadFindings = onUploadFindings
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            addFindingButton
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
            Text("ListOfFindingsV2.actionError.message".localized)
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
            FindingsOverviewCard(findings: viewModel.findings)
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

            ForEach(viewModel.findings) { finding in
                FindingSummaryRow(
                    finding: finding,
                    onSelect: { viewModel.didSelectFinding(finding) },
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
                .frame(height: 76)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            viewModel.loadFindings()
        }
    }

    private var addFindingButton: some View {
        Button(action: viewModel.didTapAddFinding) {
            Label(
                "ListOfFindingsV2.add".localized,
                systemImage: "plus"
            )
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

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onUploadFindings(())
            } label: {
                Image(systemName: "icloud.and.arrow.up")
            }
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
                .disabled(viewModel.findings.isEmpty)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
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
