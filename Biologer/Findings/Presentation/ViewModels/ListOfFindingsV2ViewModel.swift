import Combine
import Foundation

enum ListOfFindingsV2LoadState: Equatable {
    case idle
    case loading
    case empty
    case content
    case failure
}

enum ListOfFindingsV2ActionError: Equatable {
    case deleteFinding
    case deleteAllFindings
    case uploadFindings(completedCount: Int, totalCount: Int)
}

@MainActor
final class ListOfFindingsV2ViewModel: ObservableObject {
    @Published private(set) var findings: [FindingSummary] = []
    @Published private(set) var loadState: ListOfFindingsV2LoadState = .idle
    @Published private(set) var actionError: ListOfFindingsV2ActionError?
    @Published private(set) var selectedFilter: FindingsListFilter = .all
    @Published private(set) var isUploadSelectionActive = false
    @Published private(set) var selectedUploadFindingIDs: Set<UUID> = []
    @Published private(set) var uploadState: FindingUploadViewState = .idle
    @Published private(set) var navigationFindingID: UUID?

    private let useCases: FindingsUseCases
    private let uploadFindings: UploadFindingsUseCase
    private let onAddFinding: () -> Void
    private var filterBeforeUploadSelection: FindingsListFilter?
    private var uploadTask: Task<Void, Never>?

    init(
        useCases: FindingsUseCases,
        onAddFinding: @escaping () -> Void,
        uploadFindings: UploadFindingsUseCase
    ) {
        self.useCases = useCases
        self.onAddFinding = onAddFinding
        self.uploadFindings = uploadFindings
    }

    var isUploading: Bool {
        uploadState.isUploading
    }

    var visibleFindings: [FindingSummary] {
        findings.filter(selectedFilter.includes)
    }

    var pendingFindingsCount: Int {
        findings.filter { $0.uploadStatus == .pending }.count
    }

    var selectedUploadFindingsCount: Int {
        selectedUploadFindingIDs.count
    }

    var areAllPendingFindingsSelected: Bool {
        let pendingIDs = Set(
            findings
                .filter { $0.uploadStatus == .pending }
                .map(\.id)
        )
        return !pendingIDs.isEmpty && pendingIDs == selectedUploadFindingIDs
    }

    func loadFindings() {
        guard !isUploading else { return }
        loadState = .loading

        do {
            findings = try useCases.getFindings.execute()
            synchronizeUploadSelection()
            loadState = findings.isEmpty ? .empty : .content
        } catch {
            findings = []
            cancelUploadSelection()
            loadState = .failure
        }
    }

    func didTapAddFinding() {
        guard !isUploading else { return }
        onAddFinding()
    }

    func didSelectFinding(_ finding: FindingSummary) {
        guard !isUploading else { return }
        navigationFindingID = finding.id
    }

    func didHandleFindingNavigation() {
        navigationFindingID = nil
    }

    func selectFilter(_ filter: FindingsListFilter) {
        guard !isUploadSelectionActive, !isUploading else { return }
        selectedFilter = filter
    }

    func beginUploadSelection() {
        guard pendingFindingsCount > 0, !isUploading else { return }

        filterBeforeUploadSelection = selectedFilter
        selectedFilter = .pending
        selectedUploadFindingIDs = []
        isUploadSelectionActive = true
    }

    func toggleUploadSelection(for finding: FindingSummary) {
        guard
            isUploadSelectionActive,
            finding.uploadStatus == .pending
        else {
            return
        }

        if selectedUploadFindingIDs.contains(finding.id) {
            selectedUploadFindingIDs.remove(finding.id)
        } else {
            selectedUploadFindingIDs.insert(finding.id)
        }
    }

    func toggleAllPendingFindings() {
        guard isUploadSelectionActive else { return }

        if areAllPendingFindingsSelected {
            selectedUploadFindingIDs = []
        } else {
            selectedUploadFindingIDs = Set(
                findings
                    .filter { $0.uploadStatus == .pending }
                    .map(\.id)
            )
        }
    }

    func cancelUploadSelection() {
        selectedUploadFindingIDs = []
        isUploadSelectionActive = false

        if let filterBeforeUploadSelection {
            selectedFilter = filterBeforeUploadSelection
        }
        filterBeforeUploadSelection = nil
    }

    func uploadSelectedFindings() {
        let selectedIDs = findings
            .filter { finding in
                finding.uploadStatus == .pending
                    && selectedUploadFindingIDs.contains(finding.id)
            }
            .map(\.id)

        guard !selectedIDs.isEmpty else { return }
        cancelUploadSelection()
        startUpload(ids: selectedIDs)
    }

    func deleteFinding(id: UUID) {
        guard !isUploading else { return }
        do {
            try useCases.deleteFinding.execute(id: id)
            actionError = nil
            loadFindings()
        } catch {
            actionError = .deleteFinding
        }
    }

    func deleteAllFindings() {
        guard !isUploading else { return }
        do {
            try useCases.deleteAllFindings.execute()
            actionError = nil
            loadFindings()
        } catch {
            actionError = .deleteAllFindings
        }
    }

    func dismissActionError() {
        actionError = nil

        if case .failure = uploadState {
            uploadState = .idle
        }
    }

    private func startUpload(ids: [UUID]) {
        guard !ids.isEmpty, !isUploading else { return }

        let initialProgress = FindingUploadProgress(
            completedCount: 0,
            totalCount: ids.count
        )
        uploadState = .uploading(initialProgress)
        actionError = nil
        uploadTask?.cancel()
        uploadTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await uploadFindings.execute(ids: ids) { [weak self] progress in
                    await MainActor.run {
                        self?.uploadState = .uploading(progress)
                    }
                }
                uploadState = .idle
                loadFindings()
            } catch is CancellationError {
                uploadState = .idle
            } catch {
                let progress = uploadState.progress ?? initialProgress
                uploadState = .failure(progress)
                actionError = .uploadFindings(
                    completedCount: progress.completedCount,
                    totalCount: progress.totalCount
                )
                loadFindings()
            }
        }
    }

    private func synchronizeUploadSelection() {
        let pendingIDs = Set(
            findings
                .filter { $0.uploadStatus == .pending }
                .map(\.id)
        )
        selectedUploadFindingIDs.formIntersection(pendingIDs)

        if isUploadSelectionActive && pendingIDs.isEmpty {
            cancelUploadSelection()
        }
    }
}
