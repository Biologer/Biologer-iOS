//
//  MaterialDesignTextField.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import SwiftUI
import MaterialComponents.MaterialTextControls_OutlinedTextFields

public final class MaterialDesignTextField: UIViewRepresentable {
    
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
    
    public func makeUIView(context: Context) -> MDCOutlinedTextField {
        let textField = MDCOutlinedTextField()
        textField.returnKeyType = .done
        textField.keyboardType = keyboardType
        textField.isUserInteractionEnabled = viewModel.isUserInteractionEnabled
        textField.autocapitalizationType = keyboardType == .emailAddress ? .none : .sentences
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        textField.delegate = context.coordinator
        return textField
    }
    
    public func updateUIView(_ textField: MDCOutlinedTextField, context: Context) {
        setTextFieldTexts(textField: textField)
        setTextFieldColors(textField: textField)
        setTextFieldFonts(textField: textField)
        setTextFieldTralingIcon(textField: textField)
        textField.sizeToFit()
    }
    
    private func setTextFieldTexts(textField: MDCOutlinedTextField) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = viewModel.textAligment
        textField.text = viewModel.text
        textField.textAlignment = textAligment
        textField.label.text = viewModel.placeholder
        textField.attributedPlaceholder = NSAttributedString(string: viewModel.placeholder,
                                                             attributes: [.paragraphStyle: paragraphStyle])
        textField.leadingAssistiveLabel.text = viewModel.getErrorText()
    }
    
    private func setTextFieldColors(textField: MDCOutlinedTextField) {
        
        textField.setTextColor(.darkText, for: .editing)
        textField.setTextColor(viewModel.type == .failure ? .red : .darkText, for: .normal)
        textField.tintColor = .biologerGreenColor
        textField.setNormalLabelColor(.gray, for: .normal)
        
        textField.setFloatingLabelColor(viewModel.type == .failure ? .red : UIColor.gray, for: .normal)
        textField.setFloatingLabelColor(.biologerGreenColor, for: .editing)
        
        textField.setLeadingAssistiveLabelColor(.red, for: .editing)
        textField.setLeadingAssistiveLabelColor(.red, for: .normal)
        
        textField.setOutlineColor(viewModel.type == .failure ? .red : .gray, for: .normal)
        textField.setOutlineColor(.biologerGreenColor, for: .editing)
        textField.isSecureTextEntry = viewModel.isCodeEntry
    }
    
    private func setTextFieldFonts(textField: MDCOutlinedTextField) {
        textField.font = UIFont.systemFont(ofSize: titleFontSize)
        textField.leadingAssistiveLabel.font = UIFont.systemFont(ofSize:descriptionFontSize)
    }
    
    private func setTextFieldTralingIcon(textField: MDCOutlinedTextField) {
        if let icon = viewModel.getIconImageByType() {
            textField.trailingViewMode = .always
//            if viewModel.isPassword {
                icon.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(iconTapped))
                icon.addGestureRecognizer(tapGesture)
//            }
            icon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            icon.contentMode = .scaleAspectFit
            textField.trailingView = icon
        } else {
            textField.trailingView = nil
        }
    }
    
    @objc private func iconTapped() {
        self.onIconTapped?(())
    }
    
    public func makeCoordinator() -> MaterialDesignTextFieldDelegate {
        MaterialDesignTextFieldDelegate(viewModel: viewModel, onTextChanged: self.onTextChanged, onIconTapped: self.onIconTapped)
    }
    
    public class MaterialDesignTextFieldDelegate: NSObject, UITextFieldDelegate {
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
            //self.onTextChanged((textField.text ?? ""))
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

struct MaterialDesignTextField_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
