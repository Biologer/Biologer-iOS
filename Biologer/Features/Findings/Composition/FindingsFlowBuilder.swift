import Foundation

@MainActor
final class FindingsFlowBuilder {
    private let useCases: FindingsUseCases

    init(useCases: FindingsUseCases) {
        self.useCases = useCases
    }

    func makeFlow(
        controller: FindingsFlowController,
        onAddFinding: @escaping Observer<Void>,
        onEditFinding: @escaping Observer<UUID>
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
