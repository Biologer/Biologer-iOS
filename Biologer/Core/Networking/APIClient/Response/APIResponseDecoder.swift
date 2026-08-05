import Foundation

protocol APIResponseDecoding {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

struct EmptyAPIResponse: Decodable, Equatable {}

final class APIResponseDecoder: APIResponseDecoding {
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        if data.isEmpty, let emptyResponse = EmptyAPIResponse() as? T {
            return emptyResponse
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw APIClientError.decodingFailed(error.localizedDescription)
        }
    }
}
