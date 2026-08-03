import Combine
import Foundation
import SwiftUI

private enum FindingsDestination: Hashable {
    case details(UUID)
}

@MainActor
private final class FindingsFlowNavigation: ObservableObject {
    @Published var path: [FindingsDestination] = []
}

@MainActor
struct FindingsFlow: View {
    private let getFindingDetails: GetFindingDetailsUseCase
    private let onEditFinding: Observer<UUID>
    private let onShowLocation: Observer<FindingDetailsLocation>
    private let onUploadFindings: Observer<Void>

    @StateObject private var navigation: FindingsFlowNavigation
    @StateObject private var listViewModel: ListOfFindingsV2ViewModel

    init(
        listUseCases: FindingsUseCases,
        getFindingDetails: GetFindingDetailsUseCase,
        onAddFinding: @escaping Observer<Void>,
        onEditFinding: @escaping Observer<UUID>,
        onShowLocation: @escaping Observer<FindingDetailsLocation>,
        onUploadFindings: @escaping Observer<Void>
    ) {
        let navigation = FindingsFlowNavigation()

        self.getFindingDetails = getFindingDetails
        self.onEditFinding = onEditFinding
        self.onShowLocation = onShowLocation
        self.onUploadFindings = onUploadFindings
        _navigation = StateObject(wrappedValue: navigation)
        _listViewModel = StateObject(
            wrappedValue: ListOfFindingsV2ViewModel(
                useCases: listUseCases,
                onAddFinding: { onAddFinding(()) },
                onFindingSelected: { id in
                    navigation.path.append(FindingsDestination.details(id))
                }
            )
        )
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            ListOfFindingsScreenV2(
                viewModel: listViewModel,
                onUploadFindings: onUploadFindings
            )
            .navigationDestination(for: FindingsDestination.self) { destination in
                destinationView(destination)
            }
        }
    }

    private func destinationView(_ destination: FindingsDestination) -> some View {
        switch destination {
        case .details(let id):
            FindingDetailsScreenV2(
                viewModel: FindingDetailsV2ViewModel(
                    findingID: id,
                    getFindingDetails: getFindingDetails,
                    onEditFinding: onEditFinding,
                    onShowLocation: onShowLocation
                )
            )
        }
    }
}
