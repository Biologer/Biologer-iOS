//
//  RegisterLicenseView.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

struct RegisterLicenseView: View {
    
    var dataLicense: DataLicense
    var onDataTapped: Observer<Void>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dataLicense.placeholder)
                .font(.system(size: 12))
                .foregroundColor(Color.gray)
            HStack {
                Button(action: {
                    onDataTapped(())
                }, label: {
                    Text(dataLicense.title)
                        .foregroundColor(Color.black)
                })
                Spacer()
                Button(action: {
                    onDataTapped(())
                }, label: {
                    Image("right_arrow")
                })
            }
            Divider()
                .padding(.top, 4)
        }
    }
}

struct RegisterLicenseView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterLicenseView(dataLicense: DataLicense(id: 1, title: "", placeholder: ""), onDataTapped: { _ in})
    }
}
