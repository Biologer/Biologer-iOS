//
//  Font+Extensions.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.12.21..
//

import Foundation

import SwiftUI

extension Font {
    
    // MARK: - Title
    static var titleFontBold: Font {
        return .system(size: titleFontSize).bold()
    }
    
    static var titleFont: Font {
        return .system(size: titleFontSize)
    }
    
    static var titleFontItalic: Font {
        return .system(size: titleFontSize).italic()
    }
    
    // MARK: - Description
    static var descriptionFont: Font {
        return .system(size: descriptionFontSize)
    }
    
    static var descriptionBoldFont: Font {
        return .system(size: descriptionFontSize).bold()
    }
    
    // MARK: - Large
    
    static var largeTitleFont: Font {
        return .system(size: largeTitleFontSize)
    }
    
    static var largeTitleBoldFont: Font {
        return .system(size: largeTitleFontSize).bold()
    }
    
    // MARK: - Header
    static var headerFont: Font {
        return .system(size: headerTitleSize)
    }
    
    static var headerBoldFont: Font {
        return .system(size: headerTitleSize).bold()
    }
    
    // MARK: - Paragraph
    static var paragraphTitleFont: Font {
        return .system(size: paragraphTitleSize)
    }
    
    static var paragraphTitleBoldFont: Font {
        return .system(size: paragraphTitleSize).bold()
    }
}
