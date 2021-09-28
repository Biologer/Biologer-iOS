//
//  MaterialDesignTextArea.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI
import MaterialComponents.MaterialTextControls_OutlinedTextAreas

public final class MaterialDesignTextArea: UIViewRepresentable {
    
    private var viewModel: MaterialDesignTextFieldViewModelProtocol
    private let onTextChanged: Observer<String>
    private let onIconTapped: Observer<Void>?
    private let keyboardType: UIKeyboardType
    private let textAligment: NSTextAlignment
    
    init(viewModel: MaterialDesignTextFieldViewModelProtocol,
         keyboardType: UIKeyboardType = .default,
         onTextChanged: @escaping Observer<String>,
         onIconTapped: Observer<Void>? = nil, textAligment: NSTextAlignment) {
        self.viewModel = viewModel
        self.onTextChanged = onTextChanged
        self.keyboardType = keyboardType
        self.onIconTapped = onIconTapped
        self.textAligment = textAligment
    }
    
    public func makeUIView(context: Context) -> MDCOutlinedTextArea {
        let textField = MDCOutlinedTextArea()
        textField.textView.returnKeyType = .done
        textField.textView.keyboardType = keyboardType
        textField.textView.isUserInteractionEnabled = viewModel.isUserInteractionEnabled
        textField.textView.autocapitalizationType = keyboardType == .emailAddress ? .none : .sentences
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        textField.textView.delegate = context.coordinator
        textField.textView.sizeToFit()
        textField.maximumNumberOfVisibleRows = 100
        return textField
    }
    
    public func updateUIView(_ textField: MDCOutlinedTextArea, context: Context) {
        setTextFieldTexts(textField: textField)
        setTextFieldColors(textField: textField)
        setTextFieldFonts(textField: textField)
        setTextFieldTralingIcon(textField: textField)
        textField.sizeToFit()
    }
    
    private func setTextFieldTexts(textField: MDCOutlinedTextArea) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = viewModel.textAligment
        textField.textView.text = viewModel.text
        textField.textView.textAlignment = textAligment
        textField.label.text = viewModel.placeholder
//        textField.attributedPlaceholder = NSAttributedString(string: viewModel.placeholder,
//                                                             attributes: [.paragraphStyle: paragraphStyle])
        textField.leadingAssistiveLabel.text = viewModel.getErrorText()
    }
    
    private func setTextFieldColors(textField: MDCOutlinedTextArea) {
        
        textField.setTextColor(.darkText, for: .editing)
        textField.setTextColor(viewModel.type == .failure ? .red : .darkText, for: .normal)
        textField.tintColor = .biologerGreenColor
        textField.setNormalLabel(.gray, for: .normal)
        
        textField.setFloatingLabel(viewModel.type == .failure ? .red : UIColor.gray, for: .normal)
        textField.setFloatingLabel(.biologerGreenColor, for: .editing)
        
        textField.setLeadingAssistiveLabel(.red, for: .editing)
        textField.setLeadingAssistiveLabel(.red, for: .normal)
        
        textField.setOutlineColor(viewModel.type == .failure ? .red : .gray, for: .normal)
        textField.setOutlineColor(.biologerGreenColor, for: .editing)
        textField.textView.isSecureTextEntry = viewModel.isCodeEntry
    }
    
    private func setTextFieldFonts(textField: MDCOutlinedTextArea) {
        textField.textView.font = UIFont(name: "Lato-Medium", size: 16)
        textField.leadingAssistiveLabel.font = UIFont(name: "Lato-Italic", size: 13)
    }
    
    private func setTextFieldTralingIcon(textField: MDCOutlinedTextArea) {
        if let icon = viewModel.getIconImageByType() {
            textField.trailingViewMode = .always
//            if viewModel.isPassword {
                icon.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(iconTapped))
                icon.addGestureRecognizer(tapGesture)
//            }
            icon.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            icon.contentMode = .scaleAspectFit
            textField.trailingView = icon
        } else {
            textField.trailingView = nil
        }
    }
    
    @objc private func iconTapped() {
        self.onIconTapped?(())
    }
    
    public func makeCoordinator() -> UITextViewDelegate {
        MaterialDesignTextFieldDelegate(viewModel: viewModel, onTextChanged: self.onTextChanged, onIconTapped: self.onIconTapped)
    }
    
    public class MaterialDesignTextFieldDelegate: NSObject, UITextViewDelegate {
        private var viewModel: MaterialDesignTextFieldViewModelProtocol
        private var onTextChanged: Observer<String>
        private var onIconTapped: Observer<Void>?
        
        init(viewModel: MaterialDesignTextFieldViewModelProtocol,
             onTextChanged: @escaping Observer<String>,
             onIconTapped: Observer<Void>?) {
            self.viewModel = viewModel
            self.onTextChanged = onTextChanged
            self.onIconTapped = onIconTapped
        }
        
        @objc public func textViewDidChange(_ textField: UITextField) {
            self.onTextChanged((textField.text ?? ""))
            viewModel.text = textField.text ?? ""
            viewModel.type = .success
        }
        
        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            self.onTextChanged((textField.text ?? ""))
            viewModel.text = textField.text ?? ""
            viewModel.type = .success
            return true
        }
        
        public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            self.onTextChanged((textField.text ?? ""))
            viewModel.text = textField.text ?? ""
            viewModel.type = .success
            return true
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

