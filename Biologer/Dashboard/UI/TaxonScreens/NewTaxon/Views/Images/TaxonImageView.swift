//
//  TaxonImageView.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct TaxonImageView: View {
    
    let taxonImage: UIImage
    
    var body: some View {
        Image(uiImage: taxonImage)
            .resizable()
            .scaledToFit()
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .frame(width: 40, height: 50, alignment: .center)
    }
}

struct TaxonImageView_Previews: PreviewProvider {
    static var previews: some View {
        TaxonImageView(taxonImage: UIImage(named: "taxon_background")!)
    }
}
