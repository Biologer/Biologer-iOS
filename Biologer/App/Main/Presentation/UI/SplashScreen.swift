import SwiftUI

struct SplashScreen: View {
    private let onSplashScreenDone: Observer<Void>

    init(onSplashScreenDone: @escaping Observer<Void>) {
        self.onSplashScreenDone = onSplashScreenDone
    }

    var body: some View {
        VStack {
            Image("biologer_logo_icon")
                .resizable()
                .scaledToFit()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .biologerPageBackground()
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard !Task.isCancelled else { return }
            onSplashScreenDone(())
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(onSplashScreenDone: { _ in })
    }
}
