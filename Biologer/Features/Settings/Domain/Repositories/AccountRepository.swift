import Foundation

protocol AccountRepository {
    func loadCurrentUser() async throws(APIError) -> User
    func deleteCurrentUser(userID: Int, deleteObservations: Bool) async throws(APIError)
}
