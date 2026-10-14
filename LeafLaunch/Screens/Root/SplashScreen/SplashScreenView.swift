import SwiftUI

struct SplashScreenView: View {

    @Environment(\.style) private var style

    private let didFinishAction: () -> Void

    init(didFinishAction: @escaping () -> Void) {
        self.didFinishAction = didFinishAction
    }

    var body: some View {

        VStack(spacing: self.style.spacing(.medium)) {

            ImageSource.image(ImageResource(name: BusinessConfig.logoAssetName, bundle: .main))
                .view()
                .frame(width: 64, height: 64)
                .accessibilityLabel("App logo")

            Text("Loading your store").appFont(with: .BODY_2)
            ProgressView()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(self.style.background(.primary))
        .onFirstAppear { self.didFinishAction() }

    }

}

#Preview {

    SplashScreenView {}
        .withMockServices()

}
