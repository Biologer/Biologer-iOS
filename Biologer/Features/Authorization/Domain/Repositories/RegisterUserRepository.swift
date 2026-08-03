import Foundation

protocol RegisterUserRepository {
    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure)
}
