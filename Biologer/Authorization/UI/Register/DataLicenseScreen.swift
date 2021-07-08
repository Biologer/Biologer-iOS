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
                    Button(action: {
                        loader.licenseTapped(license: license)
                    }, label: {
                        Text(license.title)
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.leading)
                    })
                    .padding()
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
                                                       placeholder: "", licenseType: .data),
                                           DataLicense(id: 1,
                                                                           title: "Free (CC BY-SA)",
                                                                           placeholder: "", licenseType: .data),
                                           DataLicense(id: 1,
                                                                           title: "Free (CC BY-SA)",
                                                                           placeholder: "", licenseType: .data)]
        
        func licenseTapped(license: DataLicense) {}
    }
}
