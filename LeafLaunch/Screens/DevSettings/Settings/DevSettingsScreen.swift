//
//  DevSettingsScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI

struct DevSettingsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DevSettingsViewModel
    @State private var navigationService = NavigationService()
    @State private var shouldShowComponentsView: Bool = false

    init(viewModel: DevSettingsViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {

        AppRootView(navigationService: self.$navigationService) {

            LLAppHeaderScrollView {

                navBarView()

            } scrollViewContent: {

                content()

            }
            // Lifecycle

            .onFirstAppear { [weak viewModel] in

                viewModel?.setup(
                    navigationService: self.navigationService,
                    dismissAction: {
                        dismiss()
                    }
                )
                viewModel?.handleFirstAppear()

            }

            // OnChange

            .onChange(of: self.viewModel.selectedEnviornment!) { oldValue, newValue in
                self.viewModel.set(environment: newValue)
            }

            // Full Screen Cover
            .fullScreenCover(isPresented: self.$shouldShowComponentsView) {
                RNDemoView()
            }

        }

    }

    @ContentBuilder
    private func navBarView() -> some View {

        NavHeader(
            title: "Dev Settings",
            trailingNavButtons: [.close],
            trailingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.content)) {

            informationSection()
            diagnosticsSection()
            routeSection()

        }
        .frame(maxWidth: .infinity)
        .animation(
            .smooth(duration: 0.4),
            value: self.viewModel.selectedEnviornment
        )

    }

    @ContentBuilder
    private func informationSection() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            Text("Information")
                .runeFont(with: LeafLaunchThemeTokens.headingFont)
                .runeTextColor(.title)

            LLAppCardView {

                VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                    environmentControls()

                    lineItemView(
                        title: "Host",
                        subtitle: Constants.URLs.urlForEnvironment(self.viewModel.selectedEnviornment!)
                    )
                    .runePadding(.bottom, LLSpacing.listRow)

                    lineItemView(
                        title: "Name",
                        subtitle: self.viewModel.user?.fullName ?? ""
                    )

                    lineItemView(
                        title: "User Id",
                        subtitle: self.viewModel.user?.id ?? ""
                    )

                    copyAuthTokenAction()

                }

            }

        }
        .frame(maxWidth: .infinity)

    }

    @ContentBuilder
    private func diagnosticsSection() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            Text("Diagnostics")
                .runeFont(with: LeafLaunchThemeTokens.headingFont)
                .runeTextColor(.title)

            LLAppCardView {

                VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                    lineItemView(
                        title: "Version",
                        subtitle: self.viewModel.appVersion
                    )

                    lineItemView(
                        title: "Build",
                        subtitle: self.viewModel.buildNumber
                    )

                    lineItemView(
                        title: "Bundle Id",
                        subtitle: self.viewModel.bundleIdentifier
                    )

                    lineItemView(
                        title: "Environment",
                        subtitle: self.viewModel.currentEnvironmentName
                    )

                    lineItemView(
                        title: "Device Id",
                        subtitle: self.viewModel.deviceId
                    )

                    lineItemView(
                        title: "FCM Registration Token",
                        subtitle: self.viewModel.pushToken
                    )

                    lineItemView(
                        title: "User Email",
                        subtitle: self.viewModel.currentUserEmail
                    )

                }

            }

        }
        .frame(maxWidth: .infinity)

    }

    @ContentBuilder
    private func routeSection() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            Text("Sections")
                .runeFont(with: LeafLaunchThemeTokens.headingFont)
                .runeTextColor(.title)

            VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                listSectionItemView(
                    title: "Components",
                    icon: "wrench.and.screwdriver.fill"
                )
                .runeAsButton {
                    self.shouldShowComponentsView = true
                }

                ForEach(Route.DevSettingRoute.allCases, id: \.rawValue) { route in

                    routeRow(route)

                }

                if self.viewModel.firebaseService.user != nil {

                    listSectionItemView(
                        title: "Logout",
                        icon: "person.fill",
                        colorOverride: .palette(.error)
                    )
                    .runeAsButton {

                        self.viewModel
                            .logout()

                    }

                }

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    func lineItemView(title: String,
                      subtitle: String) -> some View {

        HStack(
            alignment: .top,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            Text(title + ": ")
                .runeFont(with: .TITLE_3)

            Text(subtitle)
                .runeFont(with: .BODY_2)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)

        }
        .runeTextColor(.title)

    }

    @ContentBuilder
    func listSectionItemView(title: String,
                             icon: String,
                             colorOverride: RNColorSource = .foreground(.primary)) -> some View {

        LLAppCardView {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                Label(
                    title,
                    systemImage: icon
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                RNImageSource.systemImage("chevron.right")
                    .view(shouldResize: false)

            }
            .foregroundStyle(colorOverride)

        }

    }

    @ContentBuilder
    private func environmentControls() -> some View {

        LLSegmentedControl(
            selectedOption: self.$viewModel.selectedEnviornment,
            options: self.viewModel.getAppEnviornments(),
            selectedTextColor: .text(.titleInverted)
        )
        .runePadding(.bottom, LLSpacing.groupedContent)

        customEnvironmentField()

    }

    @ContentBuilder
    private func copyAuthTokenAction() -> some View {

        Text("Copy Auth Token")
            .runeFont(with: .TITLE_5)
            .runeTextColor(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .runePadding(.horizontal, LLSpacing.groupedContent)
            .runePadding(.vertical, LLSpacing.listRow)
            .background(.backgroundTappable)
            .background {

                RoundedRectangle(cornerRadius: self.style.radius(.small))
                    .stroke(
                        .background(.tertiary),
                        lineWidth: 2
                    )

            }
            .runeAsButton {
                self.viewModel.copyAuthTokenToNotepad()
            }
            .runePadding(.top, LLSpacing.groupedContent)

    }

    @ContentBuilder
    private func routeRow(_ route: Route.DevSettingRoute) -> some View {

        listSectionItemView(
            title: route.displayName,
            icon: route.icon
        )
        .runeAsButton {

            self.viewModel
                .navigate(to: route.routeForDevSetting)

        }

    }

    @ContentBuilder
    private func customEnvironmentField() -> some View {

        if case .custom = self.viewModel.selectedEnviornment {

            TextField(
                "Title",
                text: self.$viewModel.customAPIEnviornmentPath
            )
                .runeFont(with: .TITLE_3)
                .runeTextColor(.title)
                .runePadding(LLSpacing.groupedContent)
                .overlay {

                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color(uiColor: .lightGray),
                            lineWidth: 1.5
                        )

                }
                .onSubmit { [weak viewModel] in

                    let customEnv: AppEnvironment = .custom(address: viewModel?.customAPIEnviornmentPath ?? "")
                    viewModel?.set(environment: customEnv)

                }
                .transition(
                    .move(edge: .top).combined(with: .opacity)
                )
                .runePadding(.bottom, LLSpacing.groupedContent)

        }

    }

}

#Preview {

    DevSettingsScreen(
        viewModel: mockResolve(DevSettingsViewModel.self)
    )
    .withMockServices(withNaivgationService: false)

}
