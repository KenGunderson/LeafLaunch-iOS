//
//  MainScreen.swift
//  LeafLaunch
//

import SwiftUI

struct MainScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject var viewModel: MainViewModel

    var body: some View {

        ZStack {

            self.style.background(.primary).view().ignoresSafeArea()

            if self.viewModel.showShouldHomeScreen {

                AppRootView(navigationService: Bindable(self.navigationService)) {
                    HomeScreen(viewModel: self.viewModel.homeViewModel)
                }

            }

            if self.viewModel.shouldShowWelcomeScreen {
                WelcomeScreen(viewModel: self.viewModel.welcomeViewModel)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .withWindowToastOverlay()
        .withWindowAlertService(.init(alertService: self.viewModel.readOnlyAlertService))
        .withWindowDynamicIslandService()
        .withDevSettingsOverlay(isEnabled: self.viewModel.isDevSettingsEnabled) {
            self.navigationService.modal(fullScreenCover: .devSettings)
        }
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

    }

}

#Preview {

    MainScreen(viewModel: mockResolve(MainViewModel.self))
        .withMockServices()

}
