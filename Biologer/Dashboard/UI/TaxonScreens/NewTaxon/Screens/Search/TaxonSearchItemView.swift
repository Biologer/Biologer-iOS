//
//  TaxonSearchItemView.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import SwiftUI

struct TaxonSearchItemView: View {
    
    let taxon: TaxonViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(taxon.name)
                    .font(.titleFont)
                    .foregroundColor(Color.black)
                    .padding(5)
                Spacer()
            }
            Divider()
            Spacer()
        }
    }
}

struct TaxonSearchItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaxonSearchItemView(taxon: TaxonViewModel(name: "Hello taxon"))
    }
}
