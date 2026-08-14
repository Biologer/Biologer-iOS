/// One selectable server environment shown by the authorization UI.
struct EnvironmentOption: Identifiable, Equatable, Sendable {
    /// Stable identity resolved to runtime configuration outside the UI layer.
    let id: EnvironmentID

    /// Localized country or environment name.
    let title: String

    /// Asset name of the flag or environment icon.
    let image: String
}
