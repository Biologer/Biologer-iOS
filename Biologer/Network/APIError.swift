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
    
    init(title: String = "API.lb.error".localized,
         description: String,
         isInternetConnectionAvailable: Bool = true) {
        self.title = title
        self.description = description
        self.isInternetConnectionAvailable = isInternetConnectionAvailable
    }
}

public final class ErrorConstant {
    public static let parsingErrorConstant = "API.lb.parsingError".localized
    public static let accountDeletionFailed = "API.lb.accountDeletionFailed".localized
    public static let environmentNotSelected = "API.lb.envError".localized
    public static let noInternetConnectionTitle = "API.lb.noInternetError".localized
    public static let noInternetConnectionDescription = "API.lb.noInternetDescriptionError".localized
}
