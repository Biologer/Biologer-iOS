import SwiftUI

protocol HelpScreenLoader: ObservableObject {
    var currentPageIndex: Int { get set }
    var items: [HelpItemViewModel] { get }
    func nextTapped()
    func previousTapped()
}

struct HelpScreen<ScreenLoader>: View where ScreenLoader: HelpScreenLoader {
    @ObservedObject var loader: ScreenLoader

    var body: some View {
        ZStack {
            Color.biologerHelpBacgroundGreen
            LazyHStack {
                PageView(
                    selection: $loader.currentPageIndex,
                    items: loader.items
                )
            }
            VStack {
                Spacer()
                HStack {
                    Button(action: loader.previousTapped) {
                        Image("forward_icon_1")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    .rotationEffect(.degrees(-180))
                    .padding(20)
                    Spacer()
                    Button(action: loader.nextTapped) {
                        Image("forward_icon_1")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    .padding(20)
                }
            }
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

struct PageView: View {
    @Binding var selection: Int
    var items: [HelpItemViewModel]
    let imageMultiplier: CGFloat = 0.5
    let imageSize = UIScreen.screenWidth * 0.6

    var body: some View {
        TabView(selection: $selection) {
            ForEach(0..<items.count) { index in
                ZStack {
                    Color.biologerHelpBacgroundGreen
                    VStack(alignment: .center) {
                        Text(items[index].title)
                            .foregroundColor(.white)
                            .font(.largeTitleBoldFont)
                            .padding(.top, 20)
                        Image(items[index].image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                        Text(items[index].description)
                            .foregroundColor(.white)
                            .font(.headerBoldFont)
                            .multilineTextAlignment(.center)
                            .padding(.top, 30)
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

    private final class StubHelpScreenViewModel: HelpScreenLoader {
        var items: [HelpItemViewModel] = HelpItemManager.createHelpItems()
        var currentPageIndex: Int = 0

        func nextTapped() {}
        func previousTapped() {}
    }
}
