import Foundation

protocol AuthorizationURLProviding {
    func url(
        for page: AuthorizationExternalPage,
        environmentID: EnvironmentID
    ) -> URL?
}

struct DefaultAuthorizationURLProvider: AuthorizationURLProviding {
    private let configurationProvider: EnvironmentConfigurationProviding

    init(configurationProvider: EnvironmentConfigurationProviding) {
        self.configurationProvider = configurationProvider
    }

    func url(
        for page: AuthorizationExternalPage,
        environmentID: EnvironmentID
    ) -> URL? {
        let environment = configurationProvider.configuration(for: environmentID)
        return URL(
            string: "https://\(environment.host)\(environment.path)\(page.path)"
        )
    }
}
