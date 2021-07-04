//
//  CodableParser.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public protocol CodableParser {
    func parse<T:Codable>(from data: Data) -> T?
}

public extension CodableParser {
    func parse<T:Codable>(from data: Data) -> T? {
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
