//
//  DataLicenseScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

protocol DataLicenseScreenLoader: ObservableObject {
    var dataLicenses: [DataLicense] { get }
    func licenseTapped(license: DataLicense)
}

struct DataLicenseScreen<ScreenLoader>: View where ScreenLoader: DataLicenseScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(loader.dataLicenses, id: \.id) { license in
                    HStack {
                        Button(action: {
                            loader.licenseTapped(license: license)
                        }, label: {
                            Text(license.title)
                                .foregroundColor(Color.black)
                                .multilineTextAlignment(.leading)
                        })
                        .padding()
                        Spacer()
                        Button(action: {
                            loader.licenseTapped(license: license)
                        }, label: {
                            Image("check_mark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .isHidden(!license.isSelected)
                            
                        })
                        .padding()
                    }
                    Divider()
                }
            }
        }
    }
}

struct DataLicenseScreen_Previews: PreviewProvider {
    static var previews: some View {
        DataLicenseScreen(loader: StubDataLicenseScreenViewModel())
    }
    
    private class StubDataLicenseScreenViewModel: DataLicenseScreenLoader {
        var dataLicenses: [DataLicense] = [DataLicense(id: 1,
                                                       title: "Free (CC BY-SA)",
                                                       placeholder: "", licenseType: .data, isSelected: true),
                                           DataLicense(id: 1,
                                                                           title: "Free (CC BY-SA)",
                                                                           placeholder: "", licenseType: .data, isSelected: false),
                                           DataLicense(id: 1,
                                                                           title: "Free (CC BY-SA)",
                                                                           placeholder: "", licenseType: .data, isSelected: false)]
        
        func licenseTapped(license: DataLicense) {}
    }
}
