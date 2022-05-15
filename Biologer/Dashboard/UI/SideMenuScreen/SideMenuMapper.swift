//
//  SideMenuMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import Foundation

public final class SideMenuMapper {
    public static var items: [[SideMenuItem]] {
        let firstSectionListSideMenu = [SideMenuItem(id: 1,
                                                     image: "list_of_findings_icon",
                                                     title: "SideMenu.lb.listOfFindings".localized,
                                                     type: .listOfFindings),
                                        SideMenuItem(id: 2,
                                                     image: "setup_icon",
                                                     title: "SideMenu.lb.setup".localized,
                                                     type: .setup),
                                        SideMenuItem(id: 3,
                                                     image: "logout_icon",
                                                     title: "SideMenu.lb.Logout".localized,
                                                     type: .logout)]
                       
        let secondSectionListSideMenu = [SideMenuItem(id: 1,
                                                      image: "about_icon",
                                                      title: "SideMenu.lb.AboutBiologer".localized,
                                                      type: .about),
                                         SideMenuItem(id: 2,
                                                      image: "help_icon",
                                                      title: "SideMenu.lb.Help".localized,
                                                      type: .help)]
        return [firstSectionListSideMenu, secondSectionListSideMenu]
    }
}
