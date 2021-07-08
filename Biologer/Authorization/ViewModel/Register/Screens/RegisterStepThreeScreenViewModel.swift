//
//  RegisterStepThreeScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class RegisterStepThreeScreenViewModel: RegisterStepThreeScreenLoader, ObservableObject {
    public var registerButtonTitle: String = "Register"
    public var topImage = "serbia_flag"
    @Published public var dataLicense: DataLicense
    @Published public var imageLicense: DataLicense
    public var acceptPPTitle: String = "I accept privary policy"
    public var acceptPPChceckMark: Bool = false
    public var privacyPolicyDescription: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
    public var onReadPrivacyPolicy: Observer<Void>
    private let onDataLicense: Observer<DataLicense>
    private let onImageLicense: Observer<DataLicense>
    
    private let onSuccess: Observer<Void>
    private let onError: Observer<Void>
    private let user: User
    private let service: RegisterUserService
    
    init(user: User,
         service: RegisterUserService,
         dataLicense: DataLicense,
         imageLicense: DataLicense,
         onReadPrivacyPolicy: @escaping Observer<Void>,
         onDataLicense: @escaping Observer<DataLicense>,
         onImageLicense: @escaping Observer<DataLicense>,
         onSuccess: @escaping Observer<Void>,
         onError: @escaping Observer<Void>) {
        self.user = user
        self.service = service
        self.dataLicense = dataLicense
        self.imageLicense = imageLicense
        self.onReadPrivacyPolicy = onReadPrivacyPolicy
        self.onDataLicense = onDataLicense
        self.onImageLicense = onImageLicense
        self.onSuccess = onSuccess
        self.onError = onError
    }
    
    public func registerTapped() {
        
    }
    
    public func dataLicenseTapped() {
        onDataLicense((dataLicense))
    }
    
    public func imageLicenseTapped() {
        onImageLicense((imageLicense))
    }
}

extension RegisterStepThreeScreenViewModel: DataLicenseScreenDelegate {
    public func get(license: DataLicense) {
        if license.licenseType == .data {
            dataLicense = DataLicense(id: license.id, title: license.title, placeholder: license.placeholder, licenseType: .data)
        } else {
            imageLicense = DataLicense(id: license.id, title: license.title, placeholder: license.placeholder, licenseType: .image)
        }
    }
}
