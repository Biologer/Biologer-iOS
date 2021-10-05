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
        GoogleMapsView(locationManager: viewModel.locationManager,
                       onTapAtCoordinate: { location in
                        viewModel.doneTapped(location: location)
                       })
            .frame(height: UIScreen.screenHeight)
    }
}

struct TaxonMapScreen_Previews: PreviewProvider {
    static var previews: some View {
        TaxonMapScreen(viewModel: TaxonMapScreenViewModel(locationManager: LocationManager()))
    }
}
