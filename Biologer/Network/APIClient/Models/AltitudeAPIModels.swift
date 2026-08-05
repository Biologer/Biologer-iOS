import Foundation

public struct GetAlitutdeByLocationResponse: Codable {
    let elevation: Int
}

public struct GetAltitudeByLocationBody: Codable {
    let latitude: Double
    let longitude: Double
}
