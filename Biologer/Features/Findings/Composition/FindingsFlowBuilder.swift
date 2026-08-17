import Foundation

final class FindingsFlowBuilder {
    private let useCases: FindingsUseCases

    init(useCases: FindingsUseCases) {
        self.useCases = useCases
    }

    @MainActor
    func makeFlow(
        controller: FindingsFlowController,
        onAddFinding: @escaping () -> Void,
        onEditFinding: @escaping (UUID) -> Void
    ) -> FindingsFlow {
        let listViewModel = ListOfFindingsViewModel(useCases: useCases.list)

        return FindingsFlow(
            viewModel: FindingsFlowViewModel(
                listViewModel: listViewModel
            ),
            controller: controller,
            detailsUseCases: useCases.details,
            onAddFinding: onAddFinding,
            onEditFinding: onEditFinding
        )
    }
}
