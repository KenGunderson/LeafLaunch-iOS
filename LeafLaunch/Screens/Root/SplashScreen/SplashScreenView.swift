import SwiftUI

struct SplashScreenView: View {

    @Environment(\.style) private var style

    @State private var hasAppeared: Bool = false
    @State private var didNotifyCompletion: Bool = false

    private let didFinishAction: () -> Void

    private var appName: String? {

        let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        return name?.trimmingCharacters(in: .whitespacesAndNewlines)

    }

    init(didFinishAction: @escaping () -> Void) {
        self.didFinishAction = didFinishAction
    }

    var body: some View {

        VStack(spacing: self.style.spacing(.extraLarge)) {

            VStack(spacing: self.style.spacing(.large)) {

                SplashBrandMarkView()
                    .scaleEffect(self.hasAppeared ? 1 : 0.9)
                    .offset(y: self.hasAppeared ? 0 : self.style.spacing(.small))

                if let appName, !appName.isEmpty {

                    Text(appName)
                        .appFont(with: .HEADER_3)
                        .foregroundStyle(self.style.textColor(.title))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                }

            }

            loadingStatus()

        }
        .padding(.horizontal, self.style.spacing(.large))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            self.style.background(.primary).view().ignoresSafeArea()
        }
        .animation(.bouncy(duration: 0.6, extraBounce: 0.08), value: self.hasAppeared)
        .onFirstAppear {

            self.hasAppeared = true

            guard !self.didNotifyCompletion else { return }
            self.didNotifyCompletion = true
            self.didFinishAction()

        }

    }

    private func loadingStatus() -> some View {

        HStack(spacing: self.style.spacing(.small2)) {

            ProgressView()
                .tint(self.style.foreground(.primary).source(style: self.style))

            Text(String(localized: "Loading your store"))
                .appFont(with: .BODY_2)
                .foregroundStyle(self.style.textColor(.body))

        }

    }

}

#Preview {

    SplashScreenView {}
        .withMockPreviews()

}
