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
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
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
            .padding(.horizontal, 10)
            Spacer()
        }
        .animation(.default)
        .background(Color.biologerGreenColor.opacity(0.4))
        .ignoresSafeArea(.container, edges: .bottom)
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
