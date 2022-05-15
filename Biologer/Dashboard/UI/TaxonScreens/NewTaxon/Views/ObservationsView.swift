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
    let height: CGFloat = 40
    
    var body: some View {
        HStack {
            ForEach(observations.indices, id: \.self) { index in
                if index > 1 {
                    Button(action: {
                        onObservationTapped((index))
                    }, label: {
                        Text(observations[index].name)
                            .foregroundColor(Color.white)
                            .font(.titleFont)
                            .padding(12)
                    })
                        .background(observations[index].isSelected ? Color.biologerGreenColor : Color.gray)
                        .cornerRadius(height / 2)
                        .frame(height: height)
                }
            }
            Spacer()
        }
        .padding(.bottom, 10)
    }
}

struct ObservationsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let observation1 = Observation(id: 1, name: "NewTaxon.btn.callObservation.text".localized)
        let observation2 = Observation(id: 2, name: "NewTaxon.btn.exuviaeObservation.text".localized)
        
        ObservationsView(observations: [observation1, observation2],
                                       onObservationTapped: { index in })
    }
}
