//
//  DevSettingsDeeplinkView.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI
import Charts

struct DevDeeplinksScreen: GPView {

    @Environment(\.style) private var style

    @StateObject var viewModel: DevDeeplinksViewModel
    @Environment(NavigationService.self) private var navigationService

    var basePath = "leaflaunch://host/"

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
            title: "Deeplink",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )

    }

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

            route(
                title: "Tab 4",
                deeplink: "tab?tab=tab4"
            )

        }

    }

    private func section(title: String) -> some View {

        Group {

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(title)
                    .appFont(with: .HEADER_4)

                Divider()

            }

        }
        .foregroundStyle(.text(.title))

    }

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

    DevDeeplinksScreen(
        viewModel: mockResolve(DevDeeplinksViewModel.self)
    )
    .withMockServices()

}
