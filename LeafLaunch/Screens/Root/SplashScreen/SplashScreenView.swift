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
            .runePadding(.horizontal, LLSpacing.content)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                background()
            }
            .safeAreaInset(
                edge: .bottom,
                spacing: 0
            ) {

                loadingStatus()
                    .runePadding(.vertical, LLSpacing.content)

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

    @ContentBuilder
    private func background() -> some View {

        RNColorSource.background(.primary).view()
            .overlay {

                RadialGradient(
                    colors: [
                        (RNColorSource.palette(.link).resolvedColor(style: self.style)?.opacity(0.08) ?? .red),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: self.style.spacing(.extraLarge2) * 4
                )

            }
            .ignoresSafeArea()

    }

    @ContentBuilder
    private func brandIdentity() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.hero)) {

            SplashBrandMarkView()
                .scaleEffect(self.hasAppeared || self.reduceMotion ? 1 : 0.96)

            welcomeCopy()

        }
        .opacity(self.hasAppeared || self.reduceMotion ? 1 : 0)
        .offset(y: self.hasAppeared || self.reduceMotion ? 0 : self.style.spacing(LLSpacing.groupedContent))

    }

    @ContentBuilder
    private func welcomeCopy() -> some View {

        if let appName, !appName.isEmpty {

            VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                Text(String(localized: "Welcome To"))
                    .runeFont(with: .TITLE_1)
                    .textCase(.uppercase)
                    .tracking(2)
                    .runeTextColor(.body)

                Text(appName)
                    .runeFont(with: .HEADER_5)
                    .tracking(-0.5)
                    .runeTextColor(.title)

            }
            .multilineTextAlignment(.center)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

        }

    }

    @ContentBuilder
    private func loadingStatus() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            ProgressView()
                .controlSize(.small)
                .tint(RNColorSource.palette(.link))

            Text(String(localized: "Loading Your Store"))
                .runeFont(with: .NOTE_1)
                .runeTextColor(.body)

        }

    }

}

#Preview {

    SplashScreenView {}
        .withMockPreviews()

}
