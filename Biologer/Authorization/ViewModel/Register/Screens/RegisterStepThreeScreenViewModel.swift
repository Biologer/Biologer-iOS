//
//  RegisterStepThreeScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class RegisterStepThreeScreenViewModel: RegisterStepThreeScreenLoader {
    public var topImage = "serbia_flag"
    public var dataLicense: DataLicense
    public var imageLicense: DataLicense
    public var acceptPPTitle: String = "I accept privary policy"
    public var acceptPPChceckMark: Bool = false
    public var privacyPolicyDescription: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
    public var onReadPrivacyPolicy: Observer<Void>
    public var onDataLicense: Observer<Void>
    public var onImageLicense: Observer<Void>
    
    private let onSuccess: Observer<Void>
    private let onError: Observer<Void>
    private let user: User
    private let service: RegisterUserService
    
    init(user: User,
         service: RegisterUserService,
         dataLicense: DataLicense,
         imageLicense: DataLicense,
         onReadPrivacyPolicy: @escaping Observer<Void>,
         onDataLicense: @escaping Observer<Void>,
         onImageLicense: @escaping Observer<Void>,
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
}
