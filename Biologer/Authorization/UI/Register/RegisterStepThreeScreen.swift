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
    var registerButtonTitle: String { get }
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
                VStack(spacing: 20) {
                    Image(loader.topImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    RegisterLicenseView(dataLicense: loader.dataLicense,
                                    onDataTapped: loader.onDataLicense)
                    RegisterLicenseView(dataLicense: loader.imageLicense,
                                    onDataTapped: loader.onImageLicense)
                    Text(loader.privacyPolicyDescription)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Link(destination: URL(string: "https://www.apple.com")!, label: {
                        Text("Privacy Policy")
                            .foregroundColor(Color.biologerGreenColor)
                            .underline()
                    })
                    HStack {
                        CheckView(isChecked: false,
                                  onToggle: { isChecked in

                                  })
                        Text(loader.acceptPPTitle)
                        Spacer()
                    }
                    LoginButton(title: loader.registerButtonTitle,
                                onTapped: { _ in
                                    loader.registerTapped()
                                })
                }
           }
            .padding(.all, 30)
    }
    
    public func createAttributeString() -> NSMutableAttributedString {
        let text = NSMutableAttributedString(string: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")
        let interactableText = NSMutableAttributedString(string: "Sign in!")
        interactableText.addAttribute(.link,
                                      value: "SignInPseudoLink",
                                      range: NSRange(location: 0, length: interactableText.length))
        text.append(interactableText)
        
        return text
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
        var registerButtonTitle = "Register"
        var acceptPPTitle: String = "I accept privary policy"
        var acceptPPChceckMark: Bool = false
        var privacyPolicyDescription: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
        var onReadPrivacyPolicy: Observer<Void> = { _ in }
        var onDataLicense: Observer<Void> = { _ in }
        var onImageLicense: Observer<Void> = { _ in }
        func registerTapped() {}
    }
}
