import Foundation

enum APIRequestBody {
    case empty
    case json(Encodable)
    case data(Data)

    func data(using encoder: JSONEncoder = JSONEncoder()) throws -> Data? {
        switch self {
        case .empty:
            return nil

        case .data(let data):
            return data

        case .json(let encodable):
            return try encoder.encode(AnyEncodable(encodable))
        }
    }
}

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init(_ encodable: Encodable) {
        self.encodeClosure = encodable.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
