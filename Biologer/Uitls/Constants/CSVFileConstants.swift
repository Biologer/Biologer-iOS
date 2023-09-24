//
//  CSVFileConstants.swift
//  Biologer
//
//  Created by Nikola Popovic on 24.9.23..
//

import Foundation

public final class CSVFileConstants {
    private static let srbFileName = "biologerRS"
    private static let croFileName = "biologerHR"
    private static let bihFileName = "biologerBA"
    private static let mneFileName = "biologerME"
    private static let extensionName = "csv"
    
    public static let srbURL = Bundle.main.url(forResource: srbFileName, withExtension: extensionName)
    public static let croURL = Bundle.main.url(forResource: croFileName, withExtension: extensionName)
    public static let bihURL = Bundle.main.url(forResource: bihFileName, withExtension: extensionName)
    public static let mneURL = Bundle.main.url(forResource: mneFileName, withExtension: extensionName)
    
}
