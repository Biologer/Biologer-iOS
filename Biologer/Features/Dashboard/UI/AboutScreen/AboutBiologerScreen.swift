//
//  AboutBiologerScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import SwiftUI

protocol AboutBiologerScreenLoader: ObservableObject {
    var topImge: String { get }
    var currentDbDescription: String { get }
    var currentEnv: String { get }
    var descriptionOne: String { get }
    var descriptionTwo: String { get }
    var descriptionThree: String { get }
    var envButtonTitle: String { get }
    func envTapped()
    var version: String { get }
}

struct AboutBiologerScreen<ScreenLoader>: View where ScreenLoader: AboutBiologerScreenLoader {
    
    private let spacing: CGFloat = 20
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        ScrollView {
            VStack {
                Image(loader.topImge)
                    .resizable()
                    .frame(height: 130)
                    .padding(.bottom, spacing)
                Text(loader.currentDbDescription)
                    .font(.headerFont)
                    .multilineTextAlignment(.center)
                Text(loader.currentEnv)
                    .font(.headerFont)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, spacing)
                Text(loader.descriptionOne)
                    .font(.headerFont)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, spacing)
                Text(loader.descriptionTwo)
                    .font(.headerFont)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, spacing)
                Text(loader.descriptionThree)
                    .font(.headerFont)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, spacing)
                Button(action: {
                    loader.envTapped()
                }, label: {
                    Text(loader.envButtonTitle)
                        .font(.headerFont)
                        .foregroundColor(.biologerGreenColor)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, spacing)
                })
                .padding(.bottom, 50)
                Text(loader.version)
                    .font(.headerFont)
            }
            .navigationBarBackButtonHidden(true)
            .padding(.leading, 30)
            .padding(.trailing, 30)
        }
    }
}

struct AboutBiologerScreen_Previews: PreviewProvider {
    static var previews: some View {
        AboutBiologerScreen(loader: AboutBiologerScreenViewModel())
    }
    
    private class AboutBiologerScreenViewModel: AboutBiologerScreenLoader {
        var currentDbDescription: String = "You are currently logged into a datebase:"
        var topImge: String = "biologer_logo_icon"
        var currentEnv: String = "https://dev.biologer.org"
        var descriptionOne: String = "Biologer is Open Source application issued under MIT license and designed to collect data on biodiversity in Eastern Europe."
        var descriptionTwo: String = "Biologer was developed with founds from Rufford Small Grands (project Nos.20507-B and 24652-B) and MAVA (project No. 15097)"
        var descriptionThree: String = "To find out more details aboud Biologer, visit our web page:"
        var envButtonTitle: String = "https://biologer.org"
        var version: String = "Version: 3.0.4"
        func envTapped() {}
    }
}
