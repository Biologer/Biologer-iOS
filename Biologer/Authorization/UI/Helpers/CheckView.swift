//
//  CheckView.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

struct CheckView: View {
   @State var isChecked:Bool = false
    
    var onToggle: Observer<Bool>

   var body: some View {
        Button(action:  {
            isChecked.toggle()
            onToggle((isChecked))
        }){
            Image(isChecked ? "checked_mark": "unchecked_mark")
        }
        .frame(width: 35, height: 35)
    }
}
