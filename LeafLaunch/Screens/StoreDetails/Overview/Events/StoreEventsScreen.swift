import SwiftUI

struct StoreEventsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: StoreEventsViewModel

    init(viewModel: StoreEventsViewModel) {
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
            title: String(localized: "Events"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            emptyContent()
            events()
            loadMoreAction()

        }
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func events() -> some View {

        LazyVStack(spacing: self.style.spacing(.medium)) {

            ForEach(self.viewModel.events) { event in
                eventCard(event)
            }

        }

    }

    @ViewBuilder
    private func eventCard(_ event: StoreEvent) -> some View {

        StoreEventCard(event: event, location: self.viewModel.location) { [weak viewModel] in
            viewModel?.openEvent(event)
        }

    }

    @ViewBuilder
    private func emptyContent() -> some View {

        if self.viewModel.events.isEmpty && !self.viewModel.isLoading {

            if self.viewModel.hasLoadFailed {

                CommerceEmptyState(
                    systemImage: "wifi.exclamationmark",
                    title: String(localized: "Events Couldn't Load"),
                    message: String(localized: "Check your connection and try again.")
                )

                LeafLaunchButton(title: String(localized: "Try Again")) {
                    self.viewModel.loadData(showHud: false)
                }

            } else if self.viewModel.hasCompletedInitialLoad {

                CommerceEmptyState(
                    systemImage: "calendar",
                    title: String(localized: "No Upcoming Events"),
                    message: String(localized: "New events will appear here when announced.")
                )

            }

        }

    }

    @ViewBuilder
    private func loadMoreAction() -> some View {

        if self.viewModel.hasMoreEvents {

            LeafLaunchButton(title: String(localized: "Load More Events")) {
                self.viewModel.loadMore()
            }
            .disabled(self.viewModel.isLoading)

            if self.viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity)
            }

        }

    }

}

#Preview {

    StoreEventsScreen(
        viewModel: mockResolve(StoreEventsViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
