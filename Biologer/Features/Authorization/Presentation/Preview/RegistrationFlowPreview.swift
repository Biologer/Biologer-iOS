import SwiftUI

struct RegistrationFlowPreview: PreviewProvider {
    static var previews: some View {
        RegistrationFlow(
            environmentID: .serbia,
            dependencies: PreviewUnauthenticatedComposition.makeRegistrationDependencies(),
            onCancel: {},
            onRegistrationSuccess: {}
        )
        .previewDisplayName("Registration Flow")
    }
}
