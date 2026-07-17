import Foundation

final class RealmLogoutLocalDataDeleter: LogoutLocalDataDeleting {
    func deleteLocalData() {
        RealmManager.delete(fromEntity: DBFinding.self)
        RealmManager.delete(fromEntity: DBTaxon.self)
    }
}
