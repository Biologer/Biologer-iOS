//
//  NewEnvironmentsScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct NewEnvironmentsScreen: View  {
    
    @Binding var selectedEnvironment: EnvironmentViewModel
    
    @State
    private var environments: [EnvironmentViewModel]
    private let close: () -> Void
    
    init(
        selectedEnvironment: Binding<EnvironmentViewModel>,
        environments: [EnvironmentViewModel],
        close: @escaping () -> Void
    ) {
        _selectedEnvironment = selectedEnvironment
        self.environments = environments
        self.close = close
        updateSelectedEnvironment()
    }
    
    var body: some View {
        
        ScrollView {
            VStack {
                ForEach(environments, id: \.id) { environment in
                    HStack {
                        Image(environment.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Button(action: {
                            selectedEnvironment = environment
                        }, label: {
                            Text(environment.title)
                                .font(.titleFont)
                                .foregroundColor(Color.black)
                                .multilineTextAlignment(.leading)
                        })
                        .padding()
                        Spacer()
                        Button(action: {
                            selectedEnvironment = environment
                        }, label: {
                            Image("check_mark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 25)
                                .isHidden(!environment.isSelected)
                            
                        })
                    }
                    .frame(height: 25)
                    .padding(10)
                    Divider()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedEnvironment) { _ in
            updateSelectedEnvironment()
            close()
        }
    }
    
    private func updateSelectedEnvironment() {
        for (index, env) in environments.enumerated() {
            if env.id == selectedEnvironment.id {
                environments[index].changeIsSelected(value: true)
            } else {
                environments[index].changeIsSelected(value: false)
            }
        }
    }
}
