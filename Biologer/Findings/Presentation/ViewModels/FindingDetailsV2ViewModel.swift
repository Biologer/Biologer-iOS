import Combine
import Foundation

enum FindingDetailsV2LoadState: Equatable {
    case idle
    case loading
    case content
    case failure
}

@MainActor
final class FindingDetailsV2ViewModel: ObservableObject {
    @Published private(set) var details: FindingDetails?
    @Published private(set) var loadState: FindingDetailsV2LoadState = .idle

    private let findingID: UUID
    private let getFindingDetails: GetFindingDetailsUseCase
    private let onEditFinding: (UUID) -> Void
    private let onShowLocation: (FindingDetailsLocation) -> Void

    init(
        findingID: UUID,
        getFindingDetails: GetFindingDetailsUseCase,
        onEditFinding: @escaping (UUID) -> Void,
        onShowLocation: @escaping (FindingDetailsLocation) -> Void
    ) {
        self.findingID = findingID
        self.getFindingDetails = getFindingDetails
        self.onEditFinding = onEditFinding
        self.onShowLocation = onShowLocation
    }

    func loadDetails() {
        loadState = .loading

        do {
            details = try getFindingDetails.execute(id: findingID)
            loadState = .content
        } catch {
            details = nil
            loadState = .failure
        }
    }

    func didTapEdit() {
        onEditFinding(findingID)
    }

    func didTapShowLocation() {
        guard let location = details?.location else { return }
        onShowLocation(location)
    }
}
