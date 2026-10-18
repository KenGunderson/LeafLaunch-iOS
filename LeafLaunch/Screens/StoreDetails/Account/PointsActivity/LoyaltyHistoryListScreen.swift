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

        LLAppHeaderScrollView {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }
        .task { [weak viewModel] in
            viewModel?.loadData(showHud: true)
        }

    }

    @ViewBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Points Activity"),
            titleFont: .HEADER_5,
            subtitle: String(localized: "Your points and redemption history"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            loadingContent()
            loadFailure()
            emptyContent()
            activity()
            loadMoreAction()

        }
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func activity() -> some View {

        LazyVStack(spacing: self.style.spacing(.small2)) {

            ForEach(self.viewModel.history, id: \.id) { entry in
                activityRow(entry)
            }

        }

    }

    @ViewBuilder
    private func activityRow(_ entry: LoyaltyHistoryEntry) -> some View {

        CommerceSurface {
            StoreAccountHistoryRow(entry: entry)
        }

    }

    @ViewBuilder
    private func loadingContent() -> some View {

        if self.viewModel.isLoading && self.viewModel.history.isEmpty {

            CommerceSurface {

                ProgressView(String(localized: "Loading points activity"))
                    .appFont(with: .BODY_1)
                    .tint(self.style.palette(.link))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .large)

            }

        }

    }

    @ViewBuilder
    private func emptyContent() -> some View {

        if self.viewModel.hasCompletedInitialLoad && self.viewModel.history.isEmpty && !self.viewModel.isLoading && !self.viewModel.hasLoadFailed {

            CommerceSurface {

                CommerceEmptyState(
                    systemImage: "clock.arrow.circlepath",
                    title: String(localized: "No Points Activity Yet"),
                    message: String(localized: "Your points and redemptions will appear here.")
                )

            }

        }

    }

    @ViewBuilder
    private func loadFailure() -> some View {

        if self.viewModel.hasLoadFailed {

            CommerceSurface {

                VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                    Text(String(localized: "Points Activity Couldn't Load"))
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(self.style.textColor(.title))

                    Text(String(localized: "Check your connection and try again. Any loaded activity is still available below."))
                        .appFont(with: .BODY_1)
                        .foregroundStyle(self.style.textColor(.body))
                        .fixedSize(horizontal: false, vertical: true)

                    LeafLaunchButton(title: String(localized: "Try Again")) { [weak viewModel] in
                        viewModel?.retry()
                    }
                    .disabled(self.viewModel.isLoading)

                }

            }

        }

    }

    @ViewBuilder
    private func loadMoreAction() -> some View {

        if self.viewModel.hasMoreHistory && !self.viewModel.hasLoadFailed {

            CommonButton(
                style: .outline(lineWidth: 1),
                title: String(localized: "Load More History"),
                titleColor: self.style.textColor(.title),
                titleFont: .TITLE_3,
                backgroundStyle: self.style.background(.border),
                isEnabled: !self.viewModel.isLoading,
                verticalPadding: .small2,
                cornerRadius: .medium
            ) { [weak viewModel] in
                viewModel?.loadMore()
            }
            .overlay(alignment: .trailing) {

                if self.viewModel.isLoading {

                    ProgressView()
                        .tint(self.style.palette(.link))
                        .padding(.trailing, .medium)
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
