//
//  DataLicenseScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

struct DataLicenseScreen: View {
    
    public let dataLicenses: [DataLicense]
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(dataLicenses, id: \.id) { license in
                    Text(license.title)
                        .multilineTextAlignment(.leading)
                    Divider()
                }
            }
        }
    }
}

struct DataLicenseScreen_Previews: PreviewProvider {
    static var previews: some View {
        let dataLicenses = [DataLicense(id: 1,
                                        title: "Free (CC BY-SA)",
                                        placeholder: ""),
                            DataLicense(id: 1,
                                                            title: "Free (CC BY-SA)",
                                                            placeholder: ""),
                            DataLicense(id: 1,
                                                            title: "Free (CC BY-SA)",
                                                            placeholder: "")]
        DataLicenseScreen(dataLicenses: dataLicenses)
    }
}
