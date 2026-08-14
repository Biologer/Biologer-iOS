protocol CurrentEnvironmentProviding {
    func currentEnvironment() -> AppEnvironment?
}

/// Resolves the persisted selection into credentials and endpoints from the current app build.
final class DefaultCurrentEnvironmentProvider: CurrentEnvironmentProviding {
    private let selectionStorage: EnvironmentSelectionStorage
    private let configurationProvider: EnvironmentConfigurationProviding

    init(
        selectionStorage: EnvironmentSelectionStorage,
        configurationProvider: EnvironmentConfigurationProviding
    ) {
        self.selectionStorage = selectionStorage
        self.configurationProvider = configurationProvider
    }

    func currentEnvironment() -> AppEnvironment? {
        guard let id = selectionStorage.selectedEnvironmentID() else {
            return nil
        }
        return configurationProvider.configuration(for: id)
    }
}
