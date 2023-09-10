//
//  EnvironmentScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import SwiftUI

struct EnvironmentScreen: View  {
    
    @ObservedObject var loader: EnvironmentScreenViewModel
    
    var body: some View {
        
        ScrollView {
            VStack {
                ForEach(loader.environmentsViewModel, id: \.id) { env in
                    HStack {
                        Image(env.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Button(action: {
                            loader.selectedEnvironment(envViewModel: env)
                        }, label: {
                            Text(env.title)
                                .font(.titleFont)
                                .foregroundColor(Color.black)
                                .multilineTextAlignment(.leading)
                        })
                        .padding()
                        Spacer()
                        Button(action: {
                            loader.selectedEnvironment(envViewModel: env)
                        }, label: {
                            Image("check_mark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 25)
                                .isHidden(!env.isSelected)
                            
                        })
                    }
                    .frame(height: 25)
                    .padding(10)
                    Divider()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct EnvironmentScreen_Previews: PreviewProvider {
    static var previews: some View {
        let envViewModels = EnvironmentViewModelFactory.createAllEnvironments()
        EnvironmentScreen(loader: EnvironmentScreenViewModel(environmentsViewModel: envViewModels,
                                                             selectedViewModel: envViewModels[0],
                                                             onSelectedEnvironment: { _ in}))

    }
}
