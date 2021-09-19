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
    let isInternetConnectionAvailable: Bool
    
    init(title: String = "Error",
         description: String,
         isInternetConnectionAvailable: Bool = true) {
        self.title = title
        self.description = description
        self.isInternetConnectionAvailable = isInternetConnectionAvailable
    }
}

public final class ErrorConstant {
    public static let parsingErrorConstant = "Parsing error"
    public static let environmentNotSelected = "Environment is not selected"
    public static let noInternetConnectionTitle = "No Internet connection"
    public static let noInternetConnectionDescription = "Please check your internet connection and try again"
}
