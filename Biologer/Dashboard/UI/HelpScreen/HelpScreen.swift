//
//  HelpScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import SwiftUI

protocol HelpScreenLoader: ObservableObject {
    var currentPageIndex: Int { get set }
    var numerOfPages: Int { get }
    func nextTapped()
    func previousTapped()
}

struct HelpScreen<ScreenLoader>: View where ScreenLoader: HelpScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        ScrollView {
            ZStack {
                LazyHStack {
                    PageView(selection: $loader.currentPageIndex, numberOfPages: 4)
                }
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            loader.previousTapped()
                        }, label: {
                            Image("forward_icon")
                                .resizable()
                                .frame(width: 50, height: 50)
                        })
                        .rotationEffect(.degrees(-180))
                        .padding(20)
                        Spacer()
                        Button(action: {
                            loader.nextTapped()
                        }, label: {
                            Image("forward_icon")
                                .resizable()
                                .frame(width: 50, height: 50)
                        })
                        .padding(20)
                    }
                }
            }
        }
    }
}

struct PageView: View {
    
    @Binding var selection: Int
    var numberOfPages: Int
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(0..<numberOfPages) { i in
                ZStack {
                    Color.black
                    Text("Row: \(i)").foregroundColor(.white)
                }.clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 400)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .animation(.easeInOut) // 2
        .transition(.slide) // 3
    }
}

struct HelpScreen_Previews: PreviewProvider {
    static var previews: some View {
        HelpScreen(loader: StubHelpScreenViewModel())
    }
    
    private class StubHelpScreenViewModel: HelpScreenLoader {
        var numerOfPages: Int = 4
        var currentPageIndex: Int = 3
        func nextTapped() {}
        func previousTapped() {}
    }
}
