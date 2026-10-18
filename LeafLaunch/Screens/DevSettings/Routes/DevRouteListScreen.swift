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

    @ViewBuilder
    private func headerView() -> some View {

        NavBarView(
            title: "Routes",
            subtitle: "Warp To Anywhere In The App!",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(spacing: self.style.spacing(.medium)) {

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

    @ViewBuilder
    private func section(title: String) -> some View {

        Group {

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(title)
                    .appFont(with: .HEADER_4)
                    .foregroundStyle(.text(.title))

                LLDivider()

            }

        }

    }

    @ViewBuilder
    private func route(title: String,
                       fullScreenCover: FullScreenCover) -> some View {

        LLAppCardView {

            Text(title)
                .appFont(with: .TITLE_5)
                .foregroundStyle(.text(.title))

        }
        .appOnTapGesture {

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
