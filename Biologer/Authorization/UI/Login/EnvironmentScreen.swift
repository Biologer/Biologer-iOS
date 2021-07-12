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
                            .frame(width: 30, height: 30)
                        Button(action: {
                            loader.selectedEnvironment(envViewModel: env)
                        }, label: {
                            Text(env.title)
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
                                .frame(width: 30, height: 30)
                                .isHidden(!env.isSelected)
                            
                        })
                    }
                    .frame(height: 25)
                    .padding()
                    Divider()
                }
            }
        }
    }
}

struct EnvironmentScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let envViewModels = [
            EnvironmentViewModel(id: 1, title: "Serbia", placeholder: "", image: "serbia_flag", host: "www.serbia.com", path: "/sr", isSelected: false),
            EnvironmentViewModel(id: 2, title: "Croatia", placeholder: "", image: "croatia_flag", host: "www.croatia.com", path: "/hr", isSelected: false),
            EnvironmentViewModel(id: 3, title: "Bosnia and Herzegovina", placeholder: "", image: "bosnia_flag_icon", host: "www.bosniaandherzegovina.com",
                                 path: "/ba", isSelected: true),
            EnvironmentViewModel(id: 4, title: "For Developers", placeholder: "", image: "hammer_icon", host: "www.bosniaandherzegovina.com",
                                 path: "/org",isSelected: false)
        ]
        
        let selectedEnv = EnvironmentViewModel(id: 1, title: "Serbia", placeholder: "", image: "serbia_flag", host: "www.serbia.com", path: "/sr", isSelected: true)
        
        EnvironmentScreen(loader: EnvironmentScreenViewModel(environmentsViewModel: envViewModels, selectedViewModel: selectedEnv, onSelectedEnvironment: { _ in}))

    }
}
