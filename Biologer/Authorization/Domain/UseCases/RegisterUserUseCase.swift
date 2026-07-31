import Foundation

protocol RegisterUserUseCase {
    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) -> Void
}

final class DefaultRegisterUserUseCase: RegisterUserUseCase {
    private let repository: RegisterUserRepository

    init(repository: RegisterUserRepository) {
        self.repository = repository
    }

    func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) -> Void {
        try await repository.createUser(request: request)
    }
}
