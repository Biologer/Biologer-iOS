protocol EnvironmentConfigurationProviding {
    var defaultID: EnvironmentID { get }
    var allIDs: [EnvironmentID] { get }

    func configuration(for id: EnvironmentID) -> AppEnvironment
    func id(matchingHost host: String) -> EnvironmentID?
}

struct DefaultEnvironmentConfigurationProvider: EnvironmentConfigurationProviding {
    let defaultID: EnvironmentID = .serbia
    let allIDs: [EnvironmentID] = EnvironmentID.allCases

    func configuration(for id: EnvironmentID) -> AppEnvironment {
        switch id {
        case .serbia:
            AppEnvironment(
                id: id,
                host: APIConstants.serbiaHost,
                path: APIConstants.serbiaLangPath,
                clientSecret: serbiaClientSecret,
                clientId: cliendIdSer
            )
        case .croatia:
            AppEnvironment(
                id: id,
                host: APIConstants.croatiaHost,
                path: APIConstants.croatiaLangPath,
                clientSecret: croatiaClientSecret,
                clientId: cliendIdCro
            )
        case .bosniaAndHerzegovina:
            AppEnvironment(
                id: id,
                host: APIConstants.bosnianAndHerzegovinHost,
                path: APIConstants.bosnianAndHerzegovinaLangPath,
                clientSecret: bosnianAndHercegovinaClientSecret,
                clientId: cliendIdBih
            )
        case .montenegro:
            AppEnvironment(
                id: id,
                host: APIConstants.montenegroHost,
                path: APIConstants.montenegroLangPath,
                clientSecret: montenegroClientSecret,
                clientId: cliendIdMe
            )
        case .development:
            AppEnvironment(
                id: id,
                host: APIConstants.devHost,
                path: APIConstants.devLangPath,
                clientSecret: devClientSecret,
                clientId: cliendIdDev
            )
        }
    }

    func id(matchingHost host: String) -> EnvironmentID? {
        allIDs.first { configuration(for: $0).host == host }
    }
}
