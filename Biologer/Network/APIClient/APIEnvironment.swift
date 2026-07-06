import Foundation

struct APIEnvironment: Equatable {
    let scheme: String
    let host: String
    let pathPrefix: String

    init(scheme: String = "https", host: String, pathPrefix: String = "") {
        self.scheme = scheme
        self.host = host
        self.pathPrefix = pathPrefix
    }
}

extension APIEnvironment {
    init(environment: Environment) {
        self.init(host: environment.host)
    }

    static let serbia = APIEnvironment(host: APIConstants.serbiaHost)
    static let croatia = APIEnvironment(host: APIConstants.croatiaHost)
    static let bosniaAndHerzegovina = APIEnvironment(host: APIConstants.bosnianAndHerzegovinHost)
    static let montenegro = APIEnvironment(host: APIConstants.montenegroHost)
    static let development = APIEnvironment(host: APIConstants.devHost)
}
