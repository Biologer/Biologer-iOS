import Foundation

struct UserDataResponse: Decodable {
    let data: UserResponse

    struct UserResponse: Decodable {
        let id: Int
        let first_name: String
        let last_name: String
        let email: String
        let full_name: String
        let is_verified: Bool
        let settings: Settings

        struct Settings: Decodable {
            let data_license: Int
            let image_license: Int
            let language: String
        }
    }
}
