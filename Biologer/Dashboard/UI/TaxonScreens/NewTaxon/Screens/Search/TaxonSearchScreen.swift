//
//  TaxonSearchScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import SwiftUI

struct TaxonSearchScreen: View {
    
    @ObservedObject var viewModel: TaxonSearchScreenViewModel
    
    var body: some View {
        
        VStack {
            TaxonSearchBarView(text: viewModel.searchText,
                               onTextChanged: { text in
                                viewModel.search(search: text)
                               },
                               onOkTapped: { _ in
                                viewModel.taxonTapped(taxon: TaxonViewModel(name: viewModel.searchText))
                               })
            Divider()
            LazyVStack {
                ForEach(viewModel.texons, id: \.id) { taxon in
                    Button(action: {
                        viewModel.taxonTapped(taxon: taxon)
                    }, label: {
                        TaxonSearchItemView(taxon: taxon)
                    })
                }
            }
            Spacer()
        }
        .padding(20)
    }
}

struct TaxonSearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = TaxonSearchScreenViewModel(service: DBTaxonService(),
                                                   delegate: nil,
                                                   onTaxonTapped: { taxon in
                                                    
                                                   },
                                                   onOkTapped: { taxon in
                                                    
                                                   })
        
        TaxonSearchScreen(viewModel: viewModel)
    }
}
