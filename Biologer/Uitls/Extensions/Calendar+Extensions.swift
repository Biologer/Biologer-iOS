//
//  Calendar+Extensions.swift
//  Biologer
//
//  Created by Nikola Popovic on 25.9.23..
//

import Foundation

extension Calendar {
    static var getLastTimeTaxonUpdate: Int64 {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 2023
        dateComponents.month = 9
        dateComponents.day = 1

        if let date = calendar.date(from: dateComponents) {
            print("Last time update taxoxn: \(date)")
            return Int64(date.timeIntervalSince1970)
        } else {
            return 0
        }
    }
}
