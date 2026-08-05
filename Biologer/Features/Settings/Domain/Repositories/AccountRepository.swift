import Foundation

protocol AccountRepository {
    func loadCurrentUser() async throws(APIError) -> UserDataResponse
    func deleteCurrentUser(userID: Int, deleteObservations: Bool) async throws(APIError)
}
