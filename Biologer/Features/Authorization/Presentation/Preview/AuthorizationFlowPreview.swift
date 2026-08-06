import SwiftUI

struct AuthorizationFlowPreview: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewAuthorizationFlow(shouldPresentHelp: false)
                .previewDisplayName("Authorization Flow")

            PreviewAuthorizationFlow(shouldPresentHelp: true)
                .previewDisplayName("Authorization Flow - Help")
        }
    }
}

private struct PreviewAuthorizationFlow: View {
    private let viewModel: AuthorizationFlowViewModel
    private let shouldPresentHelp: Bool

    init(shouldPresentHelp: Bool) {
        self.shouldPresentHelp = shouldPresentHelp
        viewModel = PreviewAuthorizationComposition.makeFlowViewModel()
    }

    var body: some View {
        AuthorizationFlow(
            viewModel: viewModel,
            shouldPresentHelp: shouldPresentHelp,
            onHelpCompleted: {},
            onAuthorizationSuccess: {}
        )
    }
}

@MainActor
enum PreviewAuthorizationComposition {
    static func makeFlowViewModel() -> AuthorizationFlowViewModel {
        let environmentFactory = EnvironmentViewModelFactory()
        let defaultEnvironment = environmentFactory.createEnvironment(type: .serbia)
        let useCases = makeUseCases()
        return AuthorizationFlowViewModel(
            selectEnvironment: useCases.selectEnvironment,
            defaultEnvironment: defaultEnvironment,
            environments: environmentFactory.createAllEnvironments(),
            loginViewModel: LoginScreenViewModel(
                environmentViewModel: defaultEnvironment,
                useCase: useCases.login
            ),
            registrationFlowViewModel: makeRegistrationFlowViewModel(
                useCases: useCases,
                environmentImage: defaultEnvironment.image
            )
        )
    }

    static func makeRegistrationFlowViewModel(
        useCases: AuthorizationUseCases? = nil,
        environmentImage: String? = nil
    ) -> RegistrationFlowViewModel {
        let useCases = useCases ?? makeUseCases()
        let environmentImage = environmentImage
            ?? EnvironmentViewModelFactory()
                .createEnvironment(type: .serbia)
                .image
        let draft = RegistrationDraft()
        let dataLicenses = CheckMarkItemMapper.getDataLicense()
        let imageLicenses = CheckMarkItemMapper.getImageLicense()
        return RegistrationFlowViewModel(
            environmentImage: environmentImage,
            dataLicenses: CheckMarkItemMapper.getDataLicense(),
            imageLicenses: CheckMarkItemMapper.getImageLicense(),
            personalInfoViewModel: RegistrationPersonalInfoViewModel(
                user: draft,
                validator: useCases.registration
            ),
            credentialsViewModel: RegistrationCredentialsViewModel(
                user: draft,
                validator: useCases.registration
            ),
            licenseConsentViewModel: RegistrationLicenseConsentViewModel(
                user: draft,
                topImage: environmentImage,
                registerUserUseCase: useCases.registration,
                dataLicense: dataLicenses[0],
                imageLicense: imageLicenses[0]
            )
        )
    }

    static func makeUseCases() -> AuthorizationUseCases {
        let loginRepository = PreviewLoginUserRepository()
        let registerRepository = PreviewRegisterUserRepository()
        let licenseRepository = PreviewRegistrationLicensePreferenceRepository()
        let environmentRepository = PreviewAuthorizationEnvironmentRepository()

        return AuthorizationUseCases(
            login: DefaultLoginUserUseCase(
                repository: loginRepository
            ),
            registration: DefaultRegistrationUseCase(
                validator: DefaultRegistrationInputValidator(),
                licensePreferenceUseCase: DefaultRegistrationLicensePreferenceUseCase(
                    repository: licenseRepository
                ),
                registerUseCase: DefaultRegisterUserUseCase(
                    repository: registerRepository
                )
            ),
            selectEnvironmentUseCase: DefaultSelectAuthorizationEnvironmentUseCase(
                repository: environmentRepository
            ),
            tutorial: DefaultAuthorizationTutorialUseCase(
                repository: PreviewAuthorizationTutorialRepository()
            )
        )
    }
}

final class PreviewAuthorizationTutorialRepository: AuthorizationTutorialRepository {
    var wasPresented = false

    func markPresented() {
        wasPresented = true
    }
}

final class PreviewLoginUserRepository: LoginUserRepository {
    func login(
        email: String,
        password: String
    ) async throws(AuthorizationFailure) {
        // Successful by default so the complete callback can be tested in Canvas.
    }
}

final class PreviewRegisterUserRepository: RegisterUserRepository {
    func createUser(
        request: RegistrationRequest
    ) async throws(AuthorizationFailure) {
        // Successful by default so all registration steps remain interactive.
    }
}

final class PreviewRegistrationLicensePreferenceRepository:
    RegistrationLicensePreferenceRepository {

    private var preferences: [RegistrationLicensePreference] = []

    func save(_ preference: RegistrationLicensePreference) {
        preferences.removeAll(where: { $0.kind == preference.kind })
        preferences.append(preference)
    }
}

final class PreviewAuthorizationEnvironmentRepository:
    AuthorizationEnvironmentRepository {

    private var selectedEnvironment: AppEnvironment?

    func save(_ environment: AppEnvironment) {
        selectedEnvironment = environment
    }
}
