//
//  HelpScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import SwiftUI

protocol HelpScreenLoader: ObservableObject {
    var title: String { get }
    var description: String { get }
    var currentPageIndex: Int { get set }
    var items: [HelpItemViewModel] { get }
    func nextTapped()
    func previousTapped()
}

struct HelpScreen<ScreenLoader>: View where ScreenLoader: HelpScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        ZStack {
            Color.biologerLightGreenColor
            LazyHStack {
                PageView(selection: $loader.currentPageIndex,
                         items: loader.items)
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
        .ignoresSafeArea()
    }
}

struct PageView: View {
    
    @Binding var selection: Int
    var items: [HelpItemViewModel]
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(0..<items.count) { i in
                ZStack {
                    Color.biologerLightGreenColor
                    VStack(alignment: .center) {
                        Text(items[i].title)
                            .foregroundColor(.white)
                            .font(.system(size: 32)).bold()
                            .padding(.top, 30)
                            .padding(.bottom, 30)
                        Image(items[i].image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .padding()
                        Text(items[i].description)
                            .foregroundColor(.white)
                            .font(.system(size: 26))
                            .padding(.top, 30)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .frame(width: UIScreen.screenWidth)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .animation(.easeInOut)
        .transition(.slide)
    }
}

struct HelpScreen_Previews: PreviewProvider {
    static var previews: some View {
        HelpScreen(loader: StubHelpScreenViewModel())
    }
    
    private class StubHelpScreenViewModel: HelpScreenLoader {
        var items: [HelpItemViewModel] = HelpItemManager.createHelpItems()
        var title: String = "Database option"
        var description: String = "Biologer application can connected to multiple datebase. You should start by choosing your preferred datebase and registering online."
        var numerOfPages: Int = 5
        var currentPageIndex: Int = 0
        func nextTapped() {}
        func previousTapped() {}
    }
}
