//
//  CheckMarkItemMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class CheckMarkItemMapper {
    public static func getDataLicense() -> [CheckMarkItem] {
        let dataLicenses = [CheckMarkItem(id: 10,
                                        title: "Free (CC BY-SA)",
                                        placeholder: "Data License",
                                        type: .data, isSelected: true),
                            CheckMarkItem(id: 20,
                                        title: "Free, NonCommercial (CC BY-SA-NC)",
                                        placeholder: "Data License",
                                        type: .data, isSelected: false),
                            CheckMarkItem(id: 30,
                                        title: "Partially Open (restricted to 10km)",
                                        placeholder: "Data License",
                                        type: .data, isSelected: false),
                            CheckMarkItem(id: 11,
                                        title: "Temporary closed (publish as free after 3 years)",
                                        placeholder: "Data License",
                                        type: .data, isSelected: false),
                            CheckMarkItem(id: 40,
                                        title: "Closed (available to you and the editors)",
                                        placeholder: "Data License",
                                        type: .data, isSelected: false)]
        return dataLicenses
    }
    
    public static func getImageLicense() -> [CheckMarkItem] {
        let imageLicenses = [CheckMarkItem(id: 10,
                                        title: "Share images for free (CC-BY-SA)",
                                        placeholder: "Image License",
                                        type: .image, isSelected: true),
                            CheckMarkItem(id: 20,
                                        title: "Share images as noncommercial (CC-BY-SA-NC)",
                                        placeholder: "Image License",
                                        type: .image, isSelected: false),
                            CheckMarkItem(id: 30,
                                        title: "Keep authorship and share online with watermark",
                                        placeholder: "Image License",
                                        type: .image, isSelected: false),
                            CheckMarkItem(id: 40,
                                        title: "Keep authorship and restrict images from public domain",
                                        placeholder: "Image License",
                                        type: .image, isSelected: false)]
        return imageLicenses
    }
}