//
//  NewTaxonLocationView.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

struct NewTaxonLocationView: View {
    
    @ObservedObject var viewModel: NewTaxonLocationViewModel
    
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
                if viewModel.isLoadingLocatino {
                    Text(viewModel.waitingForCordiateLabel)
                        .foregroundColor(.red)
                } else {
                    Text(viewModel.latitude)
                        .font(.caption)
                        .foregroundColor(Color.black)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(viewModel.longitude)
                        .font(.caption)
                        .foregroundColor(Color.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack {
                    Text(viewModel.accuraccyTitle)
                        .font(.caption)
                        .foregroundColor(Color.black)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(viewModel.isLoadingLocatino ? viewModel.accuracyUnknown : viewModel.accuraccy)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.leading, 10)
            Spacer()
        }
    }
}

struct NewTaxonLocationView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = NewTaxonLocationViewModel(isLoadingLocatino: false,
                                                          latitude: "44.7732 N",
                                                          longitude: "20.4163 E",
                                                          accuraccy: "13 m",
                                                          onLocationTapped: { _ in})
        
        NewTaxonLocationView(viewModel: viewModel)
    }
}