//
//  CheckInternetConnection.swift
//  Biologer
//
//  Created by Nikola Popovic on 21.11.21..
//

import Foundation
import Reachability

public final class CheckInternetConnection {
    
    private let reachability: Reachability
    
    init() {
        reachability = try! Reachability()
    }
    
    public func isConnectedToWiFi() -> Bool {
        return reachability.connection == .wifi
    }
    
    public func isConnectedToCellularData() -> Bool {
        return reachability.connection == .cellular
    }
    
    public func isConnectedToInternet() -> Bool {
        return  reachability.connection == .unavailable ? false : true
    }
}
