//
//  TextFields.swift
//  Biologer
//
//  Created by Nikola Popovic on 29.9.21..
//

import UIKit


public final class TaxonNameTextField: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String = ""
    public var placeholder: String = "NewTaxon.tf.taxonName.placeholder".localized
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = "right_arrow"
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = false
    public var type: MaterialDesignTextFieldType = .success
    
    init(text: String) {
        self.text = text
    }
}

public final class NestingTextField: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String
    public var placeholder: String = "NewTaxon.tf.nesting.placeholder".localized
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = "right_arrow"
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = false
    public var type: MaterialDesignTextFieldType = .success
    
    init(text: String) {
        self.text = text
    }
}

public final class CommentsTextField: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String = ""
    public var placeholder: String = "NewTaxon.tf.comment.placeholder".localized
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = nil
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
    
    init(text: String) {
        self.text = text
    }
}

public final class IndividualTextField: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String = ""
    public var placeholder: String = "NewTaxon.tf.individual.placeholder".localized
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = nil
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
    
    init(text: String) {
        self.text = text
    }
}

public final class MaleIndividualTextField: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String = ""
    public var placeholder: String = "NewTaxon.tf.maleIndividual.placeholder".localized
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = nil
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
    
    init(text: String) {
        self.text = text
    }
}

public final class FemaleIndividualTextField: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String = ""
    public var placeholder: String = "NewTaxon.tf.femaleIndividual.placeholder".localized
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = nil
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
    
    init(text: String) {
        self.text = text
    }
}

public final class DevelopmentStageTextField: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String = ""
    public var placeholder: String = "NewTaxon.tf.developmentStage.placeholder".localized
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = "right_arrow"
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = false
    public var type: MaterialDesignTextFieldType = .success
    
    init(text: String) {
        self.text = text
    }
}

public final class HabitatlTextField: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String = ""
    public var placeholder: String = "NewTaxon.tf.habitat.placeholder".localized
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = nil
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
    
    init(text: String) {
        self.text = text
    }
}

public final class FoundOnTextField: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String = ""
    public var placeholder: String = "NewTaxon.tf.foundOn.placeholder".localized
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = nil
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
    
    init(text: String) {
        self.text = text
    }
}

public final class FoundDeadTextField: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String = ""
    public var placeholder: String = "NewTaxon.tf.foundDead.placeholder".localized
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = nil
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
    
    init(text: String) {
        self.text = text
    }
}
