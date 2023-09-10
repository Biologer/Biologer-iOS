//
//  NewTaxonImageViewModelFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.9.23..
//

import UIKit

public final class FindingImageFactory {
    static func getModels() -> [FindingImage] {
        return [FindingImage(image: UIImage(named: "intro4")!),
                FindingImage(image: UIImage(named: "img_placeholder_icon")!),
                FindingImage(image: UIImage(named: "intro4")!),
                FindingImage(image: UIImage(named: "img_placeholder_icon")!),
                FindingImage(image: UIImage(named: "intro4")!)]
    }
}
