final class UnauthenticatedFlowBuilder {
    private let useCases: AuthorizationUseCases
    private let environmentOptionsProvider: EnvironmentOptionsProviding
    private let licenseOptionsProvider: LicenseOptionsProviding
    private let urlProvider: AuthorizationURLProviding

    init(
        useCases: AuthorizationUseCases,
        environmentOptionsProvider: EnvironmentOptionsProviding,
        licenseOptionsProvider: LicenseOptionsProviding,
        urlProvider: AuthorizationURLProviding
    ) {
        self.useCases = useCases
        self.environmentOptionsProvider = environmentOptionsProvider
        self.licenseOptionsProvider = licenseOptionsProvider
        self.urlProvider = urlProvider
    }

    @MainActor
    func makeFlow(
        onAuthorizationSuccess: @escaping () async -> Void
    ) -> UnauthenticatedFlow {
        UnauthenticatedFlow(
            loginDependencies: LoginFlowDependencies(
                loginUseCase: useCases.login,
                environmentSelectionUseCase: useCases.environmentSelection,
                environmentOptionsProvider: environmentOptionsProvider,
                urlProvider: urlProvider
            ),
            registrationDependencies: RegistrationFlowDependencies(
                registrationUseCase: useCases.registration,
                environmentOptionsProvider: environmentOptionsProvider,
                licenseOptionsProvider: licenseOptionsProvider,
                urlProvider: urlProvider
            ),
            shouldPresentHelp: useCases.tutorial.shouldPresent,
            onHelpCompleted: { [tutorial = useCases.tutorial] in
                tutorial.markPresented()
            },
            onAuthorizationSuccess: onAuthorizationSuccess
        )
    }
}
