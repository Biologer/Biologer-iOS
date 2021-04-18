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

struct EnvironmentScreen<ViewModel>: View where ViewModel: EnvironmentScreenLoader {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.title)
                .padding(.top, 10)
                .padding(.leading, 10)
                .padding(.trailing, 10)
            Divider()
            VStack {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.environmentsViewModel) { env in
                            environmentView(environmentViewModel: env)
                        }
                    }
                }
            }
            .padding(.bottom, 10)
        }
        .fixedSize()
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    private func environmentView(environmentViewModel: EnvironmentViewModel) -> some View {
        HStack {
            Image(environmentViewModel.image)
                .resizable()
                .frame(width: 35, height: 35)
            Text(environmentViewModel.title)
                .font(.system(size: 13))
                .foregroundColor(Color.gray)
        }
        .onTapGesture {
            viewModel.selectedEnvironment(envViewModel: environmentViewModel)
        }
    }
}

struct EnvironmentScreen_Previews: PreviewProvider {
    static var previews: some View {
        EnvironmentScreen(viewModel: StubEnvironmentScreenViewModel())
    }
    
    private class StubEnvironmentScreenViewModel: EnvironmentScreenLoader {
        let title: String = "Select desired environment"
        var environmentsViewModel: [EnvironmentViewModel]
        
        init() {
            self.environmentsViewModel = [
                EnvironmentViewModel(title: "Serbia", image: "serbia_flag", url: "www.serbia.com"),
                EnvironmentViewModel(title: "Croatia", image: "croatia_flag", url: "www.croatia.com"),
                EnvironmentViewModel(title: "Bosnia and Herzegovina", image: "bosnia_flag_icon", url: "www.bosniaandherzegovina.com"),EnvironmentViewModel(title: "For Developers", image: "hammer_icon", url: "www.bosniaandherzegovina.com")
            ]
        }
        
        func selectedEnvironment(envViewModel: EnvironmentViewModel) {}
    }
}
