//
//  WelcomeScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI

struct WelcomeScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject var viewModel: WelcomeViewModel

    @State private var footerSize: CGSize = .zero
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation

    var body: some View {

        AppRootView(navigationService: Bindable(self.navigationService)) {

            content()
                .safeAreaInset(edge: .bottom) {
                    footer()
                }

                .onFirstAppear { [weak viewModel] in

                    viewModel?.setup(navigationService: self.navigationService)
                    viewModel?.handleFirstAppear()

                }

        }
        .appPrefersColorScheme()
        .detectRotation { orientation in
            self.orientation = orientation
        }


    }

    @ContentBuilder
    private func content() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.none)) {

            welcomeImage()

            introduction()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .runeBackground(.primary)
        .ignoresSafeArea()

    }

    @ContentBuilder
    private func welcomeImage() -> some View {

        RNImageSource.systemImage("person.fill")
            .view()
            .if(self.orientation == .landscapeLeft || self.orientation == .landscapeRight) { view in
                view.scaledToFit().runeCornerRadius(.large)
            }
            .if(self.orientation == .portrait || self.orientation == .portraitUpsideDown) { view in
                view.frame(height: Constants.Runtime.deviceHeight / 1.95)
            }
            .ignoresSafeArea()

    }

    @ContentBuilder
    private func introduction() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.content)) {

            RNImageSource.systemImage("person.fill")
                .view()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .frame(maxWidth: .infinity)

            Text("Capture photos, create before & afters, and showcase your results.")
                .runeFont(with: .BODY_4)
                .multilineTextAlignment(.center)
                .runeTextColor(.body)
                .runePadding(.horizontal, .extraLarge)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .runeBackground(.primary)
        .runePadding(.bottom, .custom(self.footerSize.height + self.style.spacing(LLSpacing.listRow)))

    }

    @ContentBuilder
    private func footer() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.listRow)) {

            signUpButton()
            loginButton()

        }
        .runePadding(.horizontal, LLSpacing.hero)
        .customSafeAreaPadding()
        .onGeometryChange(for: CGSize.self) { proxy in
            return proxy.size
        } action: { newValue in
            self.footerSize = newValue
        }

    }

    @ContentBuilder
    private func signUpButton() -> some View {

        LeafLaunchButton(
            title: "Sign Up",
            cornerRadius: .medium2,
            action: {
                self.viewModel.navigateToSignUp()
            }
        )

    }

    @ContentBuilder
    private func loginButton() -> some View {

        LeafLaunchButton(
            style: .outline(lineWidth: 3),
            title: "Login",
            titleColor: .accent,
            cornerRadius: .medium2,
            action: {
                self.viewModel.navigateToLogin()
            }
        )

    }

}

#Preview {

    WelcomeScreen(
        viewModel: mockResolve(WelcomeViewModel.self)
    )
    .withMockServices(withNaivgationService: true)

}
