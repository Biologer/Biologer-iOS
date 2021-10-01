//
//  TaxonSearchBarView.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import SwiftUI

struct TaxonSearchBarView: View {
    
    @State private var isEditing = false
    public var text: String
    let onTextChanged: Observer<String>
    
    var body: some View {
        HStack {
            
            SearchTextField(text: text,
                            onTextChanged: onTextChanged)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .frame(height: 40)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing {
                            Button(action: {
                                onTextChanged((""))
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    onTextChanged((text))
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
        
}

struct TaxonSearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        TaxonSearchBarView(text: "Search for something..", onTextChanged: { _ in })
    }
}
