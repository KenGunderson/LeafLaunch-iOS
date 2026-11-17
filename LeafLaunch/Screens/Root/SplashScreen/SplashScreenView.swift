import SwiftUI

struct SplashScreenView: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

        brandIdentity()
            .padding(.horizontal, .large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                background()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {

                loadingStatus()
                    .padding(.vertical, .large)

            }
            .onFirstAppear {

                withAnimation(
                    self.reduceMotion ? nil : .easeOut(duration: 0.7),
                    completionCriteria: .removed
                ) {

                    self.hasAppeared = true

                } completion: {

                    guard !self.didNotifyCompletion else { return }
                    self.didNotifyCompletion = true
                    self.didFinishAction()

                }

            }

    }

    @ViewBuilder
    private func background() -> some View {

        self.style.background(.primary).view()
            .overlay {

                RadialGradient(
                    colors: [
                        (self.style.palette(.link).resolvedColor()?.opacity(0.08) ?? .red),
                        (ColorSource.color(.clear).resolvedColor() ?? .red)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: self.style.spacing(.extraLarge2) * 4
                )

            }
            .ignoresSafeArea()

    }

    @ViewBuilder
    private func brandIdentity() -> some View {

        VStack(spacing: self.style.spacing(.large2)) {

            SplashBrandMarkView()
                .scaleEffect(self.hasAppeared || self.reduceMotion ? 1 : 0.96)

            welcomeCopy()

        }
        .opacity(self.hasAppeared || self.reduceMotion ? 1 : 0)
        .offset(y: self.hasAppeared || self.reduceMotion ? 0 : self.style.spacing(.small))

    }

    @ViewBuilder
    private func welcomeCopy() -> some View {

        if let appName, !appName.isEmpty {

            VStack(spacing: self.style.spacing(.small)) {

                Text(String(localized: "Welcome To"))
                    .appFont(with: .TITLE_1)
                    .textCase(.uppercase)
                    .tracking(2)
                    .foregroundStyle(self.style.textColor(.body))

                Text(appName)
                    .appFont(with: .HEADER_5)
                    .tracking(-0.5)
                    .foregroundStyle(self.style.textColor(.title))

            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func loadingStatus() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            ProgressView()
                .controlSize(.small)
                .tint(self.style.palette(.link).resolvedColor(style: self.style))

            Text(String(localized: "Loading Your Store"))
                .appFont(with: .NOTE_1)
                .foregroundStyle(self.style.textColor(.body))

        }

    }

}

#Preview {

    SplashScreenView {}
        .withMockPreviews()

}
