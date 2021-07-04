//
//  DataLicenseView.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

struct DataLicenseView: View {
    
    var dataLicense: DataLicense
    var onDataTapped: Observer<Void>
    
    var body: some View {
        VStack {
            Text(dataLicense.placeholder)
            HStack {
                Text(dataLicense.title)
                Spacer()
                Button(action: {
                    onDataTapped(())
                }, label: {
                    Image("right_arrow")
                        .resizable()
                        frame(width: 30, height: 30)
                })
            }
            Divider()
        }
    }
}

struct DateLicenseView_Previews: PreviewProvider {
    static var previews: some View {
        let dataLicense = DataLicense(id: 1,
                                              title: "Free (CC BY-SA)“ int vrednost 10",
                                              placeholder: "Data License")
        DataLicenseView(dataLicense: dataLicense,
                        onDataTapped: { _ in})
    }
}
