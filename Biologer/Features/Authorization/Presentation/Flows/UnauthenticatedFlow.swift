import SwiftUI

enum UnauthenticatedFlowState: Equatable {
    /// The one-time introductory help is visible.
    case help

    /// The user can select an environment and sign in.
    case login

    /// A new registration is in progress for the selected environment.
    case registration(EnvironmentID)
}

/// Routes between the independent help, login, and registration flows.
struct UnauthenticatedFlow: View {
    @State private var state: UnauthenticatedFlowState

    private let loginDependencies: LoginFlowDependencies
    private let registrationDependencies: RegistrationFlowDependencies
    private let onHelpCompleted: () -> Void
    private let onAuthorizationSuccess: () async -> Void

    init(
        loginDependencies: LoginFlowDependencies,
        registrationDependencies: RegistrationFlowDependencies,
        shouldPresentHelp: Bool,
        onHelpCompleted: @escaping () -> Void,
        onAuthorizationSuccess: @escaping () async -> Void
    ) {
        self.loginDependencies = loginDependencies
        self.registrationDependencies = registrationDependencies
        _state = State(initialValue: shouldPresentHelp ? .help : .login)
        self.onHelpCompleted = onHelpCompleted
        self.onAuthorizationSuccess = onAuthorizationSuccess
    }

    var body: some View {
        switch state {
        case .help:
            BiologerHelpScreen {
                guard state == .help else { return }
                state = .login
                onHelpCompleted()
            }

        case .login:
            LoginFlow(
                dependencies: loginDependencies,
                onRegister: { state = .registration($0) },
                onLoginSuccess: onAuthorizationSuccess
            )

        case .registration(let environmentID):
            RegistrationFlow(
                environmentID: environmentID,
                dependencies: registrationDependencies,
                onCancel: { state = .login },
                onRegistrationSuccess: onAuthorizationSuccess
            )
        }
    }
}
