//
//  NoInternetConnectionValidator.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import Foundation

class NoInternetConnectionValidator {
    
    typealias NSErrorCode = Int
    
    static func noInternetConnection(errorCode: NSErrorCode) -> Bool {
        return errorCode == NSURLErrorNetworkConnectionLost || errorCode == NSURLErrorNotConnectedToInternet || errorCode == NSURLErrorDataNotAllowed
    }
}
