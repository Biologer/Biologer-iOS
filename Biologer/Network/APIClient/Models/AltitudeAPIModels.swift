import Foundation

struct GetAltitudeByLocationResponse: Decodable {
    let elevation: Int
}

struct GetAltitudeByLocationBody: Encodable {
    let latitude: Double
    let longitude: Double
}
