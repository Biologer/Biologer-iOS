import Foundation

@MainActor
final class FindingsFlowViewModel: ObservableObject {
    let listViewModel: ListOfFindingsViewModel

    init(listViewModel: ListOfFindingsViewModel) {
        self.listViewModel = listViewModel
    }
}
