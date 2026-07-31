import Foundation

final class LicenseSettingsViewModel: ObservableObject {
    let kind: SettingsLicenseKind
    let options: [SettingsLicenseOption]
    @Published private(set) var selectedOptionID: Int

    private let useCase: SettingsLicenseUseCase

    init(
        kind: SettingsLicenseKind,
        useCase: SettingsLicenseUseCase
    ) {
        self.kind = kind
        self.useCase = useCase
        options = useCase.options(for: kind)
        selectedOptionID = useCase.selectedOption(for: kind).id
    }

    var navigationTitle: String {
        switch kind {
        case .data:
            "DataLicense.nav.title".localized
        case .image:
            "ImgLicense.nav.title".localized
        }
    }

    func select(_ option: SettingsLicenseOption) {
        useCase.select(option, for: kind)
        selectedOptionID = option.id
    }
}
