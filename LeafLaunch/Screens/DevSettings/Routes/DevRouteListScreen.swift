//
//  DevRouteListScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI

struct DevRouteListScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject var viewModel: DevRouteListViewModel

    var body: some View {

        LLAppHeaderScrollView {

            headerView()

        } scrollViewContent: {

            content()

        }

        // Lifecycle

        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

    }

    @ContentBuilder
    private func headerView() -> some View {

        NavHeader(
            title: "Routes",
            subtitle: "Warp To Anywhere In The App!",
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.listRow)) {

            // Full Screen Covers

            section(title: "Full Screen")

            route(
                title: "Settings",
                fullScreenCover: .settings
            )

            route(
                title: "Dev Settings",
                fullScreenCover: .devSettings
            )

        }

    }

    @ContentBuilder
    private func section(title: String) -> some View {

        Group {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.metadata)
            ) {

                Text(title)
                    .runeFont(with: LeafLaunchThemeTokens.headingFont)
                    .runeTextColor(.title)

                LLDivider()

            }

        }

    }

    @ContentBuilder
    private func route(title: String,
                       fullScreenCover: FullScreenCover) -> some View {

        LLAppCardView {

            Text(title)
                .runeFont(with: .TITLE_5)
                .runeTextColor(.title)

        }
        .runeOnTapGesture {

            self.viewModel
                .present(modal: fullScreenCover)

        }

    }

}

#Preview {

    DevRouteListScreen(
        viewModel: mockResolve(DevRouteListViewModel.self)
    )
    .withMockServices()

}
