import Foundation

public struct RegisterUserResponse: Codable {
    let access_token: String
    let refresh_token: String
}
