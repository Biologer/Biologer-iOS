//
//  CheckMarkItemMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class CheckMarkItemMapper {
    public static func getDataLicense() -> [CheckMarkItem] {
        let placeholder = "Register.three.dataLicense.placeholder".localized
        let dataLicenses = [CheckMarkItem(id: 10,
                                        title: "DataLicense.lb.one".localized,
                                        placeholder: placeholder,
                                        type: .data, isSelected: true),
                            CheckMarkItem(id: 20,
                                          title: "DataLicense.lb.two".localized,
                                        placeholder: placeholder,
                                        type: .data, isSelected: false),
                            CheckMarkItem(id: 30,
                                        title: "DataLicense.lb.three".localized,
                                        placeholder: placeholder,
                                        type: .data, isSelected: false),
                            CheckMarkItem(id: 35,
                                          title: "DataLicense.lb.four".localized,
                                        placeholder: placeholder,
                                        type: .data, isSelected: false),
                            CheckMarkItem(id: 40,
                                          title: "DataLicense.lb.five".localized,
                                        placeholder: placeholder,
                                        type: .data, isSelected: false)]
        return dataLicenses
    }
    
    public static func getImageLicense() -> [CheckMarkItem] {
                
        let placeholder = "Register.three.imageLicense.placeholder".localized
        let imageLicenses = [CheckMarkItem(id: 10,
                                        title: "ImgLicense.lb.one".localized,
                                        placeholder: placeholder,
                                        type: .image, isSelected: true),
                            CheckMarkItem(id: 20,
                                          title: "ImgLicense.lb.two".localized,
                                        placeholder: placeholder,
                                        type: .image, isSelected: false),
                            CheckMarkItem(id: 30,
                                          title: "ImgLicense.lb.three".localized,
                                        placeholder: placeholder,
                                        type: .image, isSelected: false),
                            CheckMarkItem(id: 40,
                                          title: "ImgLicense.lb.four".localized,
                                        placeholder: placeholder,
                                        type: .image, isSelected: false)]
        return imageLicenses
    }
}
