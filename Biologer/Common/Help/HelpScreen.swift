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

struct BiologerHelpScreen: View {
    @StateObject private var viewModel: HelpScreenViewModel

    init(onDone: @escaping Observer<Void>) {
        _viewModel = StateObject(
            wrappedValue: HelpScreenViewModel(onDone: onDone)
        )
    }

    var body: some View {
        VStack(spacing: BiologerSpacing.regular) {
            TabView(selection: $viewModel.currentPageIndex) {
                ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                    helpCard(item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentPageIndex)

            HStack(spacing: BiologerSpacing.regular) {
                navigationButton(
                    systemImage: "chevron.left",
                    action: viewModel.previousTapped
                )
                .disabled(viewModel.currentPageIndex == 0)
                .opacity(viewModel.currentPageIndex == 0 ? 0.35 : 1)

                Text(pageIndicator)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BiologerColors.sectionTitle)
                    .monospacedDigit()
                    .frame(minWidth: 64)

                navigationButton(
                    systemImage: isLastPage ? "checkmark" : "chevron.right",
                    action: viewModel.nextTapped
                )
            }
        }
        .padding(.horizontal, BiologerSpacing.regular)
        .padding(.top, BiologerSpacing.small)
        .padding(.bottom, BiologerSpacing.large)
        .biologerPageBackground()
        .tint(BiologerColors.accent)
    }

    private var isLastPage: Bool {
        viewModel.currentPageIndex == viewModel.items.count - 1
    }

    private var pageIndicator: String {
        guard !viewModel.items.isEmpty else { return "0 / 0" }
        return "\(viewModel.currentPageIndex + 1) / \(viewModel.items.count)"
    }

    private func helpCard(_ item: HelpItemViewModel) -> some View {
        VStack(spacing: BiologerSpacing.large) {
            Spacer(minLength: BiologerSpacing.small)

            Image(item.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 260, maxHeight: 260)

            VStack(spacing: BiologerSpacing.xSmall) {
                Text(item.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(BiologerColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(item.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: BiologerSpacing.small)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(BiologerSpacing.large)
        .biologerCard(cornerRadius: BiologerRadius.featureCard)
        .padding(.vertical, BiologerSpacing.xxSmall)
    }

    private func navigationButton(
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    BiologerColors.primaryActionBackground,
                    in: Circle()
                )
                .shadow(
                    color: BiologerColors.brandStrong.opacity(0.2),
                    radius: 7,
                    y: 3
                )
        }
        .buttonStyle(.plain)
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
