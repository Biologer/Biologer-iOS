//
//  SearchTextField.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import SwiftUI
import Foundation

public final class SearchTextField: UIViewRepresentable {
    
    let text: String
    let onTextChanged: Observer<String>
    
    init(text: String,
         onTextChanged: @escaping Observer<String>) {
        self.text = text
        self.onTextChanged = onTextChanged
    }
    
    public func makeUIView(context: Context) ->  UITextField {
        let textField = UITextField()
        textField.text = text
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        textField.delegate = context.coordinator
        return textField
    }
    
    public func updateUIView(_ textField: UITextField, context: Context) {
        textField.sizeToFit()
    }
    
    public func makeCoordinator() -> SearchTextFieldDelegate {
        SearchTextFieldDelegate(onTextChanged: onTextChanged)
    }
    
    public final class SearchTextFieldDelegate: NSObject, UITextFieldDelegate {
        
        let onTextChanged: Observer<String>
        
        init(onTextChanged: @escaping Observer<String>) {
            self.onTextChanged = onTextChanged
        }
        
        @objc public func textViewDidChange(_ textField: UITextField) {
            self.onTextChanged((textField.text ?? ""))
        }
    }
}

struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(text: "Search for something..", onTextChanged: { text in })
    }
}
