//
//  DataLicenseScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

protocol CheckMarkScreenLoader: ObservableObject {
    var dataLicenses: [CheckMarkItem] { get }
    func licenseTapped(license: CheckMarkItem)
}

struct CheckMarkScreen<ScreenLoader>: View where ScreenLoader: CheckMarkScreenLoader {
    
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
        CheckMarkScreen(loader: StubCheckMarkScreenViewModel())
    }
    
    private class StubCheckMarkScreenViewModel: CheckMarkScreenLoader {
        var dataLicenses: [CheckMarkItem] = [CheckMarkItem(id: 1,
                                                       title: "Free (CC BY-SA)",
                                                       placeholder: "", licenseType: .data, isSelected: true),
                                           CheckMarkItem(id: 1,
                                                                           title: "Free (CC BY-SA)",
                                                                           placeholder: "", licenseType: .data, isSelected: false),
                                           CheckMarkItem(id: 1,
                                                                           title: "Free (CC BY-SA)",
                                                                           placeholder: "", licenseType: .data, isSelected: false)]
        
        func licenseTapped(license: CheckMarkItem) {}
    }
}
