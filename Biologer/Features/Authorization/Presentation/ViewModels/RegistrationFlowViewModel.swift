import Foundation

enum RegistrationPopup: Identifiable {
    case error(AuthorizationFailure)
    case success

    var id: String {
        switch self {
        case .error: "error"
        case .success: "success"
        }
    }
}

@MainActor
final class RegistrationFlowViewModel: ObservableObject {
    @Published private(set) var draft: RegistrationDraft

    @Published private(set) var firstNameError: String?
    @Published private(set) var lastNameError: String?
    @Published private(set) var emailError: String?
    @Published private(set) var passwordError: String?
    @Published private(set) var repeatedPasswordError: String?
    @Published private(set) var privacyPolicyError = ""
    @Published private(set) var isLoading = false
    @Published var registrationPopup: RegistrationPopup?
    @Published var acceptsPrivacyPolicy = false

    let environmentID: EnvironmentID
    let environmentImage: String
    let dataLicenses: [LicenseOption]
    let imageLicenses: [LicenseOption]

    private let useCase: RegistrationUseCase

    init(
        environmentID: EnvironmentID,
        environmentImage: String,
        dataLicenses: [LicenseOption],
        imageLicenses: [LicenseOption],
        useCase: RegistrationUseCase
    ) {
        guard let dataLicense = dataLicenses.first,
              let imageLicense = imageLicenses.first else {
            preconditionFailure("Registration requires data and image license options")
        }

        self.environmentID = environmentID
        self.environmentImage = environmentImage
        self.dataLicenses = dataLicenses
        self.imageLicenses = imageLicenses
        self.useCase = useCase
        draft = RegistrationDraft(
            dataLicenseID: dataLicense.id,
            imageLicenseID: imageLicense.id
        )
    }

    var selectedDataLicense: LicenseOption {
        dataLicenses.first { $0.id == draft.dataLicenseID }
            ?? dataLicenses[0]
    }

    var selectedImageLicense: LicenseOption {
        imageLicenses.first { $0.id == draft.imageLicenseID }
            ?? imageLicenses[0]
    }

    func updateFirstName(_ value: String) {
        draft.firstName = value
        firstNameError = nil
    }

    func updateLastName(_ value: String) {
        draft.lastName = value
        lastNameError = nil
    }

    func updateInstitution(_ value: String) {
        draft.institution = value
    }

    func updateEmail(_ value: String) {
        draft.email = value
        emailError = nil
    }

    func updatePassword(_ value: String) {
        draft.password = value
        passwordError = nil
    }

    func updateRepeatedPassword(_ value: String) {
        draft.repeatedPassword = value
        repeatedPasswordError = nil
    }

    func selectDataLicense(id: Int) {
        guard dataLicenses.contains(where: { $0.id == id }) else { return }
        draft.dataLicenseID = id
    }

    func selectImageLicense(id: Int) {
        guard imageLicenses.contains(where: { $0.id == id }) else { return }
        draft.imageLicenseID = id
    }

    func validatePersonalInfo() -> Bool {
        do throws(RegisterUserValidationError) {
            let personalInfo = try useCase.validatePersonalInfo(
                firstName: draft.firstName,
                lastName: draft.lastName,
                institution: draft.institution
            )
            draft.firstName = personalInfo.firstName
            draft.lastName = personalInfo.lastName
            draft.institution = personalInfo.institution
            firstNameError = nil
            lastNameError = nil
            return true
        } catch {
            handlePersonalInfo(error)
            return false
        }
    }

    func validateCredentials() -> Bool {
        do throws(RegisterUserValidationError) {
            let credentials = try useCase.validateCredentials(
                email: draft.email,
                password: draft.password,
                repeatedPassword: draft.repeatedPassword
            )
            draft.email = credentials.email
            draft.password = credentials.password
            emailError = nil
            passwordError = nil
            repeatedPasswordError = nil
            return true
        } catch {
            handleCredentials(error)
            return false
        }
    }

    func register() async {
        guard acceptsPrivacyPolicy else {
            privacyPolicyError = "Register.three.lb.error".localized
            return
        }

        privacyPolicyError = ""
        isLoading = true
        do throws(AuthorizationFailure) {
            try await useCase.createUser(request: registrationRequest)
            isLoading = false
            registrationPopup = .success
        } catch let error {
            isLoading = false
            registrationPopup = .error(error)
        }
    }

    func dismissRegistrationPopup() {
        registrationPopup = nil
    }

    func confirmRegistrationSuccess() {
        registrationPopup = nil
    }

    private var registrationRequest: RegistrationRequest {
        RegistrationRequest(
            firstName: draft.firstName,
            lastName: draft.lastName,
            institution: draft.institution.isEmpty ? nil : draft.institution,
            email: draft.email,
            password: draft.password,
            dataLicenseId: draft.dataLicenseID,
            imageLicenseId: draft.imageLicenseID
        )
    }

    private func handlePersonalInfo(_ error: RegisterUserValidationError) {
        switch error {
        case .emptyUsername:
            firstNameError = "Common.tf.error.required".localized
        case .emptyLastName:
            lastNameError = "Common.tf.error.required".localized
        default:
            break
        }
    }

    private func handleCredentials(_ error: RegisterUserValidationError) {
        switch error {
        case .emptyEmail:
            emailError = "Common.tf.error.required".localized
        case .invalidEmail:
            emailError = "Common.tf.email.error.notValid".localized
        case .emptyPassword:
            passwordError = "Common.tf.error.required".localized
        case .invalidPassword:
            passwordError = "Common.tf.password.error.notValid".localized
        case .passwordsDoNotMatch:
            repeatedPasswordError = "Register.two.tf.repeatPassword.error".localized
        default:
            break
        }
    }
}
