import Foundation

enum AuthorizationExternalPage {
    case forgotPassword
    case privacyPolicy

    fileprivate var path: String {
        switch self {
        case .forgotPassword:
            "/password/reset"
        case .privacyPolicy:
            "/pages/privacy-policy"
        }
    }
}

struct AuthorizationResultPresentation: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
final class AuthorizationFlowViewModel: ObservableObject {
    @Published private(set) var isHelpPresented: Bool
    @Published var selectedEnvironment: EnvironmentViewModel
    @Published private(set) var environments: [EnvironmentViewModel]
    @Published var result: AuthorizationResultPresentation?

    let loginViewModel: LoginScreenViewModel
    let registrationFlowViewModel: RegistrationFlowViewModel

    private let selectEnvironment: SelectAuthorizationEnvironmentUseCase
    private var didPrepareLogin = false

    init(
        selectEnvironment: SelectAuthorizationEnvironmentUseCase,
        shouldPresentHelp: Bool,
        defaultEnvironment: EnvironmentViewModel,
        environments: [EnvironmentViewModel],
        loginViewModel: LoginScreenViewModel,
        registrationFlowViewModel: RegistrationFlowViewModel
    ) {
        self.selectEnvironment = selectEnvironment
        self.loginViewModel = loginViewModel
        self.registrationFlowViewModel = registrationFlowViewModel
        isHelpPresented = shouldPresentHelp
        var selectedEnvironment = defaultEnvironment
        selectedEnvironment.changeIsSelected(value: true)
        self.selectedEnvironment = selectedEnvironment
        self.environments = environments.selecting(defaultEnvironment)
    }

    @discardableResult
    func completeHelp() -> Bool {
        guard isHelpPresented else { return false }

        isHelpPresented = false
        return true
    }

    func prepareLogin() {
        guard !didPrepareLogin else { return }
        didPrepareLogin = true
        selectEnvironment.select(selectedEnvironment.env)
    }

    func selectEnvironment(_ environment: EnvironmentViewModel) {
        guard selectedEnvironment != environment else { return }

        var selectedEnvironment = environment
        selectedEnvironment.changeIsSelected(value: true)
        self.selectedEnvironment = selectedEnvironment
        environments = environments.selecting(selectedEnvironment)
        loginViewModel.updateEnvironment(selectedEnvironment)
        registrationFlowViewModel.updateEnvironmentImage(selectedEnvironment.image)
        selectEnvironment.select(environment.env)
    }

    func externalURL(for page: AuthorizationExternalPage) -> URL? {
        guard let url = URL(
            string: "https://\(selectedEnvironment.env.host)\(selectedEnvironment.env.path)\(page.path)"
        ) else {
            result = AuthorizationResultPresentation(
                title: "API.lb.error".localized,
                message: "API.lb.parsingError".localized
            )
            return nil
        }

        return url
    }

    func dismissResult() {
        result = nil
    }

    func present(error: AuthorizationFailure) {
        result = AuthorizationResultPresentation(
            title: error.summary.isEmpty
                ? "API.lb.error".localized
                : error.summary,
            message: error.message
        )
    }
}

private extension Array where Element == EnvironmentViewModel {
    func selecting(_ selectedEnvironment: EnvironmentViewModel) -> [EnvironmentViewModel] {
        map { environment in
            var environment = environment
            environment.changeIsSelected(value: environment.id == selectedEnvironment.id)
            return environment
        }
    }
}
