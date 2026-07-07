//
//  MaterialDesignTextField.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import SwiftUI

public final class BiologerOutlinedTextFieldView: UIView {
    let textField = UITextField()
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
        CGSize(width: UIView.noIntrinsicMetric, height: 66)
    }
    
    func configure(viewModel: MaterialDesignTextFieldViewModelProtocol,
                   textAligment: NSTextAlignment,
                   icon: UIView?,
                   onIconTapped: (() -> Void)?) {
        fieldType = viewModel.type
        isUserInteractionEnabled = viewModel.isUserInteractionEnabled
        titleLabel.text = viewModel.placeholder
        assistiveLabel.text = viewModel.getErrorText()
        textField.textAlignment = textAligment
        textField.attributedPlaceholder = NSAttributedString(
            string: viewModel.placeholder,
            attributes: [.paragraphStyle: paragraphStyle(alignment: viewModel.textAligment)]
        )
        textField.isSecureTextEntry = viewModel.isCodeEntry
        if textField.text != viewModel.text {
            textField.text = viewModel.text
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
        
        textField.font = UIFont.systemFont(ofSize: titleFontSize)
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        trailingContainer.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        addSubview(titleLabel)
        addSubview(assistiveLabel)
        containerView.addSubview(textField)
        containerView.addSubview(trailingContainer)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            containerView.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.topAnchor),
            
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: trailingContainer.leadingAnchor, constant: -8),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
            
            trailingContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            trailingContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
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
        
        textField.textColor = hasFailure && !isEditingText ? .red : .darkText
        textField.tintColor = activeColor
        titleLabel.textColor = isEditingText ? activeColor : normalColor
        assistiveLabel.textColor = .red
        containerView.layer.borderColor = (isEditingText ? activeColor : normalColor).cgColor
    }
    
    private func paragraphStyle(alignment: NSTextAlignment) -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        return paragraphStyle
    }
}





public enum MaterialDesignTextFieldType {
    case empty
    case success
    case failure
}

public enum MaterialDesignTextFieldTralingViewType {
    case password
    case none
    case other
}

public protocol MaterialDesignTextFieldViewModelProtocol {
    var text: String { get set }
    var placeholder: String { get }
    var errorText: String { get set }
    var isCodeEntry: Bool { get set }
    var tralingImage: String? { get }
    var tralingErrorImage: String? { get }
    var isUserInteractionEnabled: Bool { get }
    var type: MaterialDesignTextFieldType { get set }
    var textAligment: NSTextAlignment { get }
    var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>? { get set }
}

public protocol EnvironmentViewModelProtocol {
    var title: String { get }
    var image: String { get }
    var host: String { get }
}

extension MaterialDesignTextFieldViewModelProtocol {
    func getErrorText() -> String {
        return type == .failure ? errorText : ""
    }
    
    func getIconImageByType() -> UIImageView? {
        if type == .failure, let errorImage = tralingErrorImage {
            return UIImageView(image: UIImage(named: errorImage)!)
        } else if let image = tralingImage {
            return UIImageView(image: UIImage(named: image)!)
        } else {
            return nil
        }
    }
}


public struct MaterialDesignTextField: UIViewRepresentable {
    
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
    
    public func makeUIView(context: Context) -> BiologerOutlinedTextFieldView {
        let view = BiologerOutlinedTextFieldView()
        view.textField.keyboardType = keyboardType
        view.textField.autocapitalizationType = keyboardType == .emailAddress ? .none : .sentences
        view.textField.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        view.textField.delegate = context.coordinator
        context.coordinator.textFieldView = view
        return view
    }
    
    public func updateUIView(_ textField: BiologerOutlinedTextFieldView, context: Context) {
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
    
    public class MaterialDesignTextFieldDelegate: NSObject, UITextFieldDelegate {
        var viewModel: MaterialDesignTextFieldViewModelProtocol
        var onTextChanged: Observer<String>
        var onIconTapped: Observer<Void>?
        weak var textFieldView: BiologerOutlinedTextFieldView?
        
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
            viewModel.text = textField.text ?? ""
            viewModel.type = .success
            textFieldView?.setEditing(true)
            return true
        }
        
        public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            self.onTextChanged((textField.text ?? ""))
            viewModel.text = textField.text ?? ""
            viewModel.type = .success
            textFieldView?.setEditing(false)
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
