import SwiftUI

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        let environment = EnvironmentViewModelFactory()
            .createEnvironment(type: .croatia)

        LoginScreen(
            environmentViewModel: environment,
            viewModel: LoginScreenViewModel(
                environmentViewModel: environment,
                useCase: PreviewAuthorizationComposition.makeUseCases().login
            ),
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
            loader: PreviewAuthorizationComposition
                .makeRegistrationFlowViewModel()
                .personalInfoViewModel,
            onNext: {}
        )
    }
}

struct RegistrationCredentialsScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationCredentialsScreen(
            viewModel: PreviewAuthorizationComposition
                .makeRegistrationFlowViewModel()
                .credentialsViewModel,
            onNext: {}
        )
    }
}

struct RegistrationLicenseConsentScreen_Previews: PreviewProvider {
    static var previews: some View {
        let flowViewModel = PreviewAuthorizationComposition
            .makeRegistrationFlowViewModel()

        RegistrationLicenseConsentScreen(
            viewModel: flowViewModel.licenseConsentViewModel,
            dataLicense: flowViewModel.selectedDataLicense,
            imageLicense: flowViewModel.selectedImageLicense,
            onPrivacyPolicy: {},
            onDataLicense: { _ in },
            onImageLicense: { _ in },
            onRegistrationSuccess: {}
        )
    }
}

struct LicenseSelectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewLicenseSelection(
                items: CheckMarkItemMapper.getDataLicense()
            )
            .previewDisplayName("Data License")

            PreviewLicenseSelection(
                items: CheckMarkItemMapper.getImageLicense()
            )
            .previewDisplayName("Image License")
        }
    }
}

private struct PreviewLicenseSelection: View {
    @State private var selectedItem: CheckMarkItem
    private let items: [CheckMarkItem]

    init(items: [CheckMarkItem]) {
        precondition(!items.isEmpty)
        self.items = items
        _selectedItem = State(initialValue: items[0])
    }

    var body: some View {
        NavigationStack {
            LicenseSelectionScreen(
                selectedItem: $selectedItem,
                items: items
            )
        }
    }
}
