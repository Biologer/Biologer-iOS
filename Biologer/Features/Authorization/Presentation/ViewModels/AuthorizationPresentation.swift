import Foundation

enum AuthorizationExternalPage {
    case forgotPassword
    case privacyPolicy

    var path: String {
        switch self {
        case .forgotPassword: "/password/reset"
        case .privacyPolicy: "/pages/privacy-policy"
        }
    }
}

struct AuthorizationResultPresentation: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
