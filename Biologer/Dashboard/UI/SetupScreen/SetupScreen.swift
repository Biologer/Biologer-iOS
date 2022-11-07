//
//  SetupScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import SwiftUI

struct SetupScreen: View  {
    
    @ObservedObject var viewModel: SetupScreenViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Color.clear
                    .padding(.top, 10)
                ForEach(viewModel.sections.indices, id: \.self) { sectionIndex in
                    let section = viewModel.sections[sectionIndex]
                    SetupSectionView(viewModel: section,
                                     onItemTapped: { itemIndex in
                                        viewModel.itemTapped(sectionIndex: sectionIndex,
                                                             itemIndex: itemIndex)
                                     })
                }
            }
            .padding(.horizontal, 30)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SetupScreen_Previews: PreviewProvider {
    static var previews: some View {
        SetupScreen(viewModel: SetupScreenViewModel(settingsStorage: UserDefaultsSettingsStorage(),
                                                    onItemTapped: { item in }))
    }
}
