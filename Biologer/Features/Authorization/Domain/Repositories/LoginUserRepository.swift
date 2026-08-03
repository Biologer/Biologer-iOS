import Foundation

protocol LoginUserRepository {
    func login(email: String, password: String) async throws(AuthorizationFailure)
}
