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
    case deleteFindings
    case deleteAllFindings
    case uploadFindings(completedCount: Int, totalCount: Int)
}

enum FindingsSelectionMode: Equatable {
    case upload
    case deletion
}

@MainActor
final class ListOfFindingsV2ViewModel: ObservableObject {
    @Published private(set) var findings: [FindingSummary] = []
    @Published private(set) var loadState: ListOfFindingsV2LoadState = .idle
    @Published private(set) var actionError: ListOfFindingsV2ActionError?
    @Published private(set) var selectedFilter: FindingsListFilter = .all
    @Published private(set) var selectionMode: FindingsSelectionMode?
    @Published private(set) var selectedFindingIDs: Set<UUID> = []
    @Published private(set) var uploadState: FindingUploadViewState = .idle
    @Published private(set) var navigationFindingID: UUID?

    private let useCases: FindingsUseCases
    private let uploadFindings: UploadFindingsUseCase
    private let onAddFinding: () -> Void
    private var filterBeforeSelection: FindingsListFilter?
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

    var isSelectionActive: Bool {
        selectionMode != nil
    }

    var isUploadSelectionActive: Bool {
        selectionMode == .upload
    }

    var isDeletionSelectionActive: Bool {
        selectionMode == .deletion
    }

    var visibleFindings: [FindingSummary] {
        findings.filter(selectedFilter.includes)
    }

    var pendingFindingsCount: Int {
        findings.filter { $0.uploadStatus == .pending }.count
    }

    var selectedUploadFindingsCount: Int {
        isUploadSelectionActive ? selectedFindingIDs.count : 0
    }

    var selectedDeletionFindingsCount: Int {
        isDeletionSelectionActive ? selectedFindingIDs.count : 0
    }

    var areAllSelectableFindingsSelected: Bool {
        let selectableIDs = Set(selectableFindings.map(\.id))
        return !selectableIDs.isEmpty && selectableIDs == selectedFindingIDs
    }

    func loadFindings() {
        guard !isUploading else { return }
        loadState = .loading

        do {
            findings = try useCases.getFindings.execute()
            synchronizeSelection()
            loadState = findings.isEmpty ? .empty : .content
        } catch {
            findings = []
            cancelSelection()
            loadState = .failure
        }
    }

    func didTapAddFinding() {
        guard !isUploading, !isSelectionActive else { return }
        onAddFinding()
    }

    func didSelectFinding(_ finding: FindingSummary) {
        guard !isUploading, !isSelectionActive else { return }
        navigationFindingID = finding.id
    }

    func didHandleFindingNavigation() {
        navigationFindingID = nil
    }

    func selectFilter(_ filter: FindingsListFilter) {
        guard !isSelectionActive, !isUploading else { return }
        selectedFilter = filter
    }

    func beginUploadSelection() {
        beginSelection(mode: .upload, filter: .pending)
    }

    func beginDeletionSelection() {
        beginSelection(mode: .deletion, filter: .all)
    }

    func toggleSelection(for finding: FindingSummary) {
        guard selectableFindings.contains(where: { $0.id == finding.id }) else {
            return
        }

        if selectedFindingIDs.contains(finding.id) {
            selectedFindingIDs.remove(finding.id)
        } else {
            selectedFindingIDs.insert(finding.id)
        }
    }

    func toggleAllSelectableFindings() {
        guard isSelectionActive else { return }

        if areAllSelectableFindingsSelected {
            selectedFindingIDs = []
        } else {
            selectedFindingIDs = Set(selectableFindings.map(\.id))
        }
    }

    func cancelSelection() {
        selectedFindingIDs = []
        selectionMode = nil

        if let filterBeforeSelection {
            selectedFilter = filterBeforeSelection
        }
        filterBeforeSelection = nil
    }

    func uploadSelectedFindings() {
        let selectedIDs = findings
            .filter { finding in
                finding.uploadStatus == .pending
                    && selectedFindingIDs.contains(finding.id)
            }
            .map(\.id)

        guard isUploadSelectionActive, !selectedIDs.isEmpty else { return }
        cancelSelection()
        startUpload(ids: selectedIDs)
    }

    func deleteSelectedFindings() {
        let selectedIDs = findings
            .filter { selectedFindingIDs.contains($0.id) }
            .map(\.id)

        guard isDeletionSelectionActive, !selectedIDs.isEmpty else { return }
        cancelSelection()

        do {
            try useCases.deleteFindings.execute(ids: selectedIDs)
            actionError = nil
            loadFindings()
        } catch {
            loadFindings()
            actionError = .deleteFindings
        }
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

    private var selectableFindings: [FindingSummary] {
        switch selectionMode {
        case .upload:
            return findings.filter { $0.uploadStatus == .pending }
        case .deletion:
            return findings
        case nil:
            return []
        }
    }

    private func beginSelection(
        mode: FindingsSelectionMode,
        filter: FindingsListFilter
    ) {
        guard
            selectionMode == nil,
            !isUploading,
            !findings.isEmpty
        else {
            return
        }

        if mode == .upload && pendingFindingsCount == 0 {
            return
        }

        filterBeforeSelection = selectedFilter
        selectedFilter = filter
        selectedFindingIDs = []
        selectionMode = mode
    }

    private func synchronizeSelection() {
        let selectableIDs = Set(selectableFindings.map(\.id))
        selectedFindingIDs.formIntersection(selectableIDs)

        if isSelectionActive && selectableIDs.isEmpty {
            cancelSelection()
        }
    }
}
