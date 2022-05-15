//
//  NewTaxonLocationView.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

struct NewTaxonLocationView: View {
    
    @ObservedObject var viewModel: NewTaxonLocationViewModel
    private let addLocationButtonWidth: CGFloat = 40
    private let addLocationButtoneHeight: CGFloat = 50
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                if let texonLocation = viewModel.taxonLocation {
                    HStack {
                        Text(viewModel.latitudeTitle)
                            .font(.descriptionBoldFont)
                            .foregroundColor(Color.black)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(texonLocation.latitudeString)
                            .font(.descriptionFont)
                            .foregroundColor(Color.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack {
                        Text(viewModel.longitudeTitle)
                            .font(.descriptionBoldFont)
                            .foregroundColor(Color.black)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(texonLocation.longitudeString)
                            .font(.descriptionFont)
                            .foregroundColor(Color.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack {
                        Text(viewModel.altitudeTitle)
                            .font(.descriptionBoldFont)
                            .foregroundColor(Color.black)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(viewModel.getAltitude)
                            .font(.descriptionFont)
                            .foregroundColor(Color.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack {
                        Text(viewModel.accuraccyTitle)
                            .font(.descriptionBoldFont)
                            .foregroundColor(Color.black)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(viewModel.getAccuracy)
                            .font(.descriptionFont)
                            .foregroundColor(Color.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    Text(viewModel.waitingForCordiateLabel)
                        .font(.descriptionFont)
                }
            }
            .padding(.leading, 10)
            Spacer()
            VStack {
                Spacer()
                Button(action: {
                    viewModel.locationTapped()
                }, label: {
                    ZStack {
                        Image(viewModel.locatioButtonImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: addLocationButtonWidth, height: addLocationButtoneHeight, alignment: .center)
                            .shadow(radius: 10)
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(viewModel.plusIconImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 23, height: 23)
                                    .padding(.trailing, -7)
                            }
                        }
                        .frame(width: addLocationButtonWidth, height: addLocationButtoneHeight)
                    }
                })
                Spacer()
            }
            .padding(.trailing, 30)
        }
    }
}

struct NewTaxonLocationView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = NewTaxonLocationViewModel(location: LocationManager(),
                                                  taxonLocation: TaxonLocation(latitude: 123.21, longitute: 123.123, accuracy: 12.2, altitude: 434.3))

        NewTaxonLocationView(viewModel: viewModel)
    }
}
