//
//  TaxonMapScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct TaxonMapScreen: View {
    
    let viewModel: TaxonMapScreenViewModel
    
    var body: some View {
        Button(action: {
            viewModel.doneTapped()
        }, label: {
            Text("Update location")
        })
    }
}

struct TaxonMapScreen_Previews: PreviewProvider {
    static var previews: some View {
        TaxonMapScreen(viewModel: TaxonMapScreenViewModel())
    }
}
