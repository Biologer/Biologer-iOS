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
}

@MainActor
final class ListOfFindingsV2ViewModel: ObservableObject {
    @Published private(set) var findings: [FindingSummary] = []
    @Published private(set) var loadState: ListOfFindingsV2LoadState = .idle
    @Published private(set) var actionError: ListOfFindingsV2ActionError?

    private let useCases: FindingsUseCases
    private let onAddFinding: () -> Void
    private let onFindingSelected: (UUID) -> Void

    init(
        useCases: FindingsUseCases,
        onAddFinding: @escaping () -> Void,
        onFindingSelected: @escaping (UUID) -> Void
    ) {
        self.useCases = useCases
        self.onAddFinding = onAddFinding
        self.onFindingSelected = onFindingSelected
    }

    func loadFindings() {
        loadState = .loading

        do {
            findings = try useCases.getFindings.execute()
            loadState = findings.isEmpty ? .empty : .content
        } catch {
            findings = []
            loadState = .failure
        }
    }

    func didTapAddFinding() {
        onAddFinding()
    }

    func didSelectFinding(_ finding: FindingSummary) {
        onFindingSelected(finding.id)
    }

    func deleteFinding(id: UUID) {
        do {
            try useCases.deleteFinding.execute(id: id)
            actionError = nil
            loadFindings()
        } catch {
            actionError = .deleteFinding
        }
    }

    func deleteAllFindings() {
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
    }
}
