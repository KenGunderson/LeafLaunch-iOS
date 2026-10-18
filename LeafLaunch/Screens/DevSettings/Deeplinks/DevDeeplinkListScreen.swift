//
//  DevDeeplinkListScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI
import Charts

struct DevDeeplinkListScreen: GPView {

    @Environment(\.style) private var style

    @Environment(NavigationService.self) private var navigationService

    @StateObject var viewModel: DevDeeplinkListViewModel

    var basePath = "leaflaunch://host/"

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
            title: "Deeplink",
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

            // Tab

            section(title: "Tabs")

            route(
                title: "Tab 1",
                deeplink: "tab?tab=tab1"
            )

            route(
                title: "Tab 2",
                deeplink: "tab?tab=tab2"
            )

            route(
                title: "Tab 3",
                deeplink: "tab?tab=tab3"
            )

        }

    }

    @ViewBuilder
    private func section(title: String) -> some View {

        Group {

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(title)
                    .appFont(with: .HEADER_4)

                LLDivider()

            }

        }
        .foregroundStyle(.text(.title))

    }

    @ViewBuilder
    private func route(title: String,
                       deeplink: String) -> some View {

        LLAppCardView {

            VStack(alignment: .leading,
                   spacing: self.style.spacing(.small2)
            ) {

                Text(title)
                    .appFont(with: .TITLE_5)

                Text(deeplink)
                    .appFont(with: .TITLE_3)
                    .fontDesign(.monospaced)

            }

        }
        .foregroundStyle(.text(.title))
        .appOnTapGesture {

            if let deeplinkURL = URL(string: "\(self.basePath)\(deeplink)") {
                self.viewModel.handleDeeplink(url: deeplinkURL)
            }

        }

    }

}

#Preview {

    DevDeeplinkListScreen(
        viewModel: mockResolve(DevDeeplinkListViewModel.self)
    )
    .withMockServices()

}
