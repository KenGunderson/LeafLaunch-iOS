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

    @ContentBuilder
    private func headerView() -> some View {

        NavHeader(
            title: "User Defaults",
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.listRow)) {

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
        .runeFont(with: .BODY_4)
        .onTapGesture {
            self.dismissKeyboard()
        }

    }

    @ContentBuilder
    private func flags() -> some View {

        Group {

            Toggle(
                "didRateMyAppAlertShow",
                isOn: self.$viewModel.didRateMyAppAlertShow
            )
            Toggle(
                "shouldHideScreenshots",
                isOn: self.$viewModel.shouldHideScreenshots
            )

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                RNTokenView(
                    text: "Reset Flags",
                    foregroundStyle: .color(.white),
                    backgroundStyle: .color(.red)
                )
                .runeAsButton {
                    self.viewModel.resetDevFlags()
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    @ContentBuilder
    private func data() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.listRow)
        ) {

            outlineView(
                title: "Themes",
                contentView: themeChoicesView()
            )

        }

    }

    @ContentBuilder
    private func simulations() -> some View {

        Toggle(
            "No Network",
            isOn: self.$viewModel.shouldShowNoNetworkError
        )
        Toggle(
            "Force Update",
            isOn: self.$viewModel.shouldShowForceUpdateError
        )
        Toggle(
            "Health Check",
            isOn: self.$viewModel.shouldShowHealthCheckError
        )

    }

    @ContentBuilder
    private func sectionView(title: String,
                             contentView: some View) -> some View {

        LLAppCardView {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                Text(title)
                    .runeFont(with: LeafLaunchThemeTokens.headingFont)

                contentView

            }
            .runeTextColor(.title)

        }

    }

    @ContentBuilder
    private func outlineView(title: String,
                             contentView: some View) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.none)
        ) {

            HStack(spacing: self.style.spacing(LLSpacing.none)) {

                VStack(
                    alignment: .leading,
                    spacing: self.style.spacing(LLSpacing.groupedContent)
                ) {

                    Text(title)
                        .runeFont(with: LeafLaunchThemeTokens.headingFont)
                        .runePadding(.horizontal, LLSpacing.pageInset)

                    contentView

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .runePadding(.vertical, LLSpacing.listRow)

            }

        }
        .runeCornerRadius(.small2)
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.small2))
                .stroke(.background(.tertiary))

        }

    }

    @ContentBuilder
    private func themeChoicesView() -> some View {

        let selectedTheme = self.viewModel.theme

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            HStack(spacing: self.style.spacing(LLSpacing.none)) {

                Text("Selected Theme: ")
                    .runeFont(with: .TITLE_3)
                    .runeTextColor(.body)

                Text(selectedTheme?.displayName ?? "N/A")
                    .runeFont(with: .TITLE_3)
                    .runeTextColor(.body)

                Circle()
                    .runeFill(selectedTheme?.theme().foreground.primary ?? .color(.red))
                    .frame(
                        width: 32,
                        height: 32
                    )
                    .runePadding(.horizontal, LLSpacing.groupedContent)

            }
            .runePadding(.horizontal, LLSpacing.pageInset)

            ScrollView(.horizontal) {

                HStack(spacing: self.style.spacing(LLSpacing.listRow)) {

                    ForEach(AvailableTheme.allCases, id: \.self) { themeChoice in

                        themeChoiceView(themeChoice)
                            .runeAsButton {

                                withAnimation(.bouncy) {

                                    self.viewModel
                                        .set(theme: themeChoice)

                                }

                            }

                    }

                }
                .runePadding(.horizontal, LLSpacing.pageInset)

            }

        }

    }

    @ContentBuilder
    func themeChoiceView(_ themeChoice: AvailableTheme) -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            Text(themeChoice.displayName)
                .runeFont(with: .TITLE_5)
                .fontWeight(.heavy)

            Circle()
                .runeFill(themeChoice.theme().foreground.primary)
                .frame(
                    width: 64,
                    height: 64
                )

        }

    }

}

#Preview {

    DevUserDefaultsScreen(
        viewModel: mockResolve(DevUserDefaultsViewModel.self)
    )
    .withMockServices()

}
