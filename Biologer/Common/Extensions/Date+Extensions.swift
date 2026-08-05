//
//  Date+Extensions.swift
//  Biologer
//
//  Created by Nikola Popovic on 16.11.21..
//

import Foundation

extension Date {
    func component(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        calendar.component(component, from: self)
    }
    
    func formattedHoursAndMinutes() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: self)
    }
}
