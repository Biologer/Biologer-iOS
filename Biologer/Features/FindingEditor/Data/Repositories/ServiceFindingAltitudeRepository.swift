final class ServiceFindingAltitudeRepository: FindingAltitudeRepository {
    private let service: GetAltitudeService

    init(service: GetAltitudeService) {
        self.service = service
    }

    func altitude(latitude: Double, longitude: Double) async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            service.getAltitude(latitude: latitude, longitude: longitude) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: Double(response.elevation))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
