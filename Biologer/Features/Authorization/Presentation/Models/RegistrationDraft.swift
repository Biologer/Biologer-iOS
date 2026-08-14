/// In-memory values entered across the registration steps.
struct RegistrationDraft: Equatable {
    /// User's given name.
    var firstName = ""

    /// User's family name.
    var lastName = ""

    /// Optional institution displayed on the user's account.
    var institution = ""

    /// Email used for the new account.
    var email = ""

    /// Password sent when registration is submitted.
    var password = ""

    /// Local-only confirmation of `password`.
    var repeatedPassword = ""

    /// Stable identifier of the selected data license.
    var dataLicenseID: Int

    /// Stable identifier of the selected image license.
    var imageLicenseID: Int
}
