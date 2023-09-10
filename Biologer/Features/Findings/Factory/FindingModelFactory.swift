//
//  FindingModelFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.9.23..
//

import UIKit

public final class FindingModelFactory {
    static func getFindgins() -> [Finding] {
        return [Finding(id: UUID(),
                        taxon: "Zerynthia polyxena",
                        image: UIImage(),
                        developmentStage: "Larva",
                        isUploaded: false),
                Finding(id: UUID(),
                        taxon: "Salamandra salamandra",
                        image: UIImage(),
                        developmentStage: "Adult",
                        isUploaded: true),
                Finding(id: UUID(),
                        taxon: "Salamandra salamandra",
                        image: UIImage(),
                        developmentStage: "Adult",
                        isUploaded: false)]
    }
}
