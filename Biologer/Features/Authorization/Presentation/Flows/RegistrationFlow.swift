import SwiftUI

struct RegistrationFlow: View {
    enum Screen: Hashable {
        case credentials
        case consent
        case imageLicense
        case dataLicense
    }

    @State private var path = NavigationPath()
    @StateObject private var viewModel: RegistrationFlowViewModel

    @SwiftUI.Environment(\.openURL) private var openURL

    private let urlProvider: AuthorizationURLProviding
    private let onCancel: () -> Void
    private let onRegistrationSuccess: () async -> Void

    init(
        environmentID: EnvironmentID,
        dependencies: RegistrationFlowDependencies,
        onCancel: @escaping () -> Void,
        onRegistrationSuccess: @escaping () async -> Void
    ) {
        let environment = dependencies.environmentOptionsProvider.option(
            for: environmentID
        )
        _viewModel = StateObject(
            wrappedValue: RegistrationFlowViewModel(
                environmentID: environmentID,
                environmentImage: environment.image,
                dataLicenses: dependencies.licenseOptionsProvider.options(for: .data),
                imageLicenses: dependencies.licenseOptionsProvider.options(for: .image),
                useCase: dependencies.registrationUseCase
            )
        )
        urlProvider = dependencies.urlProvider
        self.onCancel = onCancel
        self.onRegistrationSuccess = onRegistrationSuccess
    }

    var body: some View {
        NavigationStack(path: $path) {
            personalInfoScreen
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .credentials:
                        credentialsScreen
                    case .consent:
                        consentScreen
                    case .imageLicense:
                        imageLicenseScreen
                    case .dataLicense:
                        dataLicenseScreen
                    }
                }
        }
    }

    private var personalInfoScreen: some View {
        RegistrationPersonalInfoScreen(
            viewModel: viewModel,
            onNext: { path.append(Screen.credentials) }
        )
        .biologerNavigationBar(
            title: "Register.one.nav.title".localized,
            onBack: onCancel
        )
    }

    private var credentialsScreen: some View {
        RegistrationCredentialsScreen(
            viewModel: viewModel,
            onNext: { path.append(Screen.consent) }
        )
        .biologerNavigationBar(
            title: "Register.two.nav.title".localized,
            onBack: goBack
        )
    }

    private var consentScreen: some View {
        RegistrationLicenseConsentScreen(
            viewModel: viewModel,
            onPrivacyPolicy: openPrivacyPolicy,
            onDataLicense: { path.append(Screen.dataLicense) },
            onImageLicense: { path.append(Screen.imageLicense) },
            onRegistrationSuccess: onRegistrationSuccess
        )
        .biologerNavigationBar(
            title: "Register.three.nav.title".localized,
            onBack: goBack
        )
    }

    private var imageLicenseScreen: some View {
        LicenseSelectionScreen(
            selectedID: Binding(
                get: { viewModel.draft.imageLicenseID },
                set: viewModel.selectImageLicense
            ),
            items: viewModel.imageLicenses,
            onSelectionChanged: { _ in goBack() }
        )
        .biologerNavigationBar(
            title: "ImgLicense.nav.title".localized,
            onBack: goBack
        )
    }

    private var dataLicenseScreen: some View {
        LicenseSelectionScreen(
            selectedID: Binding(
                get: { viewModel.draft.dataLicenseID },
                set: viewModel.selectDataLicense
            ),
            items: viewModel.dataLicenses,
            onSelectionChanged: { _ in goBack() }
        )
        .biologerNavigationBar(
            title: "DataLicense.nav.title".localized,
            onBack: goBack
        )
    }

    private func goBack() {
        guard !path.isEmpty else {
            onCancel()
            return
        }
        path.removeLast()
    }

    private func openPrivacyPolicy() {
        guard let url = urlProvider.url(
            for: .privacyPolicy,
            environmentID: viewModel.environmentID
        ) else { return }
        openURL(url)
    }
}
