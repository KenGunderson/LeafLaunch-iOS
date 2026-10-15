//
//  DevRoutesScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI

struct DevRoutesScreen: GPView {

    @Environment(\.style) private var style

    @StateObject var viewModel: DevRoutesViewModel
    @Environment(NavigationService.self) private var navigationService

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {

            headerView()

        } scrollViewContent: {

            content()

        }

        // Lifecycle

        .onFirstAppear { [weak viewModel] in

            viewModel?
                .handleFirstAppear()

            viewModel?
                .setup(navigationService: self.navigationService)

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

    private func section(title: String) -> some View {

        Group {

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(title)
                    .appFont(with: .HEADER_4)
                    .foregroundStyle(.text(.title))

                Divider()
                    .background(.background(.quaternary))

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

    DevRoutesScreen(
        viewModel: mockResolve(DevRoutesViewModel.self)
    )
    .withMockServices()

}
