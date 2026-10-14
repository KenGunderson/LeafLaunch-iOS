//
//  RootView.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import SwiftUI
import FactoryKit

struct RootScreen: GPView {

    @Environment(\.style) private var style

    @StateObject private var viewModel: RootViewModel
    @State private var navigationService = NavigationService()

    init(viewModel: RootViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        ZStack {

            backgroundView()
            mainView()
            splashScreenView()

        }
        .environment(self.navigationService)
        .appPrefersColorScheme()

        // Lifecycle

        .onFirstAppear { [weak viewModel] in

            viewModel?.setNavigationService(self.navigationService)
            viewModel?.track()
            globalNavigationService = self.navigationService

        }

        .task { [weak viewModel] in
            viewModel?.loadData()
        }

        // Deeplinks

        .onOpenURL { url in
            self.viewModel.setDeeplink(url: url)
        }
        // Full Screen Cover

        .fullScreenCover(isPresented: self.$viewModel.shouldPresentDevSettings) {

            let viewModel = Container.shared.devSettingsViewModel()
            DevSettingsScreen(viewModel: viewModel)

        }

    }

    private func backgroundView() -> some View {

        self.style
            .background(.primary)
            .view()
            .ignoresSafeArea()

    }

    private func mainView() -> some View {

        GeometryReader { _ in

            VStack(spacing: self.style.spacing(.none)) {

                if self.viewModel.launchState == .completed {

                    MainScreen(viewModel: self.viewModel.mainViewModel)
                        .restrictCapture(self.viewModel.userDefaultsService.shouldHideScreenshots)

                }

            }

        }

    }

    private func splashScreenView() -> some View {

        SplashScreenView {

            self.viewModel
                .markSplashAnimationCompleted()

        }
        .opacity(self.viewModel.launchState == .completed ? 0 : 1)
        .allowsHitTesting(self.viewModel.launchState != .completed)
        .animation(.smooth(duration: 0.6), value: viewModel.launchState)
        .onFirstAppear { [weak viewModel] in

            viewModel?
                .trackLauchScreen()

        }

    }

}

#Preview {

    RootScreen(
        viewModel: mockResolve(RootViewModel.self)
    )
    .withMockServices()

}
