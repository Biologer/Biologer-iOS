import Foundation

struct GetAltitudeEndpoint: APIEndpoint {
    typealias Response = GetAlitutdeByLocationResponse

    let host: String
    let path = APIConstants.getAltitudePath
    let method: APIHTTPMethod = .post
    let body: APIRequestBody

    init(host: String, latitude: Double, longitude: Double) {
        let latitudeAdjusted = Double(round(10 * latitude) / 10)
        let longitudeAdjusted = Double(round(10 * longitude) / 10)

        self.host = host
        self.body = .json(
            GetAltitudeByLocationBody(
                latitude: latitudeAdjusted,
                longitude: longitudeAdjusted
            )
        )
    }
}
