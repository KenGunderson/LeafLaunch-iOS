//
//  DevUserDefaultsScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI
import Charts

struct DevUserDefaultsScreen: GPView {

    @Environment(\.style) private var style

    @Environment(NavigationService.self) private var navigationService

    @StateObject var viewModel: DevUserDefaultsViewModel

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
            title: "User Defaults",
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

            sectionView(
                title: "Flags",
                contentView: flags()
            )

            sectionView(
                title: "Simulations",
                contentView: simulations()
            )

            sectionView(
                title: "Data",
                contentView: data()
            )

        }
        .appFont(with: .BODY_4)
        .onTapGesture {
            self.dismissKeyboard()
        }

    }

    @ViewBuilder
    private func flags() -> some View {

        Group {

            Toggle("didRateMyAppAlertShow", isOn: self.$viewModel.didRateMyAppAlertShow)
            Toggle("shouldHideScreenshots", isOn: self.$viewModel.shouldHideScreenshots)

            HStack {

                TokenView(
                    text: "Reset Flags",
                    foregroundStyle: .color(.white),
                    backgroundStyle: .color(.red)
                )
                .asButton {
                    self.viewModel.resetDevFlags()
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    @ViewBuilder
    private func data() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            outlineView(
                title: "Themes",
                contentView: themeChoicesView()
            )

        }

    }

    @ViewBuilder
    private func simulations() -> some View {

        Toggle("No Network", isOn: self.$viewModel.shouldShowNoNetworkError)
        Toggle("Force Update", isOn: self.$viewModel.shouldShowForceUpdateError)
        Toggle("Health Check", isOn: self.$viewModel.shouldShowHealthCheckError)

    }

    @ViewBuilder
    private func sectionView(title: String,
                             contentView: some View) -> some View {

        LLAppCardView {

            VStack(alignment: .leading) {

                Text(title)
                    .appFont(with: .TITLE_5)
                    .fontWeight(.heavy)

                contentView

            }
            .foregroundStyle(.text(.title))

        }

    }

    @ViewBuilder
    private func outlineView(title: String,
                             contentView: some View) -> some View {

        VStack(alignment: .leading, spacing: 0) {

            HStack(spacing: 0) {

                VStack(alignment: .leading) {

                    Text(title)
                        .appFont(with: .TITLE_5)
                        .fontWeight(.heavy)
                        .padding(.horizontal, self.style.spacing(.medium))

                    contentView

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, .medium)

            }

        }
        .cornerRadius(self.style.radius(.small2))
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.small2))
                .stroke(.background(.tertiary))

        }

    }

    @ViewBuilder
    private func themeChoicesView() -> some View {

        let selectedTheme = self.viewModel.theme

        VStack(alignment: .leading,
                      spacing: self.style.spacing(.small)) {

            HStack(spacing: self.style.spacing(.none)) {

                Text("Selected Theme: ")
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(.text(.body))

                Text(selectedTheme?.displayName ?? "N/A")
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(.text(.body))

                Circle()
                    .fill(selectedTheme?.theme().foreground.primary ?? .color(.red))
                    .frame(width: 32, height: 32)
                    .padding(.horizontal, .small)

            }
            .padding(.horizontal, .medium)

            ScrollView(.horizontal) {

                HStack(spacing: self.style.spacing(.medium)) {

                    ForEach(AvailableTheme.allCases, id: \.self) { themeChoice in

                        themeChoiceView(themeChoice)
                            .asButton {

                                withAnimation(.bouncy) {

                                    self.viewModel
                                        .set(theme: themeChoice)

                                }

                            }

                    }

                }
                .padding(.horizontal, self.style.spacing(.medium))

            }

        }

    }

    @ViewBuilder
    func themeChoiceView(_ themeChoice: AvailableTheme) -> some View {

        VStack {

            Text(themeChoice.displayName)
                .appFont(with: .TITLE_5)
                .fontWeight(.heavy)

            Circle()
                .fill(themeChoice.theme().foreground.primary)
                .frame(width: 64, height: 64)

        }

    }

}

#Preview {

    DevUserDefaultsScreen(
        viewModel: mockResolve(DevUserDefaultsViewModel.self)
    )
    .withMockServices()

}
