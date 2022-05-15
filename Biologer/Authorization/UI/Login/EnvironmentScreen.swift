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
    }
}

struct EnvironmentScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let envViewModels = [EnvironmentViewModel(id: 1,
                                                  title: "Serbia",
                                                  image: "serbia_flag",
                                                  env: Environment(host: serbiaHost, path: serbiaPath, clientSecret: serbiaClientSecret),
                                                  isSelected: false),
                             EnvironmentViewModel(id: 2,
                                                  title: "Croatia",
                                                  image: "croatia_flag",
                                                  env: Environment(host: croatiaHost, path: croatiaPath, clientSecret: croatiaClientSecret),
                                                  isSelected: false),
                             
                             EnvironmentViewModel(id: 3, title: "Bosnia and Herzegovina",
                                                  image: "bosnia_flag_icon",
                                                  env: Environment(host: bosnianAndHerzegovinHost, path: bosnianAndHerzegovinaPath, clientSecret: bosnianAndHercegovinaClientSecret),
                                                  isSelected: false),
                             EnvironmentViewModel(id: 4, title: "For Developers",
                                                  image: "hammer_icon",
                                                  env: Environment(host: devHost, path: devPath, clientSecret: devClientSecret),
                                                  isSelected: false)]
        
        let selectedEnv = EnvironmentViewModel(id: 1,
                                               title: "Serbia",
                                               image: "serbia_flag",
                                               env: Environment(host: serbiaHost, path: serbiaPath, clientSecret: serbiaClientSecret),
                                               isSelected: false)
        
        EnvironmentScreen(loader: EnvironmentScreenViewModel(environmentsViewModel: envViewModels, selectedViewModel: selectedEnv, onSelectedEnvironment: { _ in}))

    }
}
