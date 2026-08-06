import SwiftUI

struct RegistrationFlowPreview: PreviewProvider {
    static var previews: some View {
        PreviewRegistrationFlow()
            .previewDisplayName("Registration Flow")
    }
}

private struct PreviewRegistrationFlow: View {
    @State private var path = NavigationPath()

    private let viewModel = PreviewAuthorizationComposition
        .makeRegistrationFlowViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            RegistrationFlow(
                path: $path,
                viewModel: viewModel,
                onPrivacyPolicy: { _ in },
                registrationSuccess: { _ in }
            )
        }
    }
}
