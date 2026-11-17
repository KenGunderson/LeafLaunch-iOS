//
//  SettingsScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 6/21/25.
//

import SwiftUI
import StoreKit

struct SettingsScreen: GPView {

    @Environment(\.style) private var style

    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview

    @StateObject var viewModel: SettingsViewModel
    @State private var navigationService = NavigationService()

    var body: some View {

        AppRootView(navigationService: self.$navigationService) {

            LLAppHeaderScrollView {
                navBar()
            } scrollViewContent: {

                VStack(spacing: 0) {
                    content()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

            }

            // Lifecycle

            .onFirstAppear { [weak viewModel] in

                viewModel?.setup(navigationService: self.navigationService)
                viewModel?.handleFirstAppear()

            }


            // OnChange

            .onChange(of: self.viewModel.shouldDismiss) { _, newValue in

                guard newValue else { return }
                self.dismiss()

            }

            .onChange(of: self.viewModel.shouldShowRateAppAlert) { oldValue, newValue in

                guard newValue else { return }
                self.requestReview()

            }

            // Mail Composer

            .emailComposer(
                isPresented: self.$viewModel.shouldShowMailComposer,
                emailData: self.viewModel.emailData
            )

        }

    }

    @ViewBuilder
    private func navBar() -> some View {

        NavHeader(
            title: String(localized: "Settings"),
            trailingNavButtons: [.close],
            trailingNavButtonsAction: { _ in self.dismiss() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        let settings: [Route.SettingRoute] = Route.SettingRoute.allCases
        let groups = Dictionary(grouping: settings, by: { $0.category })
        let categories = groups.keys.sorted()
        let config = Constants.StaggerAnimation.config(interitemSpacing: self.style.spacing(.small))

        StaggeredView(config: config) {

            ForEach(categories, id: \.self) { category in

                settingsSection(
                    category: category,
                    settings: groups[category] ?? [],
                    isFirst: category == categories.first
                )

            }

            versionItem()

        }

    }

    @ViewBuilder
    private func settingsSection(category: String,
                                  settings: [Route.SettingRoute],
                                  isFirst: Bool) -> some View {

        let isLogout = category == "Logout"

        if !isLogout {

            SectionView(leadingTitle: category.capitalized)
                .padding(.bottom, .extraSmall)
                .padding(.top, isFirst ? .none : .medium)

        }

        ForEach(settings, id: \.self) { setting in

            settingItem(setting)
                .padding(.top, isLogout ? .medium : .none)

        }

    }

    @ViewBuilder
    private func settingItem(_ item: Route.SettingRoute) -> some View {

        LLAppCardView(cornerRadius: .medium) {

            HStack(spacing: self.style.spacing(.small)) {

                item
                    .icon
                    .view(renderingMode: .template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(item.tintColor)

                Text(item.displayName)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(.text(.title))
                    .frame(maxWidth: .infinity, alignment: .leading)

                ImageSource.systemImage("chevron.right")
                    .view(shouldResize: false)
                    .foregroundStyle(.text(.title))
                    .opacity(0.5)

            }

        }
        .asButton {

            withAnimation(.smooth) {

                self.viewModel
                    .selectSetting(item)

            }

        }

    }

    @ViewBuilder
    private func versionItem() -> some View {

        Text(String(localized: "App Version \(self.viewModel.appVersion)"))
            .appFont(with: .NOTE_2)
            .foregroundStyle(.text(.body))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, .extraSmall)
            .padding(.bottom, .large)

    }

}

#Preview {

    let viewModel = mockResolve(SettingsViewModel.self)

    SettingsScreen(viewModel: viewModel)
        .withMockServices(withNaivgationService: false)

}
