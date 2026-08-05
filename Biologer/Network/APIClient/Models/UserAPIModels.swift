import Foundation

public struct UserDataResponse: Codable {
    let data: UserResponse

    public struct UserResponse: Codable {
        let id: Int
        let first_name: String
        let last_name: String
        let email: String
        let full_name: String
        let is_verified: Bool
        let settings: Settings

        public struct Settings: Codable {
            let data_license: Int
            let image_license: Int
            let language: String
        }
    }
}
