//
//  DataLicenseScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

protocol CheckMarkScreenLoader: ObservableObject {
    var items: [CheckMarkItem] { get }
    func itemTapped(item: CheckMarkItem)
}

struct CheckMarkScreen<ScreenLoader>: View where ScreenLoader: CheckMarkScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(loader.items, id: \.id) { item in
                    HStack {
                        Button(action: {
                            loader.itemTapped(item: item)
                        }, label: {
                            Text(item.title)
                                .font(.titleFont)
                                .foregroundColor(Color.black)
                                .multilineTextAlignment(.leading)
                        })
                        .padding()
                        Spacer()
                        Button(action: {
                            loader.itemTapped(item: item)
                        }, label: {
                            Image("check_mark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 25)
                                .isHidden(!item.isSelected)
                            
                        })
                        .padding(10)
                    }
                    Divider()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct DataLicenseScreen_Previews: PreviewProvider {
    static var previews: some View {
        CheckMarkScreen(loader: StubCheckMarkScreenViewModel())
    }
    
    private class StubCheckMarkScreenViewModel: CheckMarkScreenLoader {
        
        var items: [CheckMarkItem] = [CheckMarkItem(id: 1,
                                                       title: "Free (CC BY-SA)",
                                                       placeholder: "", type: .data, isSelected: true),
                                           CheckMarkItem(id: 1,
                                                                           title: "Free (CC BY-SA)",
                                                                           placeholder: "", type: .data, isSelected: false),
                                           CheckMarkItem(id: 1,
                                                                           title: "Free (CC BY-SA)",
                                                                           placeholder: "", type: .data, isSelected: false)]
        
        func itemTapped(item: CheckMarkItem){}
    }
}
