import Foundation

enum LoginSubmissionResult: Equatable {
    case success
    case validationFailure
    case authorizationFailure(AuthorizationFailure)
}

@MainActor
final class LoginFlowViewModel: ObservableObject {
    @Published private(set) var selectedEnvironment: EnvironmentOption
    @Published private(set) var email = ""
    @Published private(set) var password = ""
    @Published private(set) var emailError: String?
    @Published private(set) var passwordError: String?
    @Published private(set) var isLoading = false
    @Published var result: AuthorizationResultPresentation?

    let environments: [EnvironmentOption]

    private let loginUseCase: LoginUserUseCase
    private let environmentSelectionUseCase: AuthorizationEnvironmentSelectionUseCase
    private let urlProvider: AuthorizationURLProviding

    init(
        environmentOptionsProvider: EnvironmentOptionsProviding,
        loginUseCase: LoginUserUseCase,
        environmentSelectionUseCase: AuthorizationEnvironmentSelectionUseCase,
        urlProvider: AuthorizationURLProviding
    ) {
        self.loginUseCase = loginUseCase
        self.environmentSelectionUseCase = environmentSelectionUseCase
        self.urlProvider = urlProvider
        environments = environmentOptionsProvider.options

        if let storedID = environmentSelectionUseCase.selectedEnvironmentID() {
            selectedEnvironment = environmentOptionsProvider.option(for: storedID)
        } else {
            let defaultEnvironment = environmentOptionsProvider.defaultOption
            selectedEnvironment = defaultEnvironment
            do {
                try environmentSelectionUseCase.select(defaultEnvironment.id)
            } catch {
                result = Self.environmentSelectionFailurePresentation
            }
        }
    }

    @discardableResult
    func selectEnvironment(_ environment: EnvironmentOption) -> Bool {
        if selectedEnvironment.id == environment.id,
           environmentSelectionUseCase.selectedEnvironmentID() == environment.id {
            return true
        }

        do {
            try environmentSelectionUseCase.select(environment.id)
            selectedEnvironment = environment
            return true
        } catch {
            result = Self.environmentSelectionFailurePresentation
            return false
        }
    }

    func updateEmail(_ email: String) {
        self.email = email
        emailError = nil
    }

    func updatePassword(_ password: String) {
        self.password = password
        passwordError = nil
    }

    func login() async -> LoginSubmissionResult {
        isLoading = true
        do throws(LoginError) {
            try await loginUseCase.login(
                email: email,
                username: email,
                password: password
            )
            emailError = nil
            passwordError = nil
            isLoading = false
            return .success
        } catch let error {
            isLoading = false
            switch error {
            case .invalidUsername:
                emailError = "Common.tf.error.required".localized
                return .validationFailure
            case .invalidEmail:
                emailError = "Common.tf.email.error.notValid".localized
                return .validationFailure
            case .invalidPassword:
                passwordError = "Common.tf.error.required".localized
                return .validationFailure
            case .authorizationFailed(let error):
                return .authorizationFailure(error)
            }
        }
    }

    func externalURL(for page: AuthorizationExternalPage) -> URL? {
        guard let url = urlProvider.url(
            for: page,
            environmentID: selectedEnvironment.id
        ) else {
            result = AuthorizationResultPresentation(
                title: "API.lb.error".localized,
                message: "API.lb.parsingError".localized
            )
            return nil
        }
        return url
    }

    func present(error: AuthorizationFailure) {
        result = AuthorizationResultPresentation(
            title: error.summary.isEmpty ? "API.lb.error".localized : error.summary,
            message: error.message
        )
    }

    func dismissResult() {
        result = nil
    }

    private static var environmentSelectionFailurePresentation:
        AuthorizationResultPresentation {
        AuthorizationResultPresentation(
            title: "API.lb.error".localized,
            message: "API.lb.envError".localized
        )
    }
}
