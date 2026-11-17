import SwiftUI

struct AccountDetailsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: AccountDetailsViewModel

    init(viewModel: AccountDetailsViewModel) {
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
            title: String(localized: "Account"),
            trailingNavButtons: [.settings],
            trailingNavButtonsAction: { [weak viewModel] _ in viewModel?.presentSettings() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            if self.viewModel.user == nil {

                StoreAccountGuestView(
                    createAccountAction: { [weak viewModel] in viewModel?.register() },
                    signInAction: { [weak viewModel] in viewModel?.login() }
                )

            } else {

                account()

            }

        }
        .runeFont(with: .BODY_2)
        .runeTextColor(.body)
        .tabFlowContentSpacing()

    }

    @ContentBuilder
    private func account() -> some View {

        if let user = self.viewModel.user {

            StoreAccountProfileView(
                user: user,
                account: self.viewModel.account
            )

        }

        if self.viewModel.hasLoadFailed {
            loadFailure()
        }

        let hasAccountDetails = self.viewModel.account != nil || self.viewModel.membership != nil
        let shouldShowLoyalty = hasAccountDetails || self.viewModel.hasCompletedInitialLoad || !self.viewModel.hasLoadFailed

        if shouldShowLoyalty {
            loyalty()
        }

        let shouldShowHistory = self.viewModel.hasCompletedInitialLoad || !self.viewModel.history.isEmpty || self.viewModel.isLoading

        if shouldShowHistory {
            pointsHistory()
        }

        accountLinks()

    }

    @ContentBuilder
    private func loyalty() -> some View {

        StoreAccountMembershipView(
            account: self.viewModel.account,
            membership: self.viewModel.membership,
            locationName: self.viewModel.locationName,
            hasSelectedLocation: self.viewModel.hasSelectedLocation,
            isLoading: self.viewModel.isLoading,
            hasCompletedInitialLoad: self.viewModel.hasCompletedInitialLoad,
            joinAction: { [weak viewModel] in viewModel?.joinMembership() }
        )

    }

    @ContentBuilder
    private func pointsHistory() -> some View {

        StoreAccountHistoryView(
            history: self.viewModel.history,
            isLoading: self.viewModel.isLoading,
            hasCompletedInitialLoad: self.viewModel.hasCompletedInitialLoad,
            canViewAllHistory: self.viewModel.membership != nil,
            viewAllAction: { [weak viewModel] in viewModel?.openPointsActivity() }
        )

    }

    @ContentBuilder
    private func accountLinks() -> some View {

        StoreAccountLinksView(
            locationName: self.viewModel.locationName,
            hasSelectedLocation: self.viewModel.hasSelectedLocation,
            favoritesAction: { [weak viewModel] in viewModel?.openFavorites() },
            locationAction: { [weak viewModel] in viewModel?.changeLocation() }
        )

    }

    @ContentBuilder
    private func loadFailure() -> some View {

        CommerceSurface {

            VStack(spacing: self.style.spacing(LLSpacing.listRow)) {

                CommerceEmptyState(
                    systemImage: "arrow.clockwise",
                    title: String(localized: "Unable To Load Account Details"),
                    message: String(localized: "Your latest membership and points activity couldn't be loaded.")
                )

                LeafLaunchButton(title: String(localized: "Try Again")) {
                    self.viewModel.loadData(showHud: false)
                }
                .disabled(self.viewModel.isLoading)

            }

        }

    }

}

#Preview {

    AccountDetailsScreen(
        viewModel: mockResolve(AccountDetailsViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
