import Foundation

struct RegistrationRequest: Equatable {
    let firstName: String
    let lastName: String
    let institution: String?
    let email: String
    let password: String
    let dataLicenseId: Int
    let imageLicenseId: Int
}
