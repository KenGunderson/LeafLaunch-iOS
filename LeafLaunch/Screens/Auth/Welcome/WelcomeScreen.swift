//
//  WelcomeScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI

struct WelcomeScreen: GPView {

    @Environment(\.style) private var style

    @StateObject var viewModel: WelcomeViewModel
    @Environment(NavigationService.self) private var navigationService

    @State private var footerSize: CGSize = .zero
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation

    var body: some View {

        AppRootView(navigationService: Bindable(self.navigationService)) {

            content
                .safeAreaInset(edge: .bottom) {
                    footer
                }

                .onFirstAppear { [weak viewModel] in

                    viewModel?
                        .handleFirstAppear()

                }

        }
        .appPrefersColorScheme()
        .detectRotation { orientation in
            self.orientation = orientation
        }
        .task { [weak viewModel] in

            viewModel?
                .setup(navigationService: self.navigationService)

        }

    }

    var content: some View {

        VStack(spacing: self.style.spacing(.none)) {

            Image(systemName: "person.fill")
                .resizable()
                .if(self.orientation == .landscapeLeft || self.orientation == .landscapeRight) { view in
                    view.scaledToFit().cornerRadius(.large)
                }
                .if(self.orientation == .portrait || self.orientation == .portraitUpsideDown) { view in
                    view.frame(height: Constants.Runtime.deviceHeight / 1.95)
                }
                .ignoresSafeArea()

            VStack(spacing: self.style.spacing(.large)) {

                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)

                Text("Capture photos, create before & afters, and showcase your results.")
                    .appFont(with: .BODY_4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.text(.body))
                    .padding(.horizontal, .extraLarge)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(.background(.primary))
            .padding(.bottom, self.footerSize.height + self.style.spacing(.medium))

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.background(.primary))
        .ignoresSafeArea()

    }

    var footer: some View {

        VStack(spacing: 16) {

            signUpButton
            loginButton

        }
        .padding(.horizontal, 32)
        .customSafeAreaPadding()
        .onGeometryChange(for: CGSize.self) { proxy in
            return proxy.size
        } action: { newValue in
            self.footerSize = newValue
        }

    }

    var signUpButton: some View {

        CommonButton(
            title: "Sign Up",
            titleColor: .text(.button),
            action: {
                self.viewModel.navigateToSignUp()
            })

    }

    var loginButton: some View {

        CommonButton(
            style: .outline(lineWidth: 3),
            title: "Login",
            titleColor: .foreground(.primary),
            action: {
                self.viewModel.navigateToLogin()
            })

    }

}

#Preview {

    WelcomeScreen(
        viewModel: mockResolve(WelcomeViewModel.self)
    )
    .withMockServices(withNaivgationService: true)

}
