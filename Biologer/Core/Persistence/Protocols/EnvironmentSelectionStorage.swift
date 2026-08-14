enum EnvironmentSelectionStorageError: Error {
    case unableToEncode
    case unableToSave
}

protocol EnvironmentSelectionStorage {
    func selectedEnvironmentID() -> EnvironmentID?
    func saveEnvironmentID(
        _ id: EnvironmentID
    ) throws(EnvironmentSelectionStorageError)
}
