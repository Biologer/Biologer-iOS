//
//  MaterialDesignTextFieldViewModelProtocol.swift
//  Biologer
//
//  Created by Nikola Popovic on 9.9.23..
//

import Foundation
import UIKit

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
