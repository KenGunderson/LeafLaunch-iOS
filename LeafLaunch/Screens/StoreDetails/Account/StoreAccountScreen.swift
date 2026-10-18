import SwiftUI

struct StoreAccountScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: StoreAccountViewModel

    init(viewModel: StoreAccountViewModel) {
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
            title: String(localized: "Account"),
            titleFont: .HEADER_5,
            trailingNavButtons: [.settings],
            trailingNavButtonsAction: { [weak viewModel] _ in viewModel?.presentSettings() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            if self.viewModel.user == nil {

                StoreAccountGuestView(
                    createAccountAction: { [weak viewModel] in viewModel?.register() },
                    signInAction: { [weak viewModel] in viewModel?.login() }
                )

            } else {

                account()

            }

        }
        .appFont(with: .BODY_2)
        .foregroundStyle(self.style.textColor(.body))
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func account() -> some View {

        if let user = self.viewModel.user {

            StoreAccountProfileView(user: user, account: self.viewModel.account)

        }

        if self.viewModel.hasLoadFailed {
            loadFailure()
        }

        if self.viewModel.account != nil || self.viewModel.hasCompletedInitialLoad || self.viewModel.membership != nil || !self.viewModel.hasLoadFailed {
            loyalty()
        }

        if self.viewModel.hasCompletedInitialLoad || !self.viewModel.history.isEmpty || self.viewModel.isLoading {
            pointsHistory()
        }

        accountLinks()
        signOutButton()

    }

    @ViewBuilder
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

    @ViewBuilder
    private func pointsHistory() -> some View {

        StoreAccountHistoryView(
            history: self.viewModel.history,
            isLoading: self.viewModel.isLoading,
            hasCompletedInitialLoad: self.viewModel.hasCompletedInitialLoad,
            canViewAllHistory: self.viewModel.membership != nil,
            viewAllAction: { [weak viewModel] in viewModel?.openPointsActivity() }
        )

    }

    @ViewBuilder
    private func accountLinks() -> some View {

        StoreAccountLinksView(
            locationName: self.viewModel.locationName,
            hasSelectedLocation: self.viewModel.hasSelectedLocation,
            favoritesAction: { [weak viewModel] in viewModel?.openFavorites() },
            locationAction: { [weak viewModel] in viewModel?.changeLocation() }
        )

    }

    @ViewBuilder
    private func loadFailure() -> some View {

        CommerceSurface {

            VStack(spacing: self.style.spacing(.medium)) {

                CommerceEmptyState(
                    systemImage: "arrow.clockwise",
                    title: String(localized: "Unable to load account details"),
                    message: String(localized: "Your latest membership and points activity couldn't be loaded.")
                )

                LeafLaunchButton(title: String(localized: "Try Again")) {
                    self.viewModel.loadData(showHud: false)
                }
                .disabled(self.viewModel.isLoading)

            }

        }

    }

    @ViewBuilder
    private func signOutButton() -> some View {

        Button(role: .destructive) {
            self.viewModel.logout()
        } label: {

            HStack(spacing: self.style.spacing(.small)) {

                ImageSource.systemImage("rectangle.portrait.and.arrow.right").view(shouldResize: false)
                Text(String(localized: "Sign Out"))

            }
            .appFont(with: .TITLE_3)
            .foregroundStyle(self.style.palette(.destructive))
            .padding(.vertical, self.style.spacing(.medium))
            .frame(maxWidth: .infinity)

        }
        .buttonStyle(.plain)
        .disabled(self.viewModel.isLoggingOut)

    }

}

#Preview {

    StoreAccountScreen(
        viewModel: mockResolve(StoreAccountViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
