import SwiftUI

struct LocationsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: LocationsViewModel

    init(viewModel: LocationsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        LLAppHeaderScrollView {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            selectionFooter()
        }
        .interactiveDismissDisabled(!self.viewModel.canDismiss)
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }
        .task { [weak viewModel] in
            viewModel?.loadData(showHud: true)
        }
        .onDisappear { [weak viewModel] in viewModel?.cancelLocationSearch() }

    }

    @ViewBuilder
    private func navHeader() -> some View {

        StoreNavHeader(
            configuration: self.viewModel.configuration,
            subtitle: String(localized: "Choose a location"),
            onDismiss: self.viewModel.canDismiss ? { [weak viewModel] in viewModel?.dismiss() } : nil
        )
        .safeAreaPadding(.top, self.style.spacing(.medium))

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            LocationSearchControls(viewModel: self.viewModel)
            locationResults()
            retryAction()

        }
        .padding(.bottom, .large)

    }

    @ViewBuilder
    private func locationResults() -> some View {

        if self.viewModel.locations.isEmpty {

            CommerceEmptyState(
                systemImage: "mappin.and.ellipse",
                title: String(localized: "No Locations Available"),
                message: String(localized: "There are no available locations.")
            )

        } else if self.viewModel.filteredLocations.isEmpty {

            VStack(spacing: self.style.spacing(.small)) {

                CommerceEmptyState(
                    systemImage: "magnifyingglass",
                    title: String(localized: "No Stores Found"),
                    message: String(localized: "Try another city, ZIP code or store name.")
                )

                LeafLaunchButton(title: String(localized: "Clear Search")) { [weak viewModel] in
                    viewModel?.clearSearch()
                }

            }

        } else {
            locations()
        }

    }

    @ViewBuilder
    private func locations() -> some View {

        let locations = self.viewModel.filteredLocations

        LLAppCardView(verticalPadding: .none, horizontalPadding: .none, cornerRadius: .large) {

            LazyVStack(spacing: 0) {

                ForEach(locations, id: \.id) { location in

                    locationRow(location)

                    if location.id != locations.last?.id {

                        Divider()
                            .overlay(self.style.background(.border))
                            .padding(.horizontal, .small2)

                    }

                }

            }

        }

    }

    @ViewBuilder
    private func locationRow(_ location: BootstrapLocation) -> some View {

        LocationSelectionCard(
            location: location,
            details: self.viewModel.locationDetails[location.id],
            isLoading: self.viewModel.isLoading,
            isSelected: self.viewModel.selectedLocationId == location.id
        ) { [weak viewModel] in
            viewModel?.selectLocation(id: location.id)
        }
        .disabled(self.viewModel.isContinuing)

    }

    @ViewBuilder
    private func selectionFooter() -> some View {

        LocationSelectionFooter(
            selectedLocationName: self.viewModel.selectedLocation?.name,
            isEnabled: self.viewModel.canContinue
        ) { [weak viewModel] in
            viewModel?.continueToLocation()
        }

    }

    @ViewBuilder
    private func retryAction() -> some View {

        if !self.viewModel.failedLocationIds.isEmpty {

            LeafLaunchButton(
                title: String(localized: "Retry Location Details"),
                icon: .systemImage("arrow.clockwise")
            ) { [weak viewModel] in
                viewModel?.loadData(showHud: true)
            }
            .disabled(self.viewModel.isLoading || self.viewModel.isContinuing)

        }

    }

}

#Preview {

    LocationsScreen(viewModel: mockResolve(LocationsViewModel.self))
        .withMockPreviews()

}
