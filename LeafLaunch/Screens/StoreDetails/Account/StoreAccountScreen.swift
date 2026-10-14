import SwiftUI

struct StoreAccountScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: StoreAccountViewModel

    init(viewModel: StoreAccountViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {
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

    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Account"),
            trailingNavButtons: [.settings],
            trailingNavButtonsAction: { [weak viewModel] _ in viewModel?.presentSettings() }
        )

    }

    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            if self.viewModel.user == nil {

                guestPrompt()

            } else {

                profile()
                loyalty()
                pointsHistory()

                LeafLaunchButton(title: String(localized: "Refresh Account")) {
                    self.viewModel.loadData(showHud: true)
                }
                .disabled(self.viewModel.isLoading)

                Button(String(localized: "Sign Out")) {
                    self.viewModel.logout()
                }
                .disabled(self.viewModel.isLoggingOut)

            }

        }
        .appFont(with: .BODY_2)
        .foregroundStyle(.text(.body))
        .tabFlowContentSpacing()

    }

    private func guestPrompt() -> some View {

        GroupBox(String(localized: "Explore as a Guest")) {

            VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                Text(String(localized: "Browse products and save favorites. Create an account to view your profile and loyalty points."))

                LeafLaunchButton(title: String(localized: "Create Account")) {
                    self.viewModel.register()
                }

                Button(String(localized: "Sign In")) {
                    self.viewModel.login()
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    private func profile() -> some View {

        GroupBox(String(localized: "Profile")) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                Text(self.viewModel.account?.displayName ?? self.viewModel.user?.fullName ?? "")
                    .appFont(with: .TITLE_4)

                if let email = self.viewModel.user?.email, !email.isEmpty {
                    Text(email)
                }

                if let joinedAt = self.viewModel.account?.createdAt {
                    Text(String(localized: "Account created \(joinedAt.formatted(date: .abbreviated, time: .omitted))"))
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    private func loyalty() -> some View {

        GroupBox(String(localized: "Loyalty Points")) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                if let membership = self.viewModel.membership {

                    Text(String(localized: "Balance: \(membership.cachedPointsBalance) points"))
                    Text(String(localized: "Member since \(membership.joinedAt.formatted(date: .abbreviated, time: .omitted))"))

                } else if self.viewModel.hasCompletedInitialLoad && !self.viewModel.isLoading {

                    Text(String(localized: "Join this location's loyalty program to earn points."))

                    LeafLaunchButton(title: String(localized: "Join Loyalty Program")) {
                        self.viewModel.joinMembership()
                    }

                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    private func pointsHistory() -> some View {

        GroupBox(String(localized: "Points and Redemption History")) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                if self.viewModel.hasCompletedInitialLoad && self.viewModel.history.isEmpty {
                    Text(String(localized: "No points activity yet."))
                }

                ForEach(self.viewModel.history, id: \.id) { entry in

                    VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                        Text(entry.customerReason).appFont(with: .TITLE_4)
                        Text(String(localized: "\(entry.pointsDelta) points"))

                        if let rewardTitle = entry.rewardTitleSnapshot {
                            Text(rewardTitle)
                        }

                        Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                        Divider()

                    }

                }

                if self.viewModel.hasMoreHistory {

                    LeafLaunchButton(title: String(localized: "Load More History")) {
                        self.viewModel.loadMoreHistory()
                    }
                    .disabled(self.viewModel.isLoading)

                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

}

#Preview {

    StoreAccountScreen(
        viewModel: mockResolve(StoreAccountViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockServices()

}
