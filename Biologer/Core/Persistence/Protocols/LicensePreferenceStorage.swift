protocol LicensePreferenceStorage {
    func selectedLicenseID(for kind: LicenseKind) -> Int?
    func saveSelectedLicenseID(_ id: Int, for kind: LicenseKind)
}
