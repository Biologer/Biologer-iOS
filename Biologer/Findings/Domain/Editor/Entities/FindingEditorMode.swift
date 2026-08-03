import Foundation

enum FindingEditorMode: Hashable {
    case create
    case edit(UUID)

    var findingID: UUID? {
        guard case .edit(let id) = self else { return nil }
        return id
    }
}
