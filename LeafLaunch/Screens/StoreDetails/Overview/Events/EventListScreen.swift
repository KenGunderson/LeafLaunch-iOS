import SwiftUI

struct EventListScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: EventListViewModel

    init(viewModel: EventListViewModel) {
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
            title: String(localized: "Events"),
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

            emptyContent()
            events()
            loadMoreAction()

        }
        .tabFlowContentSpacing()

    }

    @ContentBuilder
    private func events() -> some View {

        LazyVStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            ForEach(self.viewModel.events) { event in
                eventCard(event)
            }

        }

    }

    @ContentBuilder
    private func eventCard(_ event: StoreEvent) -> some View {

        StoreEventCard(
            event: event,
            location: self.viewModel.location
        ) { [weak viewModel] in
            viewModel?.openEvent(event)
        }

    }

    @ContentBuilder
    private func emptyContent() -> some View {

        let hasResolvedEvents = self.viewModel.hasCompletedInitialLoad || !self.viewModel.isLoading

        if self.viewModel.events.isEmpty && hasResolvedEvents {

            if self.viewModel.hasLoadFailed && !self.viewModel.hasCompletedInitialLoad {

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

    @ContentBuilder
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

    EventListScreen(
        viewModel: mockResolve(EventListViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
