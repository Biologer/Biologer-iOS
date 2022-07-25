//
//  SideMenuItem.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import Foundation

public enum SideMenuItemType {
    case listOfFindings
    case setup
    case logout
    case deleteAccount
    case about
    case help
}

public struct SideMenuItem {
    var id: Int
    var image: String
    var title: String
    var type: SideMenuItemType
}
