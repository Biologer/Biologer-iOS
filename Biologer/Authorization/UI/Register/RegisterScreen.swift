//
//  RegisterScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

protocol RegisterScreenLoader: ObservableObject {
    var userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var lastNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var institutionTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var emailTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var repeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol { get set }
    var dataLicense: DataLicense { get }
    var imageLicense: DataLicense { get }
    var acceptPPTitle: String { get }
    var acceptPPChceckMark: Bool { get }
    var privacyPolicyDescription: String { get }
    var onReadPrivacyPolicy: Observer<Void> { get }
    var onDataLicense: Observer<Void> { get }
    var onImageLIcense: Observer<Void> { get }
    var onRegister: Observer<Void> { get }
}

struct RegisterScreen<ScreenLoader>: View where ScreenLoader: RegisterScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct RegisterScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterScreen(loader: StubRegisterScreenViewModel())
    }
    
    public final class StubRegisterScreenViewModel: RegisterScreenLoader {
        var userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = UserNameTextFieldViewModel()
        var lastNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = SurnameTextFieldViewModel()
        var institutionTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = InsititutionTextFieldViewModel()
        var emailTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = EmailTextFieldViewModel()
        var passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = RegisterPasswordTextFieldViewModel()
        var repeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = RepeatPasswordTextFieldViewModel()
        var dataLicense: DataLicense = DataLicense(id: 11, title: "Free (CC BY-SA)“ int vrednost")
        var imageLicense: DataLicense = DataLicense(id: 10, title: "Share images for free (CC-BY-SA)")
        var acceptPPTitle: String = "I accept privary policy"
        var acceptPPChceckMark: Bool = false
        var privacyPolicyDescription: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        var onReadPrivacyPolicy: Observer<Void> = { _ in }
        var onDataLicense: Observer<Void> = { _ in }
        var onImageLIcense: Observer<Void> = { _ in }
        var onRegister: Observer<Void> = { _ in }
    }
}
