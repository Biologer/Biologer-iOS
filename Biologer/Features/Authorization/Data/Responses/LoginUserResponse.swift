import Foundation

public struct LoginUserResponse: Codable {
    let access_token: String
    let refresh_token: String
}
