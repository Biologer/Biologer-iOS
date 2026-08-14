import SwiftUI

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen(
            viewModel: PreviewUnauthenticatedComposition.makeLoginFlowViewModel(),
            onSelectEnvironment: {},
            onLoginSuccess: {},
            onLoginError: { _ in },
            onRegister: {},
            onForgotPassword: {}
        )
    }
}

struct RegistrationPersonalInfoScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationPersonalInfoScreen(
            viewModel: PreviewUnauthenticatedComposition.makeRegistrationFlowViewModel(),
            onNext: {}
        )
    }
}

struct RegistrationCredentialsScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationCredentialsScreen(
            viewModel: PreviewUnauthenticatedComposition.makeRegistrationFlowViewModel(),
            onNext: {}
        )
    }
}

struct RegistrationLicenseConsentScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationLicenseConsentScreen(
            viewModel: PreviewUnauthenticatedComposition.makeRegistrationFlowViewModel(),
            onPrivacyPolicy: {},
            onDataLicense: {},
            onImageLicense: {},
            onRegistrationSuccess: {}
        )
    }
}

struct LicenseSelectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewLicenseSelection(kind: .data)
                .previewDisplayName("Data License")
            PreviewLicenseSelection(kind: .image)
                .previewDisplayName("Image License")
        }
    }
}

private struct PreviewLicenseSelection: View {
    @State private var selectedID: Int
    private let items: [LicenseOption]

    init(kind: LicenseKind) {
        let items = DefaultLicenseOptionsProvider().options(for: kind)
        self.items = items
        _selectedID = State(initialValue: items[0].id)
    }

    var body: some View {
        NavigationStack {
            LicenseSelectionScreen(selectedID: $selectedID, items: items)
        }
    }
}
