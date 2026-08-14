enum SettingsDestination: Hashable {
    case projectName
    case license(LicenseKind)
    case automaticDownload
    case taxonSync
    case help
    case about
    case account
}
