import Foundation

final class SettingsAboutViewModel: ObservableObject {
    let currentDatabaseDescription = "AboutBiologer.lb.currentlyDB".localized
    let logoImageName = "biologer_logo_icon"
    let environment: String
    let descriptionOne = "AboutBiologer.lb.desc.one".localized
    let descriptionTwo = "AboutBiologer.lb.desc.two".localized
    let descriptionThree = "AboutBiologer.lb.toFingMoreDetails".localized
    let version: String

    init(environment: String, version: String) {
        self.environment = environment
        self.version = version
    }

    var environmentURL: URL? {
        guard
            let url = URL(string: environment),
            let scheme = url.scheme?.lowercased(),
            scheme == "https" || scheme == "http"
        else {
            return nil
        }
        return url
    }
}
