//
//  NoItemsView.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import SwiftUI

struct NoItemsView: View {
    
    var title: String
    
    var body: some View {
        VStack {
            Text(title)
        }
    }
}

struct NoItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NoItemsView(title: "No Data")
    }
}
