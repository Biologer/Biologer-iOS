protocol LicenseOptionsProviding {
    func options(for kind: LicenseKind) -> [LicenseOption]
}

extension LicenseOptionsProviding {
    func option(id: Int, kind: LicenseKind) -> LicenseOption? {
        options(for: kind).first { $0.id == id }
    }

    func defaultOption(for kind: LicenseKind) -> LicenseOption {
        guard let option = options(for: kind).first else {
            preconditionFailure("At least one \(kind.rawValue) license is required")
        }
        return option
    }
}

/// Provides the app-bundled license choices with text from the current locale.
struct DefaultLicenseOptionsProvider: LicenseOptionsProviding {
    func options(for kind: LicenseKind) -> [LicenseOption] {
        switch kind {
        case .data:
            dataLicenses
        case .image:
            imageLicenses
        }
    }

    private var dataLicenses: [LicenseOption] {
        let details = "Register.three.dataLicense.placeholder".localized
        return [
            option(10, .data, "DataLicense.lb.one", details),
            option(20, .data, "DataLicense.lb.two", details),
            option(30, .data, "DataLicense.lb.three", details),
            option(35, .data, "DataLicense.lb.four", details),
            option(40, .data, "DataLicense.lb.five", details)
        ]
    }

    private var imageLicenses: [LicenseOption] {
        let details = "Register.three.imageLicense.placeholder".localized
        return [
            option(10, .image, "ImgLicense.lb.one", details),
            option(20, .image, "ImgLicense.lb.two", details),
            option(30, .image, "ImgLicense.lb.three", details),
            option(40, .image, "ImgLicense.lb.four", details)
        ]
    }

    private func option(
        _ id: Int,
        _ kind: LicenseKind,
        _ titleKey: String,
        _ details: String
    ) -> LicenseOption {
        LicenseOption(
            id: id,
            kind: kind,
            title: titleKey.localized,
            details: details
        )
    }
}
