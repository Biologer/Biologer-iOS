//
//  APIError.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.9.21..
//

import Foundation

public struct APIErrorResponse: Codable {
    let error: String
    let error_description: String
}

public final class APIError: Error {
    let title: String
    let description: String
    
    init(title: String = "Error", description: String) {
        self.title = title
        self.description = description
    }
}

let parsingErrorConstant = "Parsing error"
let environmentNotSelected = "Environment is not selected"
