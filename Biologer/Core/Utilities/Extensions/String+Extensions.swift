//
//  String+Extensions.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
