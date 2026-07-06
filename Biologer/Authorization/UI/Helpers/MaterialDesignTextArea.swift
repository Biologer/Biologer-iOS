//
//  MaterialDesignTextArea.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

public final class BiologerOutlinedTextAreaView: UIView {
    let textView = UITextView()
    private let titleLabel = UILabel()
    private let assistiveLabel = UILabel()
    private let containerView = UIView()
    private let trailingContainer = UIView()
    private var trailingView: UIView?
    private var isEditingText = false
    private var fieldType: MaterialDesignTextFieldType = .success
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 112)
    }
    
    func configure(viewModel: MaterialDesignTextFieldViewModelProtocol,
                   textAligment: NSTextAlignment,
                   icon: UIView?,
                   onIconTapped: (() -> Void)?) {
        fieldType = viewModel.type
        isUserInteractionEnabled = viewModel.isUserInteractionEnabled
        titleLabel.text = viewModel.placeholder
        assistiveLabel.text = viewModel.getErrorText()
        textView.textAlignment = textAligment
        textView.isSecureTextEntry = viewModel.isCodeEntry
        if textView.text != viewModel.text {
            textView.text = viewModel.text
        }
        
        setTrailingIcon(icon, onIconTapped: onIconTapped)
        applyColors()
    }
    
    func setEditing(_ isEditing: Bool) {
        isEditingText = isEditing
        applyColors()
    }
    
    private func setUpView() {
        containerView.layer.cornerRadius = 4
        containerView.layer.borderWidth = 1
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.systemFont(ofSize: descriptionFontSize)
        titleLabel.backgroundColor = .systemBackground
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        assistiveLabel.font = UIFont.systemFont(ofSize: descriptionFontSize)
        assistiveLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textView.font = UIFont.systemFont(ofSize: titleFontSize)
        textView.returnKeyType = .done
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 6, right: 6)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        trailingContainer.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        addSubview(titleLabel)
        addSubview(assistiveLabel)
        containerView.addSubview(textView)
        containerView.addSubview(trailingContainer)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 82),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.topAnchor),
            
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
            textView.trailingAnchor.constraint(equalTo: trailingContainer.leadingAnchor, constant: -4),
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            
            trailingContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            trailingContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            trailingContainer.widthAnchor.constraint(equalToConstant: 28),
            trailingContainer.heightAnchor.constraint(equalToConstant: 28),
            
            assistiveLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            assistiveLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            assistiveLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 3),
            assistiveLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
    
    private func setTrailingIcon(_ icon: UIView?, onIconTapped: (() -> Void)?) {
        trailingView?.removeFromSuperview()
        trailingView = icon
        trailingContainer.isHidden = icon == nil
        
        guard let icon else { return }
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.addTapGestureRecognizer(action: onIconTapped)
        trailingContainer.addSubview(icon)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: trailingContainer.leadingAnchor),
            icon.trailingAnchor.constraint(equalTo: trailingContainer.trailingAnchor),
            icon.topAnchor.constraint(equalTo: trailingContainer.topAnchor),
            icon.bottomAnchor.constraint(equalTo: trailingContainer.bottomAnchor)
        ])
    }
    
    private func applyColors() {
        let hasFailure = fieldType == .failure
        let activeColor = UIColor.biologerGreenColor
        let normalColor = hasFailure ? UIColor.red : UIColor.gray
        
        textView.textColor = hasFailure && !isEditingText ? .red : .darkText
        textView.tintColor = activeColor
        titleLabel.textColor = isEditingText ? activeColor : normalColor
        assistiveLabel.textColor = .red
        containerView.layer.borderColor = (isEditingText ? activeColor : normalColor).cgColor
    }
}

public struct MaterialDesignTextArea: UIViewRepresentable {
    
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
    
    public func makeUIView(context: Context) -> BiologerOutlinedTextAreaView {
        let view = BiologerOutlinedTextAreaView()
        view.textView.keyboardType = keyboardType
        view.textView.autocapitalizationType = keyboardType == .emailAddress ? .none : .sentences
        view.textView.delegate = context.coordinator
        context.coordinator.textAreaView = view
        return view
    }
    
    public func updateUIView(_ textField: BiologerOutlinedTextAreaView, context: Context) {
        context.coordinator.viewModel = viewModel
        context.coordinator.onTextChanged = onTextChanged
        context.coordinator.onIconTapped = onIconTapped
        textField.configure(viewModel: viewModel,
                            textAligment: textAligment,
                            icon: viewModel.getIconImageByType(),
                            onIconTapped: { onIconTapped?(()) })
    }
    
    public func makeCoordinator() -> MaterialDesignTextFieldDelegate {
        MaterialDesignTextFieldDelegate(viewModel: viewModel, onTextChanged: self.onTextChanged, onIconTapped: self.onIconTapped)
    }
    
    public class MaterialDesignTextFieldDelegate: NSObject, UITextViewDelegate {
        var viewModel: MaterialDesignTextFieldViewModelProtocol
        var onTextChanged: Observer<String>
        var onIconTapped: Observer<Void>?
        weak var textAreaView: BiologerOutlinedTextAreaView?
        
        init(viewModel: MaterialDesignTextFieldViewModelProtocol,
             onTextChanged: @escaping Observer<String>,
             onIconTapped: Observer<Void>?) {
            self.viewModel = viewModel
            self.onTextChanged = onTextChanged
            self.onIconTapped = onIconTapped
        }
        
        @objc public func textViewDidChange(_ textView: UITextView) {
            self.onTextChanged((textView.text ?? ""))
            viewModel.text = textView.text ?? ""
            viewModel.type = .success
        }
        
        public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            self.onTextChanged((textView.text ?? ""))
            viewModel.text = textView.text ?? ""
            viewModel.type = .success
            textAreaView?.setEditing(true)
            return true
        }
    
        
        public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
            self.onTextChanged((textView.text ?? ""))
            viewModel.text = textView.text ?? ""
            viewModel.type = .success
            textAreaView?.setEditing(false)
            return true
        }
        
        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}
