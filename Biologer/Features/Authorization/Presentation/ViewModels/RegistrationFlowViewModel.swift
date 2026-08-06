import Foundation

@MainActor
final class RegistrationFlowViewModel: ObservableObject {
    @Published var selectedDataLicense: CheckMarkItem {
        didSet {
            licenseConsentViewModel.updateDataLicense(selectedDataLicense)
        }
    }
    @Published var selectedImageLicense: CheckMarkItem {
        didSet {
            licenseConsentViewModel.updateImageLicense(selectedImageLicense)
        }
    }

    private(set) var environmentImage: String
    let dataLicenses: [CheckMarkItem]
    let imageLicenses: [CheckMarkItem]

    let personalInfoViewModel: RegistrationPersonalInfoViewModel
    let credentialsViewModel: RegistrationCredentialsViewModel
    let licenseConsentViewModel: RegistrationLicenseConsentViewModel

    init(
        environmentImage: String,
        dataLicenses: [CheckMarkItem],
        imageLicenses: [CheckMarkItem],
        personalInfoViewModel: RegistrationPersonalInfoViewModel,
        credentialsViewModel: RegistrationCredentialsViewModel,
        licenseConsentViewModel: RegistrationLicenseConsentViewModel
    ) {
        precondition(!dataLicenses.isEmpty, "At least one data license is required")
        precondition(!imageLicenses.isEmpty, "At least one image license is required")

        self.environmentImage = environmentImage
        self.dataLicenses = dataLicenses
        self.imageLicenses = imageLicenses
        self.personalInfoViewModel = personalInfoViewModel
        self.credentialsViewModel = credentialsViewModel
        self.licenseConsentViewModel = licenseConsentViewModel
        selectedDataLicense = dataLicenses[0]
        selectedImageLicense = imageLicenses[0]
    }

    func updateEnvironmentImage(_ image: String) {
        environmentImage = image
        licenseConsentViewModel.topImage = image
    }
}
