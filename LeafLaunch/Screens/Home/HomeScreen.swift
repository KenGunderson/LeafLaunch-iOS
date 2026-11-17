//
//  HomeScreen.swift
//  LeafLaunch
//

import SwiftUI

struct HomeScreen: GPView {

    @Environment(NavigationService.self) private var navigationService

    @StateObject var viewModel: HomeViewModel

    var body: some View {

        RNHeaderScrollView {
            navHeader()
        } scrollViewContent: {
            EmptyView()
        }
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

    }

    @ContentBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: "Home",
            trailingNavButtons: [.settings]
        ) { _ in
            self.viewModel.presentSettings()
        }

    }

}

#Preview {

    HomeScreen(viewModel: mockResolve(HomeViewModel.self))
        .withMockServices()

}
