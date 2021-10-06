//
//  NewTaxonLocationView.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

struct NewTaxonLocationView: View {
    
    @ObservedObject var viewModel: NewTaxonLocationViewModel
    @ObservedObject var location = LocationManager()
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.locationTapped()
            }, label: {
                VStack {
                    Image(viewModel.locatioButtonImage)
                        .resizable()
                        .frame(width: 30, height: 40, alignment: .center)
                        .shadow(radius: 10)
                    Text(viewModel.setLocationButtonTitle)
                        .font(.caption)
                }
            })
            VStack(alignment: .leading, spacing: 10) {
                if let texonLocation = viewModel.taxonLocation {
                    Text(String(texonLocation.latitude))
                        .font(.caption)
                        .foregroundColor(Color.black)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(String(texonLocation.longitute))
                        .font(.caption)
                        .foregroundColor(Color.black)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        Text(viewModel.accuraccyTitle)
                            .font(.caption)
                            .foregroundColor(Color.black)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(texonLocation.accuracy == 0.0 ? viewModel.accuracyUnknown : String(texonLocation.accuracy))
                            .font(.caption)
                            .foregroundColor(Color.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    Text(viewModel.waitingForCordiateLabel)
                        .foregroundColor(.red)
                }
            }
            .padding(.leading, 10)
            Spacer()
        }
    }
}

struct NewTaxonLocationView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = NewTaxonLocationViewModel(location: LocationManager(),
                                                  onLocationTapped: { _ in })
        NewTaxonLocationView(viewModel: viewModel)
    }
}
