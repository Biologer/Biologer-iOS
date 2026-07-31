//
//  ErrorLabelView.swift
//  Biologer
//
//  Created by Nikola Popovic on 8.7.21..
//

import SwiftUI

struct ErrorLabelView: View {
    public let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(Color.red)
    }
}

struct ErrorLabelView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorLabelView(text: "Some error")
    }
}
