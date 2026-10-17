import SwiftUI

struct StoreOverviewScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: StoreOverviewViewModel

    init(viewModel: StoreOverviewViewModel) {
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
        NavHeader(title: self.viewModel.store?.name ?? String(localized: "Store"))
    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large2)) {

            location()

            promotions()
            events()

            information()
            reloadAction()

        }
        .foregroundStyle(.text(.body))
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func location() -> some View {

        if let details = self.viewModel.locationDetails {

            StoreLocationCard(details: details) {
                self.viewModel.changeLocation()
            }

        } else {

            LeafLaunchButton(
                title: String(localized: "Change Location"),
                icon: .systemImage("mappin.and.ellipse")
            ) {
                self.viewModel.changeLocation()
            }

        }

    }

    @ViewBuilder
    private func information() -> some View {

        if self.viewModel.store != nil || self.viewModel.locationDetails != nil {

            StoreInformationCard(
                store: self.viewModel.store,
                details: self.viewModel.locationDetails
            )

        }

    }

    @ViewBuilder
    private func reloadAction() -> some View {

        if !self.viewModel.hasCompletedInitialLoad && !self.viewModel.isLoading {

            LeafLaunchButton(
                title: String(localized: "Reload Store"),
                icon: .systemImage("arrow.clockwise")
            ) {
                self.viewModel.loadData(showHud: true)
            }

        }

    }

    @ViewBuilder
    private func promotions() -> some View {

        if !self.viewModel.promotions.isEmpty {

            VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                CommerceSectionHeader(
                    title: String(localized: "In the spotlight"),
                    subtitle: String(localized: "Promotions from your store.")
                )

                ForEach(self.viewModel.promotions) { promotion in

                    promotionRow(promotion)

                }

            }

        } else if self.viewModel.hasCompletedInitialLoad && !self.viewModel.isLoading {

            CommerceEmptyState(
                systemImage: "tag",
                title: String(localized: "No current promotions"),
                message: String(localized: "Check back for the latest from your store.")
            )

        }

    }

    @ViewBuilder
    private func promotionRow(_ promotion: Promotion) -> some View {

        StorePromotionCard(
            promotion: promotion,
            location: self.viewModel.locationDetails?.location,
            onSelectProduct: self.viewModel.openProduct
        )

    }

    @ViewBuilder
    private func eventRow(_ event: StoreEvent) -> some View {

        StoreEventCard(event: event, location: self.viewModel.locationDetails?.location)

    }

    @ViewBuilder
    private func events() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            CommerceSectionHeader(
                title: String(localized: "At your store"),
                subtitle: String(localized: "Upcoming events and local happenings.")
            )

            if self.viewModel.hasCompletedInitialLoad && !self.viewModel.isLoading && self.viewModel.events.isEmpty {

                CommerceEmptyState(
                    systemImage: "calendar",
                    title: String(localized: "No upcoming events"),
                    message: String(localized: "New events will appear here when announced.")
                )

            }

            ForEach(self.viewModel.events) { event in

                eventRow(event)

            }

            if self.viewModel.hasMoreEvents {

                LeafLaunchButton(
                    title: String(localized: "Load More Events"),
                    icon: .systemImage("arrow.down")
                ) {
                    self.viewModel.loadMoreEvents()
                }
                .disabled(self.viewModel.isLoadingEvents || self.viewModel.isLoading)

            }

        }

    }

}

#Preview {

    StoreOverviewScreen(
        viewModel: mockResolve(StoreOverviewViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
