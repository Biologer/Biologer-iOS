//
//  TaxonMapScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct TaxonMapScreen: View {
    
    @ObservedObject var viewModel: TaxonMapScreenViewModel
    
    var body: some View {
        ZStack {
            GoogleMapsView(locationManager: viewModel.locationManager,
                           taxonLocation: viewModel.taxonLocation,
                           onTapAtCoordinate: { location in
                            viewModel.doneTapped(location: location)
                           })
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Image("setup_icon")
                            .resizable()
                            .frame(width: 40, height: 40)
                    })
                    .padding(30)
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.setMarkerToCurrentLocation()
                    }, label: {
                        Image("current_location_icon")
                            .resizable()
                            .frame(width: 60, height: 60)
                    })
                    .padding(30)
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct TaxonMapScreen_Previews: PreviewProvider {
    static var previews: some View {
        TaxonMapScreen(viewModel: TaxonMapScreenViewModel(locationManager: LocationManager()))
    }
}
