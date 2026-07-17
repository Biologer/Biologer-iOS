//
//  RegistrationLicenseConsentViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import Foundation

@MainActor
public final class RegistrationLicenseConsentViewModel: ObservableObject {

    @Published
    public var dataLicense: CheckMarkItem

    @Published
    public var imageLicense: CheckMarkItem

    @Published
    public var errorLabel: String = ""

    @Published
    private var user: RegistrationDraft

    @Published
    public var isLoading = false

    @Published
    var registrationPopup: RegistrationPopup?

    public var topImage: String
    @Published public var acceptPPCheckMark: Bool = false

    public var onReadPrivacyPolicy: Observer<Void>
    private let onDataLicense: Observer<CheckMarkItem>
    private let onImageLicense: Observer<CheckMarkItem>
    private let onSuccess: Observer<Void>
    private let registrationUseCase: RegistrationUseCase


    init(
        user: RegistrationDraft,
        topImage: String,
        registrationUseCase: RegistrationUseCase,
        dataLicense: CheckMarkItem,
        imageLicense: CheckMarkItem,
        onReadPrivacyPolicy: @escaping Observer<Void>,
        onDataLicense: @escaping Observer<CheckMarkItem>,
        onImageLicense: @escaping Observer<CheckMarkItem>,
        onSuccess: @escaping Observer<Void>
    ) {
        self.user = user
        self.topImage = topImage
        self.registrationUseCase = registrationUseCase
        self.dataLicense = dataLicense
        self.imageLicense = imageLicense
        self.onReadPrivacyPolicy = onReadPrivacyPolicy
        self.onDataLicense = onDataLicense
        self.onImageLicense = onImageLicense
        self.onSuccess = onSuccess
    }

    public func dataLicenseTapped() {
        onDataLicense((dataLicense))
    }

    public func imageLicenseTapped() {
        onImageLicense((imageLicense))
    }

    public func registerTapped() async {
        if !acceptPPCheckMark {
            errorLabel = "Register.three.lb.error".localized
            return
        }
        user.dataLicense = dataLicense
        user.imageLicense = imageLicense
        errorLabel = ""

        isLoading = true
        do throws(APIError) {
            try await registrationUseCase.createUser(request: user.registrationRequest)
            isLoading = false
            registrationPopup = .success
        } catch let error {
            isLoading = false
            registrationPopup = .error(error)
        }
    }

    public func updateDataLicense(_ license: CheckMarkItem) {
        dataLicense = license
    }

    public func updateImageLicense(_ license: CheckMarkItem) {
        imageLicense = license
    }

    public func dismissRegistrationPopup() {
        registrationPopup = nil
    }

    public func confirmRegistrationSuccess() {
        registrationPopup = nil
        onSuccess(())
    }
}

enum RegistrationPopup: Identifiable {
    case error(APIError)
    case success

    var id: String {
        switch self {
        case .error:
            return "error"
        case .success:
            return "success"
        }
    }
}

private extension RegistrationDraft {
    var registrationRequest: RegistrationRequest {
        RegistrationRequest(
            firstName: username,
            lastName: lastname,
            institution: institution.isEmpty ? nil : institution,
            email: email,
            password: password,
            dataLicenseId: dataLicense.id,
            imageLicenseId: imageLicense.id
        )
    }
}
