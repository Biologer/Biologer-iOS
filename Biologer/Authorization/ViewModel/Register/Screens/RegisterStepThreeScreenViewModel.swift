//
//  RegisterStepThreeScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class RegisterStepThreeScreenViewModel: RegisterStepThreeScreenLoader, ObservableObject {
    public var registerButtonTitle: String = "Register.three.btn.register".localized
    public var topImage: String
    @Published public var dataLicense: CheckMarkItem
    @Published public var imageLicense: CheckMarkItem
    public var acceptPPTitle: String = "Register.three.lb.acceptPrivacyPolicy".localized
    public var acceptPPChceckMark: Bool = false
    public var privacyPolicyDescription: String = "Register.three.lb.description".localized
    @Published public var errorLabel: String = ""
    public var onReadPrivacyPolicy: Observer<Void>
    private let onDataLicense: Observer<CheckMarkItem>
    private let onImageLicense: Observer<CheckMarkItem>
    
    private let onSuccess: Observer<Token>
    private let onError: Observer<APIError>
    private let onLoading: Observer<Bool>
    private let user: User
    private let service: RegisterUserService
    
    init(user: User,
         topImage: String,
         service: RegisterUserService,
         dataLicense: CheckMarkItem,
         imageLicense: CheckMarkItem,
         onReadPrivacyPolicy: @escaping Observer<Void>,
         onDataLicense: @escaping Observer<CheckMarkItem>,
         onImageLicense: @escaping Observer<CheckMarkItem>,
         onSuccess: @escaping Observer<Token>,
         onError: @escaping Observer<APIError>,
         onLoading: @escaping Observer<Bool>) {
        self.user = user
        self.topImage = topImage
        self.service = service
        self.dataLicense = dataLicense
        self.imageLicense = imageLicense
        self.onReadPrivacyPolicy = onReadPrivacyPolicy
        self.onDataLicense = onDataLicense
        self.onImageLicense = onImageLicense
        self.onSuccess = onSuccess
        self.onError = onError
        self.onLoading = onLoading
    }
    
    public func registerTapped() {
        validationFields()
    }
    
    public func dataLicenseTapped() {
        onDataLicense((dataLicense))
    }
    
    public func imageLicenseTapped() {
        onImageLicense((imageLicense))
    }
    
    private func validationFields() {
        if !acceptPPChceckMark {
            errorLabel = "Register.three.lb.error".localized
            return
        }
        user.dataLicense = dataLicense
        user.imageLicense = imageLicense
        errorLabel = ""
        
        onLoading((true))
        service.loadSearch(user: user) { [weak self] result in
            self?.onLoading((false))
            switch result {
            case .success(let response):
                print("Response: \(response)")
                let token = Token(accessToken: response.access_token, refreshToken: response.refresh_token)
                self?.onSuccess((token))
            case .failure(let error):
                self?.onError((error))
                print("Error: \(error)")
            }
        }
    }
}

extension RegisterStepThreeScreenViewModel: CheckMarkScreenDelegate {
    public func get(item: CheckMarkItem) {
        if item.type == .data {
            dataLicense = CheckMarkItem(id: item.id, title: item.title, placeholder: item.placeholder, type: .data, isSelected: item.isSelected)
        } else {
            imageLicense = CheckMarkItem(id: item.id, title: item.title, placeholder: item.placeholder, type: .image, isSelected: item.isSelected)
        }
    }
}
