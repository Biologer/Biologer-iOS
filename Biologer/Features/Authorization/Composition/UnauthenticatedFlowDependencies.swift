struct LoginFlowDependencies {
    let loginUseCase: LoginUserUseCase
    let environmentSelectionUseCase: AuthorizationEnvironmentSelectionUseCase
    let environmentOptionsProvider: EnvironmentOptionsProviding
    let urlProvider: AuthorizationURLProviding
}

struct RegistrationFlowDependencies {
    let registrationUseCase: RegistrationUseCase
    let environmentOptionsProvider: EnvironmentOptionsProviding
    let licenseOptionsProvider: LicenseOptionsProviding
    let urlProvider: AuthorizationURLProviding
}
