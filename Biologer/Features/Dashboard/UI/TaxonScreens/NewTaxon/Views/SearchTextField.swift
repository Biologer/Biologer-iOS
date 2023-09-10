//
//  SearchTextField.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import SwiftUI
import Foundation

public struct SearchTextField: UIViewRepresentable {
    
    let text: String
    let onTextChanged: ((String, String?) -> Void)
    
    init(text: String,
         onTextChanged: @escaping ((String, String?) -> Void)) {
        self.text = text
        self.onTextChanged = onTextChanged
    }
    
    public func makeUIView(context: Context) ->  UITextField {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: titleFontSize)
        textField.text = text
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        textField.delegate = context.coordinator
        textField.becomeFirstResponder()
        return textField
    }
    
    public func updateUIView(_ textField: UITextField, context: Context) {
        textField.text = text
        textField.sizeToFit()
    }
    
    public func makeCoordinator() -> SearchTextFieldDelegate {
        SearchTextFieldDelegate(onTextChanged: onTextChanged)
    }
    
    public final class SearchTextFieldDelegate: NSObject, UITextFieldDelegate {
        
        let onTextChanged: ((String, String?) -> Void)
        
        init(onTextChanged: @escaping ((String, String?) -> Void)) {
            self.onTextChanged = onTextChanged
        }
        
        @objc public func textViewDidChange(_ textField: UITextField) {
            self.onTextChanged(textField.text ?? "", textField.textInputMode?.primaryLanguage)
        }
    }
}

struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(text: "Search for something..", onTextChanged: { text, keyboardLanguage in })
    }
}
