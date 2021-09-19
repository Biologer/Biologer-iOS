//
//  NewTaxonScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import SwiftUI

struct NewTaxonScreen: View {
    
    var viewModel: NewTaxonScreenViewModel
    
    var body: some View {
        
        Button(action: {
            viewModel.buttonTapped()
        }, label: {
            Text("New Taxon Screen")
        })
    }
}

struct NewTaxonScreen_Previews: PreviewProvider {
    static var previews: some View {
        NewTaxonScreen(viewModel: NewTaxonScreenViewModel(onButtonTapped: { _ in }))
    }
}
