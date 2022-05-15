//
//  NoImagesAddedView.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct NoImagesAddedView: View {
    
    let title: String

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack(alignment: .center) {
                Spacer()
                Text(title)
                    .foregroundColor(Color.gray)
                    .font(.descriptionFont)
                Spacer()
            }
            Spacer()
        }
    }
}

struct NoImagesAddedView_Previews: PreviewProvider {
    static var previews: some View {
        NoImagesAddedView(title: "NewTaxon.image.placeholder.title".localized)
    }
}
