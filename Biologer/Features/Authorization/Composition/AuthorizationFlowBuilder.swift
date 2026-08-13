import Foundation

@MainActor
final class AuthorizationFlowBuilder {
    private let useCases: AuthorizationUseCases
    private let environmentFactory: EnvironmentViewModelFactory

    init(
        useCases: AuthorizationUseCases,
        environmentFactory: EnvironmentViewModelFactory = EnvironmentViewModelFactory()
    ) {
        self.useCases = useCases
        self.environmentFactory = environmentFactory
    }

    func makeFlow(
        onAuthorizationSuccess: @escaping () async -> Void
    ) -> AuthorizationFlow {
        let defaultEnvironment = environmentFactory.createEnvironment(type: .serbia)
        let registrationDraft = RegistrationDraft()
        let dataLicenses = CheckMarkItemMapper.getDataLicense()
        let imageLicenses = CheckMarkItemMapper.getImageLicense()

        let registrationFlowViewModel = RegistrationFlowViewModel(
            environmentImage: defaultEnvironment.image,
            dataLicenses: dataLicenses,
            imageLicenses: imageLicenses,
            personalInfoViewModel: RegistrationPersonalInfoViewModel(
                user: registrationDraft,
                validator: useCases.registration
            ),
            credentialsViewModel: RegistrationCredentialsViewModel(
                user: registrationDraft,
                validator: useCases.registration
            ),
            licenseConsentViewModel: RegistrationLicenseConsentViewModel(
                user: registrationDraft,
                topImage: defaultEnvironment.image,
                registerUserUseCase: useCases.registration,
                dataLicense: dataLicenses[0],
                imageLicense: imageLicenses[0]
            )
        )

        return AuthorizationFlow(
            viewModel: AuthorizationFlowViewModel(
                selectEnvironment: useCases.selectEnvironment,
                defaultEnvironment: defaultEnvironment,
                environments: environmentFactory.createAllEnvironments(),
                loginViewModel: LoginScreenViewModel(
                    environmentViewModel: defaultEnvironment,
                    useCase: useCases.login
                ),
                registrationFlowViewModel: registrationFlowViewModel
            ),
            shouldPresentHelp: useCases.tutorial.shouldPresent,
            onHelpCompleted: { [tutorial = useCases.tutorial] in
                tutorial.markPresented()
            },
            onAuthorizationSuccess: onAuthorizationSuccess
        )
    }
}
