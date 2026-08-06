import SwiftUI

struct BiologerHelpScreen: View {
    @StateObject private var viewModel: HelpScreenViewModel
    private let onDone: Observer<Void>

    init(onDone: @escaping Observer<Void>) {
        _viewModel = StateObject(wrappedValue: HelpScreenViewModel())
        self.onDone = onDone
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
                    action: nextTapped
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

    private func nextTapped() {
        guard viewModel.nextTapped() else { return }
        onDone(())
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
