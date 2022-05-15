//
//  View+Extensions.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.7.21..
//

import SwiftUI

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}
