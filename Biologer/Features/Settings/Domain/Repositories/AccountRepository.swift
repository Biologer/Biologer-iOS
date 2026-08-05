import Foundation

protocol AccountRepository {
    func loadCurrentUser() async throws(SettingsDataFailure) -> User
    func deleteCurrentUser(
        userID: Int,
        deleteObservations: Bool
    ) async throws(SettingsDataFailure)
}
