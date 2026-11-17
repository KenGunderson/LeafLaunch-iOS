//
//  LoyaltyHistoryListScreen.swift
//  LeafLaunch
//
//  Created by KC Gunderson on 10/17/26.
//

import SwiftUI

struct LoyaltyHistoryListScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: LoyaltyHistoryListViewModel

    init(viewModel: LoyaltyHistoryListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        LLAppHeaderScrollView(onRefresh: { [weak viewModel] in await viewModel?.refreshData() }) {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }
        .task { [weak viewModel] in
            viewModel?.loadData(showHud: self.viewModel.isFirstLoad)
        }

    }

    @ContentBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Points Activity"),
            subtitle: String(localized: "Your Points And Redemption History"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            loadingContent()
            loadFailure()
            emptyContent()
            activity()
            loadMoreAction()

        }
        .tabFlowContentSpacing()

    }

    @ContentBuilder
    private func activity() -> some View {

        LazyVStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            ForEach(self.viewModel.history, id: \.id) { entry in
                activityRow(entry)
            }

        }

    }

    @ContentBuilder
    private func activityRow(_ entry: LoyaltyHistoryEntry) -> some View {

        CommerceSurface {
            StoreAccountHistoryRow(entry: entry)
        }

    }

    @ContentBuilder
    private func loadingContent() -> some View {

        if self.viewModel.isLoading && self.viewModel.history.isEmpty {

            CommerceSurface {

                ProgressView(String(localized: "Loading Points Activity"))
                    .runeFont(with: .BODY_1)
                    .tint(RNColorSource.palette(.link))
                    .frame(maxWidth: .infinity)
                    .runePadding(.vertical, LLSpacing.content)

            }

        }

    }

    @ContentBuilder
    private func emptyContent() -> some View {

        if self.viewModel.hasCompletedInitialLoad && self.viewModel.history.isEmpty {

            CommerceSurface {

                CommerceEmptyState(
                    systemImage: "clock.arrow.circlepath",
                    title: String(localized: "No Points Activity Yet"),
                    message: String(localized: "Your points and redemptions will appear here.")
                )

            }

        }

    }

    @ContentBuilder
    private func loadFailure() -> some View {

        if self.viewModel.hasLoadFailed {

            CommerceSurface {

                VStack(
                    alignment: .leading,
                    spacing: self.style.spacing(LLSpacing.cardContent)
                ) {

                    Text(String(localized: "Points Activity Couldn't Load"))
                        .runeFont(with: .TITLE_3)
                        .runeTextColor(.title)

                    Text(String(localized: "Check your connection and try again. Any loaded activity is still available below."))
                        .runeFont(with: .BODY_1)
                        .runeTextColor(.body)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    LeafLaunchButton(title: String(localized: "Try Again")) { [weak viewModel] in
                        viewModel?.retry()
                    }
                    .disabled(self.viewModel.isLoading)

                }

            }

        }

    }

    @ContentBuilder
    private func loadMoreAction() -> some View {

        if self.viewModel.hasMoreHistory && !self.viewModel.hasLoadFailed {

            LeafLaunchButton(
                style: .outline(lineWidth: 1),
                title: String(localized: "Load More History"),
                titleColor: RNColorSource.text(.title),
                titleFont: .TITLE_3,
                backgroundStyle: RNColorSource.background(.border),
                isEnabled: !self.viewModel.isLoading,
                verticalPadding: .small2,
                cornerRadius: .medium
            ) { [weak viewModel] in
                viewModel?.loadMore()
            }
            .overlay(alignment: .trailing) {

                if self.viewModel.isLoading {

                    ProgressView()
                        .tint(RNColorSource.palette(.link))
                        .runePadding(.trailing, LLSpacing.pageInset)
                        .allowsHitTesting(false)

                }

            }

        }

    }

}

#Preview {

    LoyaltyHistoryListScreen(
        viewModel: mockResolve(LoyaltyHistoryListViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
