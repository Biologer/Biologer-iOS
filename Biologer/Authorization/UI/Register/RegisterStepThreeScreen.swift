//
//  RegisterStepThreeScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

public protocol RegisterStepThreeScreenLoader: ObservableObject {
    var topImage: String { get }
    var dataLicense: DataLicense { get }
    var imageLicense: DataLicense { get }
    var acceptPPTitle: String { get }
    var acceptPPChceckMark: Bool { get }
    var privacyPolicyDescription: String { get }
    var onReadPrivacyPolicy: Observer<Void> { get }
    var onDataLicense: Observer<Void> { get }
    var onImageLicense: Observer<Void> { get }
    func registerTapped()
}

struct RegisterStepThreeScreen<ScreenLoader>: View where ScreenLoader: RegisterStepThreeScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        ScrollView {
            VStack {
                Image(loader.topImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                Text(loader.privacyPolicyDescription)
                    .padding(.top, 10)
                DataLicenseView(dataLicense: loader.dataLicense,
                                onDataTapped: loader.onDataLicense)
                    .padding(.top, 10)
                DataLicenseView(dataLicense: loader.imageLicense,
                                onDataTapped: loader.onImageLicense)
                    .padding(.top, 10)
            }
        }
        .padding()
    }
}

struct RegisterStepThreeScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterStepThreeScreen(loader: StubRegisterStepThreeScreenViewModel())
    }
    
    private class StubRegisterStepThreeScreenViewModel: RegisterStepThreeScreenLoader {
        var topImage = "serbia_flag"
        var dataLicense: DataLicense = DataLicense(id: 11, title: "Free (CC BY-SA)“ int vrednost", placeholder: "Data License")
        var imageLicense: DataLicense = DataLicense(id: 10, title: "Share images for free (CC-BY-SA)", placeholder: "Image License")
        var acceptPPTitle: String = "I accept privary policy"
        var acceptPPChceckMark: Bool = false
        var privacyPolicyDescription: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
        var onReadPrivacyPolicy: Observer<Void> = { _ in }
        var onDataLicense: Observer<Void> = { _ in }
        var onImageLicense: Observer<Void> = { _ in }
        func registerTapped() {}
    }
}
