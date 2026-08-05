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
    private let shouldPresentHelp: Bool
    private let useCases: AuthorizationUseCases

    @State private var event: PreviewAuthorizationEvent?

    init(shouldPresentHelp: Bool) {
        self.shouldPresentHelp = shouldPresentHelp
        useCases = PreviewAuthorizationComposition.makeUseCases()
    }

    var body: some View {
        AuthorizationFlow(
            authorizationUseCases: useCases,
            shouldPresentHelp: shouldPresentHelp,
            onHelpCompleted: { _ in
                showEvent(
                    title: "Help completed",
                    message: "The preview switched to the login screen."
                )
            },
            onAuthorizationSuccess: { _ in
                showEvent(
                    title: "Authorization succeeded",
                    message: "The mocked authorization request completed successfully."
                )
            },
        )
        .alert(item: $event) { event in
            Alert(
                title: Text(event.title),
                message: Text(event.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func showEvent(title: String, message: String) {
        event = PreviewAuthorizationEvent(title: title, message: message)
    }
}

private struct PreviewAuthorizationEvent: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

private enum PreviewAuthorizationComposition {
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
            )
        )
    }
}

private final class PreviewLoginUserRepository: LoginUserRepository {
    func login(
        email: String,
        password: String
    ) async throws(AuthorizationFailure) {
        // Successful by default so the complete callback can be tested in Canvas.
    }
}

private final class PreviewRegisterUserRepository: RegisterUserRepository {
    func createUser(
        request: RegistrationRequest
    ) async throws(AuthorizationFailure) {
        // Successful by default so all registration steps remain interactive.
    }
}

private final class PreviewRegistrationLicensePreferenceRepository:
    RegistrationLicensePreferenceRepository {

    private var preferences: [RegistrationLicensePreference] = []

    func save(_ preference: RegistrationLicensePreference) {
        preferences.removeAll(where: { $0.kind == preference.kind })
        preferences.append(preference)
    }
}

private final class PreviewAuthorizationEnvironmentRepository:
    AuthorizationEnvironmentRepository {

    private var selectedEnvironment: AppEnvironment?

    func save(_ environment: AppEnvironment) {
        selectedEnvironment = environment
    }
}
