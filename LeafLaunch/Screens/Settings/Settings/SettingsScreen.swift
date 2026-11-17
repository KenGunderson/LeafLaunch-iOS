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

                VStack(spacing: self.style.spacing(LLSpacing.none)) {
                    content()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

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

    @ContentBuilder
    private func navBar() -> some View {

        NavHeader(
            title: String(localized: "Settings"),
            trailingNavButtons: [.close],
            trailingNavButtonsAction: { _ in self.dismiss() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        let settings: [Route.SettingRoute] = Route.SettingRoute.allCases
        let groups = Dictionary(
            grouping: settings,
            by: { $0.category }
        )
        let categories = groups.keys.sorted()
        let config = Constants.StaggerAnimation.config(interitemSpacing: self.style.spacing(LLSpacing.groupedContent))

        RNStaggeredView(config: config) {

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

    @ContentBuilder
    private func settingsSection(category: String,
                                 settings: [Route.SettingRoute],
                                 isFirst: Bool) -> some View {

        if category == "Logout" {

            ForEach(settings, id: \.self) { setting in

                LLAppCardView(cornerRadius: .medium) {
                    settingItem(setting)
                }
                .runePadding(.top, LLSpacing.listRow)

            }

        } else {

            LLSection(
                title: category,
                headingSpacing: LLSpacing.metadata,
                contentSpacing: LLSpacing.none
            ) {

                LLAppCardView(cornerRadius: .medium) {
                    settingRows(settings)
                }

            }
            .runePadding(.top, isFirst ? LLSpacing.none : LLSpacing.listRow)

        }

    }

    @ContentBuilder
    private func settingRows(_ settings: [Route.SettingRoute]) -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.none)) {

            ForEach(settings, id: \.self) { setting in

                if setting != settings.first {
                    LLDivider()
                }

                settingItem(setting)
                    .runePadding(.vertical, LLSpacing.groupedContent)

            }

        }

    }

    @ContentBuilder
    private func settingItem(_ item: Route.SettingRoute) -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            item
                .icon
                .view(renderingMode: .template)
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: 20,
                    height: 20
                )
                .runeFont(with: .TITLE_4)
                .foregroundStyle(item.tintColor)

            Text(item.displayName)
                .runeFont(with: .TITLE_4)
                .runeTextColor(.title)
                .frame(maxWidth: .infinity, alignment: .leading)

            RNImageSource.systemImage("chevron.right")
                .view(shouldResize: false)
                .runeTextColor(.title)
                .opacity(0.5)

        }
        .contentShape(Rectangle())
        .runeAsButton {

            withAnimation(.smooth) {

                self.viewModel
                    .selectSetting(item)

            }

        }

    }

    @ContentBuilder
    private func versionItem() -> some View {

        Text(String(localized: "App Version \(self.viewModel.appVersion)"))
            .runeFont(with: .NOTE_2)
            .runeTextColor(.body)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .runePadding(.top, LLSpacing.metadata)
            .runePadding(.bottom, LLSpacing.content)

    }

}

#Preview {

    let viewModel = mockResolve(SettingsViewModel.self)

    SettingsScreen(viewModel: viewModel)
        .withMockServices(withNaivgationService: false)

}
