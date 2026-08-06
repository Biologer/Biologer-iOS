enum SettingsDestination: Hashable {
    case projectName
    case license(SettingsLicenseKind)
    case automaticDownload
    case taxonSync
    case help
    case about
    case account
}
