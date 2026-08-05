import Foundation
import SwiftKeychainWrapper

enum CodableStorageError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"

    var errorDescription: String? {
        rawValue
    }
}

extension KeychainWrapper {
    func setObject<Object: Encodable>(_ object: Object, forKey key: String) throws {
        do {
            set(try JSONEncoder().encode(object), forKey: key)
        } catch {
            throw CodableStorageError.unableToEncode
        }
    }

    func getObject<Object: Decodable>(forKey key: String, castTo type: Object.Type) throws -> Object {
        guard let data = data(forKey: key) else {
            throw CodableStorageError.noValue
        }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw CodableStorageError.unableToDecode
        }
    }
}

extension UserDefaults {
    func setObject<Object: Encodable>(_ object: Object, forKey key: String) throws {
        do {
            set(try JSONEncoder().encode(object), forKey: key)
        } catch {
            throw CodableStorageError.unableToEncode
        }
    }

    func getObject<Object: Decodable>(forKey key: String, castTo type: Object.Type) throws -> Object {
        guard let data = data(forKey: key) else {
            throw CodableStorageError.noValue
        }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw CodableStorageError.unableToDecode
        }
    }
}
