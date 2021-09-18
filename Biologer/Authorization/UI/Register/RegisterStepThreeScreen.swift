//
//  RegisterStepThreeScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

public protocol RegisterStepThreeScreenLoader: ObservableObject {
    var topImage: String { get }
    var dataLicense: CheckMarkItem { get }
    var imageLicense: CheckMarkItem { get }
    var acceptPPTitle: String { get }
    var registerButtonTitle: String { get }
    var acceptPPChceckMark: Bool { get set }
    var privacyPolicyDescription: String { get }
    var errorLabel: String { get set }
    var onReadPrivacyPolicy: Observer<Void> { get }
    func dataLicenseTapped()
    func imageLicenseTapped()
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
                                    onDataTapped: loader.dataLicenseTapped)
                    RegisterLicenseView(dataLicense: loader.imageLicense,
                                    onDataTapped: loader.imageLicenseTapped)
                    Text(loader.privacyPolicyDescription)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(action: {
                        loader.onReadPrivacyPolicy(())
                    }, label: {
                        AttributedTextView(configuration: { label in
                            label.attributedText = createUnderlinePrivacyPolicy(text: "Privacy Policy")
                            label.numberOfLines = 0
                            label.textAlignment = .center
                            label.textColor = UIColor.biologerGreenColor
                        })
                    })
                    
                    HStack {
                        CheckView(isChecked: false,
                                  onToggle: { isChecked in
                                    loader.acceptPPChceckMark = isChecked
                                  })
                        Text(loader.acceptPPTitle)
                        Spacer()
                    }
                    BiologerButton(title: loader.registerButtonTitle,
                                onTapped: { _ in
                                    loader.registerTapped()
                                })
                    ErrorLabelView(text: loader.errorLabel)
                        .padding()
                }
           }
            .padding(.all, 30)
    }
    
    public func createUnderlinePrivacyPolicy(text: String) -> NSMutableAttributedString {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        return NSMutableAttributedString(string: text, attributes: underlineAttribute)
    }
}

struct RegisterStepThreeScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterStepThreeScreen(loader: StubRegisterStepThreeScreenViewModel())
    }
    
    private class StubRegisterStepThreeScreenViewModel: RegisterStepThreeScreenLoader {
        var errorLabel: String = ""
        var topImage = "serbia_flag"
        var dataLicense: CheckMarkItem = CheckMarkItem(id: 11, title: "Free (CC BY-SA)“ int vrednost", placeholder: "Data License", licenseType: .data, isSelected: true)
        var imageLicense: CheckMarkItem = CheckMarkItem(id: 10, title: "Share images for free (CC-BY-SA)", placeholder: "Image License", licenseType: .data, isSelected: true)
        var registerButtonTitle = "Register"
        var acceptPPTitle: String = "I accept privary policy"
        var acceptPPChceckMark: Bool = false
        var privacyPolicyDescription: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
        var onReadPrivacyPolicy: Observer<Void> = { _ in }
        func registerTapped() {}
        func dataLicenseTapped() {}
        func imageLicenseTapped() {}
    }
}
