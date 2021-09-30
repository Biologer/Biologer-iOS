//
//  ObservationsView.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct ObservationsView: View {
    
    let observations: [Observation]
    let onObservationTapped: Observer<Int>
    let height: CGFloat = 50
    
    var body: some View {
        ScrollView {
            HStack {
                ForEach(observations.indices, id: \.self) { index in
                    Button(action: {
                        onObservationTapped((index))
                    }, label: {
                        Text(observations[index].name)
                            .foregroundColor(Color.white)
                            .padding(12)
                    })
                    .background(observations[index].isSelected ? Color.biologerGreenColor : Color.gray)
                    .cornerRadius(height / 2)
                    .frame(height: height)
                }
                Spacer()
            }
        }
        .frame(height: height)
        .padding(.bottom, 10)
    }
}

struct ObservationsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let observation1 = Observation(name: "NewTaxon.btn.callObservation.text".localized)
        let observation2 = Observation(name: "NewTaxon.btn.exuviaeObservation.text".localized)
        
        ObservationsView(observations: [observation1, observation2],
                                       onObservationTapped: { index in })
    }
}
