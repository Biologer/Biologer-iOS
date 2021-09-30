//
//  TaxonImageView.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct TaxonImageView: View {
    
    let taxonImage: Image
    
    var body: some View {
        taxonImage
            .resizable()
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
        TaxonImageView(taxonImage: Image("taxon_background"))
    }
}
