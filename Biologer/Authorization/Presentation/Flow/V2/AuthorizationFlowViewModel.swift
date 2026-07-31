import Foundation

@MainActor
final class AuthorizationFlowViewModel: ObservableObject {
    @Published private(set) var isHelpPresented: Bool

    private let onHelpCompleted: Observer<Void>

    init(
        shouldPresentHelp: Bool,
        onHelpCompleted: @escaping Observer<Void>
    ) {
        isHelpPresented = shouldPresentHelp
        self.onHelpCompleted = onHelpCompleted
    }

    func completeHelp() {
        guard isHelpPresented else { return }

        onHelpCompleted(())
        isHelpPresented = false
    }
}
