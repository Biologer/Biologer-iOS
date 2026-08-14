import SwiftUI

struct UnauthenticatedFlowPreview: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewUnauthenticatedFlow(shouldPresentHelp: false)
                .previewDisplayName("Unauthenticated Flow")
            PreviewUnauthenticatedFlow(shouldPresentHelp: true)
                .previewDisplayName("Unauthenticated Flow - Help")
        }
    }
}

private struct PreviewUnauthenticatedFlow: View {
    let shouldPresentHelp: Bool

    var body: some View {
        PreviewUnauthenticatedComposition.makeFlow(
            shouldPresentHelp: shouldPresentHelp
        )
    }
}

@MainActor
enum PreviewUnauthenticatedComposition {
    static let environmentConfigurations: EnvironmentConfigurationProviding =
        DefaultEnvironmentConfigurationProvider()
    static let environmentOptions: EnvironmentOptionsProviding =
        DefaultEnvironmentOptionsProvider(
            configurationProvider: environmentConfigurations
        )
    static let licenseOptions: LicenseOptionsProviding =
        DefaultLicenseOptionsProvider()
    static let urlProvider: AuthorizationURLProviding =
        DefaultAuthorizationURLProvider(
            configurationProvider: environmentConfigurations
        )

    static func makeFlow(shouldPresentHelp: Bool) -> UnauthenticatedFlow {
        let tutorial = PreviewAuthorizationTutorialRepository()
        tutorial.wasPresented = !shouldPresentHelp
        return UnauthenticatedFlowBuilder(
            useCases: makeUseCases(tutorial: tutorial),
            environmentOptionsProvider: environmentOptions,
            licenseOptionsProvider: licenseOptions,
            urlProvider: urlProvider
        ).makeFlow(onAuthorizationSuccess: {})
    }

    static func makeLoginFlowViewModel() -> LoginFlowViewModel {
        let useCases = makeUseCases()
        return LoginFlowViewModel(
            environmentOptionsProvider: environmentOptions,
            loginUseCase: useCases.login,
            environmentSelectionUseCase: useCases.environmentSelection,
            urlProvider: urlProvider
        )
    }

    static func makeRegistrationFlowViewModel() -> RegistrationFlowViewModel {
        let environment = environmentOptions.defaultOption
        return RegistrationFlowViewModel(
            environmentID: environment.id,
            environmentImage: environment.image,
            dataLicenses: licenseOptions.options(for: .data),
            imageLicenses: licenseOptions.options(for: .image),
            useCase: makeUseCases().registration
        )
    }

    static func makeRegistrationDependencies() -> RegistrationFlowDependencies {
        RegistrationFlowDependencies(
            registrationUseCase: makeUseCases().registration,
            environmentOptionsProvider: environmentOptions,
            licenseOptionsProvider: licenseOptions,
            urlProvider: urlProvider
        )
    }

    static func makeUseCases(
        tutorial: PreviewAuthorizationTutorialRepository = .init()
    ) -> AuthorizationUseCases {
        AuthorizationUseCases(
            login: DefaultLoginUserUseCase(repository: PreviewLoginUserRepository()),
            registration: DefaultRegistrationUseCase(
                validator: DefaultRegistrationInputValidator(),
                licensePreferenceUseCase: DefaultRegistrationLicensePreferenceUseCase(
                    repository: PreviewRegistrationLicensePreferenceRepository()
                ),
                registerUseCase: DefaultRegisterUserUseCase(
                    repository: PreviewRegisterUserRepository()
                )
            ),
            environmentSelection: DefaultAuthorizationEnvironmentSelectionUseCase(
                repository: PreviewAuthorizationEnvironmentSelectionRepository()
            ),
            tutorial: DefaultAuthorizationTutorialUseCase(repository: tutorial)
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
    func login(email: String, password: String) async throws(AuthorizationFailure) {}
}

final class PreviewRegisterUserRepository: RegisterUserRepository {
    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) {}
}

final class PreviewRegistrationLicensePreferenceRepository:
    RegistrationLicensePreferenceRepository {
    func save(_ preference: RegistrationLicensePreference) {}
}

final class PreviewAuthorizationEnvironmentSelectionRepository:
    AuthorizationEnvironmentSelectionRepository {
    private var environmentID: EnvironmentID?

    func selectedEnvironmentID() -> EnvironmentID? {
        environmentID
    }

    func save(
        _ id: EnvironmentID
    ) throws(AuthorizationEnvironmentSelectionError) {
        environmentID = id
    }
}
