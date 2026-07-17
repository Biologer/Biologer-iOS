import Foundation

protocol UserAccountUseCase {
    func loadCurrentUser() async throws(APIError) -> User
    func deleteCurrentUser(deleteObservations: Bool) async throws(APIError) -> Void
}

final class DefaultUserAccountUseCase: UserAccountUseCase {
    private let profileService: ProfileService
    private let userStorage: UserStorage

    init(
        profileService: ProfileService,
        userStorage: UserStorage
    ) {
        self.profileService = profileService
        self.userStorage = userStorage
    }

    func loadCurrentUser() async throws(APIError) -> User {
        let response = try await profileService.getMyProfile()
        let user = User(response.data)
        userStorage.save(user: user)
        return user
    }

    func deleteCurrentUser(deleteObservations: Bool) async throws(APIError) -> Void {
        guard let userID = userStorage.getUser()?.id else {
            throw APIError(description: ErrorConstant.accountDeletionFailed)
        }

        try await profileService.deleteUser(
            userID: userID,
            deleteObservations: deleteObservations
        )
    }
}

private extension ProfileService {
    func getMyProfile() async throws(APIError) -> UserDataResponse {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                getMyProfile { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError(description: error.localizedDescription)
        }
    }

    func deleteUser(
        userID: Int,
        deleteObservations: Bool
    ) async throws(APIError) -> Void {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                deleteUser(userID: userID, deleteObservations: deleteObservations) { result in
                    switch result {
                    case .success:
                        continuation.resume(returning: ())
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError(description: error.localizedDescription)
        }
    }
}

private extension User {
    convenience init(_ response: UserDataResponse.UserResponse) {
        self.init(
            id: response.id,
            firstName: response.first_name,
            lastName: response.last_name,
            email: response.email,
            fullName: response.full_name,
            isVerified: response.is_verified,
            settings: Settings(
                dataLicense: response.settings.data_license,
                imageLicense: response.settings.image_license,
                language: response.settings.language
            )
        )
    }
}
