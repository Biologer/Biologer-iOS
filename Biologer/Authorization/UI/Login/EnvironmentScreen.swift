//
//  EnvironmentScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import SwiftUI

public protocol EnvironmentScreenLoader: ObservableObject {
    var title: String { get }
    var environmentsViewModel: [EnvironmentViewModel] { get }
    func selectedEnvironment(envViewModel: EnvironmentViewModel)
}

struct EnvironmentScreen<ScreenLoader>: View where ScreenLoader: EnvironmentScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
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
        EnvironmentScreen(loader: StubEnvironmentScreenViewModel())
    }
    
    private class StubEnvironmentScreenViewModel: EnvironmentScreenLoader {
        let title: String = "Select desired environment"
        var environmentsViewModel: [EnvironmentViewModel]
        
        init() {
            self.environmentsViewModel = [
                EnvironmentViewModel(title: "Serbia", image: "serbia_flag", url: "www.serbia.com", isSelected: false),
                EnvironmentViewModel(title: "Croatia", image: "croatia_flag", url: "www.croatia.com", isSelected: false),
                EnvironmentViewModel(title: "Bosnia and Herzegovina", image: "bosnia_flag_icon", url: "www.bosniaandherzegovina.com", isSelected: true),
                EnvironmentViewModel(title: "For Developers", image: "hammer_icon", url: "www.bosniaandherzegovina.com", isSelected: false)
            ]
        }
        
        func selectedEnvironment(envViewModel: EnvironmentViewModel) {}
    }
}
