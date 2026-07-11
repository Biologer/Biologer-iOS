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
    private var isLoading = false

    public var topImage: String
    public var acceptPPCheckMark: Bool = false

    public var onReadPrivacyPolicy: Observer<Void>
    private let onDataLicense: Observer<CheckMarkItem>
    private let onImageLicense: Observer<CheckMarkItem>
    private let onSuccess: Observer<Void>
    private let onError: Observer<APIError>
    private let useCase: RegisterUserUseCase


    init(
        user: RegistrationDraft,
        topImage: String,
        useCase: RegisterUserUseCase,
        dataLicense: CheckMarkItem,
        imageLicense: CheckMarkItem,
        onReadPrivacyPolicy: @escaping Observer<Void>,
        onDataLicense: @escaping Observer<CheckMarkItem>,
        onImageLicense: @escaping Observer<CheckMarkItem>,
        onSuccess: @escaping Observer<Void>,
        onError: @escaping Observer<APIError>
    ) {
        self.user = user
        self.topImage = topImage
        self.useCase = useCase
        self.dataLicense = dataLicense
        self.imageLicense = imageLicense
        self.onReadPrivacyPolicy = onReadPrivacyPolicy
        self.onDataLicense = onDataLicense
        self.onImageLicense = onImageLicense
        self.onSuccess = onSuccess
        self.onError = onError
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
            try await useCase.createUser(user: user)
            isLoading = false
            onSuccess(())
        } catch let error {
            isLoading = false
            onError(error)
        }
    }
}
